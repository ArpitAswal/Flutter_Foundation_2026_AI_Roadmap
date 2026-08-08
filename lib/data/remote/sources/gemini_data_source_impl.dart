import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/error/app_exception.dart';
import '../../../domain/models/ai_model.dart';
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

      final content = [Content.text(userMessage)];
      final responseStream = generativeModel.generateContentStream(content);

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
}
