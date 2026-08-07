import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/models/ai_model.dart';
import 'ai_remote_data_source.dart';

/// Remote data source responsible for communicating with the Gemini API.
@Injectable(as: AiRemoteDataSource)
@Named('gemini')
class GeminiDataSourceImpl implements AiRemoteDataSource {
  @override
  Stream<String> sendMessage({
    required String systemPrompt,
    required String userMessage,
    required AiModel model,
  }) async* {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw const AiTutorException(
        'GEMINI_API_KEY is not set in the .env file.',
      );
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
