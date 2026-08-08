import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/models/ai_model.dart';

/// Local storage gateway for AI assistant preferences and provider keys.
///
/// Model preferences are stored in SharedPreferences because they are
/// non-sensitive and should be restored quickly on launch.
/// Provider API keys are stored in Flutter Secure Storage so they are backed
/// by the platform's encrypted keychain or keystore.
@singleton
class AiAssistantSettingsLocalDataSource {
  static const String _selectedModelKey = 'ai_assistant_selected_model';
  static const String _geminiApiKey = 'ai_assistant_gemini_api_key';
  static const String _openAiApiKey = 'ai_assistant_openai_api_key';
  static const String _anthropicApiKey = 'ai_assistant_anthropic_api_key';

  final FlutterSecureStorage _secureStorage;

  const AiAssistantSettingsLocalDataSource(this._secureStorage);

  Future<AiModel> readSelectedModel() async {
    final prefs = await SharedPreferences.getInstance();
    final rawValue = prefs.getString(_selectedModelKey);

    if (rawValue == null) {
      return AiModel.geminiFlash;
    }

    for (final model in AiModel.values) {
      if (model.name == rawValue) {
        return model;
      }
    }

    return AiModel.geminiFlash;
  }

  Future<void> saveSelectedModel(AiModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedModelKey, model.name);
  }

  Future<String?> readProviderKey(AiModel model) {
    return _secureStorage.read(key: _storageKeyForModel(model));
  }

  Future<void> saveProviderKey(AiModel model, String apiKey) async {
    final normalizedKey = apiKey.trim();
    if (normalizedKey.isEmpty) {
      await deleteProviderKey(model);
      return;
    }

    await _secureStorage.write(
      key: _storageKeyForModel(model),
      value: normalizedKey,
    );
  }

  Future<void> deleteProviderKey(AiModel model) {
    return _secureStorage.delete(key: _storageKeyForModel(model));
  }

  Future<Map<AiModel, bool>> readKeyAvailability() async {
    final availability = <AiModel, bool>{};

    for (final model in AiModel.values) {
      final value = await readProviderKey(model);
      availability[model] = value != null && value.trim().isNotEmpty;
    }

    return availability;
  }

  Future<bool> hasAnyProviderKey() async {
    final availability = await readKeyAvailability();
    return availability.values.any((isAvailable) => isAvailable);
  }

  String _storageKeyForModel(AiModel model) {
    return switch (model) {
      AiModel.geminiFlash => _geminiApiKey,
      AiModel.gpt4oMini => _openAiApiKey,
      AiModel.claudeHaiku => _anthropicApiKey,
    };
  }
}
