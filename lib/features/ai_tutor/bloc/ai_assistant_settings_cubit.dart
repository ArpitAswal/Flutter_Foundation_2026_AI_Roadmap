import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/string_constants.dart';
import '../../../domain/models/ai_model.dart';
import '../../../data/local/sources/ai_assistant_settings_local_data_source.dart';
import '../../../data/remote/sources/ai_data_source_factory.dart';
import '../../../domain/models/key_validation_result.dart';
import 'ai_assistant_settings_state.dart';

/// Holds the persisted AI assistant configuration for the chat and settings UI.
@lazySingleton
class AiAssistantSettingsCubit extends Cubit<AiAssistantSettingsState> {
  final AiAssistantSettingsLocalDataSource _localDataSource;
  final AiDataSourceFactory _dataSourceFactory;

  AiAssistantSettingsCubit(this._localDataSource, this._dataSourceFactory)
    : super(AiAssistantSettingsState.initial());

  Future<void> loadSettings() async {
    if (!state.isLoading && state.errorMessage == null) {
      return;
    }

    emit(state.copyWith(isLoading: true, clearErrorMessage: true));

    try {
      final selectedModel = await _localDataSource.readSelectedModel();
      final keyAvailability = await _localDataSource.readKeyAvailability();
      final savedKeys = await _readSavedKeys();

      emit(
        state.copyWith(
          isLoading: false,
          selectedModel: selectedModel,
          keyAvailability: keyAvailability,
          savedKeys: savedKeys,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: StringConstants.aiAssistantSettingsLoadError,
        ),
      );
    }
  }

  Future<void> selectModel(AiModel model) async {
    emit(state.copyWith(isSavingModel: true, clearErrorMessage: true));

    try {
      await _localDataSource.saveSelectedModel(model);
      emit(
        state.copyWith(
          isSavingModel: false,
          selectedModel: model,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSavingModel: false,
          errorMessage: StringConstants.aiAssistantSettingsSaveError,
        ),
      );
    }
  }

  Future<void> saveProviderKey(AiModel model, String apiKey) async {
    emit(state.copyWith(savingKeyModel: model, clearErrorMessage: true));

    try {
      // Validate the key before persisting it with typed error classification
      final result = await _dataSourceFactory.validateKey(model, apiKey);
      if (!result.isValid) {
        final errorMsg = switch (result) {
          KeyValidationResult.unauthorized =>
            StringConstants.aiAssistantUnauthorizedKey,
          KeyValidationResult.rateLimited =>
            StringConstants.aiAssistantRateLimited,
          KeyValidationResult.modelUnavailable =>
            StringConstants.aiAssistantModelUnavailable,
          KeyValidationResult.networkUnavailable =>
            StringConstants.aiAssistantNetworkUnavailable,
          _ => StringConstants.aiAssistantInvalidKey,
        };

        emit(state.copyWith(clearSavingKeyModel: true, errorMessage: errorMsg));
        return;
      }

      await _localDataSource.saveProviderKey(model, apiKey);
      await _reloadKeyAvailability();
      emit(state.copyWith(clearSavingKeyModel: true, clearErrorMessage: true));
    } catch (_) {
      emit(
        state.copyWith(
          clearSavingKeyModel: true,
          errorMessage: StringConstants.aiAssistantKeySaveError,
        ),
      );
    }
  }

  Future<void> deleteProviderKey(AiModel model) async {
    emit(state.copyWith(savingKeyModel: model, clearErrorMessage: true));

    try {
      await _localDataSource.deleteProviderKey(model);
      await _reloadKeyAvailability();
      emit(state.copyWith(clearSavingKeyModel: true, clearErrorMessage: true));
    } catch (_) {
      emit(
        state.copyWith(
          clearSavingKeyModel: true,
          errorMessage: StringConstants.aiAssistantKeyDeleteError,
        ),
      );
    }
  }

  Future<void> _reloadKeyAvailability() async {
    final keyAvailability = await _localDataSource.readKeyAvailability();
    final savedKeys = await _readSavedKeys();
    emit(
      state.copyWith(keyAvailability: keyAvailability, savedKeys: savedKeys),
    );
  }

  String _maskKey(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.length <= 8) return '••••••••';
    final firstFour = trimmed.substring(0, 4);
    final lastFour = trimmed.substring(trimmed.length - 4);
    return '$firstFour••••••••$lastFour';
  }

  Future<Map<AiModel, String>> _readSavedKeys() async {
    final map = <AiModel, String>{};
    for (final model in AiModel.values) {
      final key = await _localDataSource.readProviderKey(model);
      // Store ONLY the non-reversible masked representation in state
      map[model] = _maskKey(key ?? '');
    }
    return map;
  }
}
