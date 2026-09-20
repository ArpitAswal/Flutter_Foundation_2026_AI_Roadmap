import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/error/app_exception.dart';
import '../../../domain/models/ai_chat_turn.dart';
import '../../../domain/models/ai_model.dart';
import '../../../domain/models/key_validation_result.dart';
import '../../local/sources/ai_assistant_settings_local_data_source.dart';
import 'ai_remote_data_source.dart';

/// Remote data source responsible for communicating with the Gemini API.
@Injectable(as: AiRemoteDataSource)
@Named('gemini')
class GeminiDataSourceImpl implements AiRemoteDataSource {
  final AiAssistantSettingsLocalDataSource _settingsLocalDataSource;

  const GeminiDataSourceImpl(this._settingsLocalDataSource);

  @override
  Stream<String> sendMessage({
    required String systemPrompt,
    required String userMessage,
    required AiModel model,
    List<ChatTurn> history = const [],
  }) async* {
    final apiKey = await _settingsLocalDataSource.readProviderKey(model);
    if (apiKey == null || apiKey.isEmpty) {
      throw const AiTutorException(StringConstants.missingGeminiKey);
    }

    try {
      final generativeModel = GenerativeModel(
        model: model.modelName,
        apiKey: apiKey,
        systemInstruction: Content.system(systemPrompt),
      );

      final contents = <Content>[];
      for (final turn in history) {
        if (turn.role == ChatRole.user) {
          contents.add(Content.text(turn.text));
        } else if (turn.role == ChatRole.assistant) {
          contents.add(Content.model([TextPart(turn.text)]));
        }
      }
      contents.add(Content.text(userMessage));

      final responseStream = generativeModel.generateContentStream(contents);

      await for (final chunk in responseStream) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } on GenerativeAIException catch (e) {
      throw NetworkException('Gemini API Error: ${e.message}', e);
    } catch (e) {
      throw NetworkException(
        'An unexpected error occurred while communicating with Gemini.',
        e,
      );
    }
  }

  @override
  Future<KeyValidationResult> validateKey(String apiKey, AiModel model) async {
    try {
      final generativeModel = GenerativeModel(
        model: model.modelName,
        apiKey: apiKey,
      );
      // Make a minimal token count request to validate auth
      await generativeModel.countTokens([Content.text('test')]);
      return KeyValidationResult.valid;
    } on GenerativeAIException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('api key not valid') ||
          msg.contains('unauthorized') ||
          msg.contains('invalid')) {
        return KeyValidationResult.unauthorized;
      }
      if (msg.contains('quota') ||
          msg.contains('resource has been exhausted') ||
          msg.contains('rate')) {
        return KeyValidationResult.rateLimited;
      }
      if (msg.contains('not found') || msg.contains('unsupported model')) {
        return KeyValidationResult.modelUnavailable;
      }
      return KeyValidationResult.unauthorized;
    } catch (e) {
      if (e.toString().toLowerCase().contains('socket') ||
          e.toString().toLowerCase().contains('connection') ||
          e.toString().toLowerCase().contains('network')) {
        return KeyValidationResult.networkUnavailable;
      }
      return KeyValidationResult.unknown;
    }
  }
}
