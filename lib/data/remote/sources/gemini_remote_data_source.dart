import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/app_exception.dart';
import '../../../domain/models/gemini_model.dart';

/// Remote data source responsible for communicating with the Gemini API.
@singleton
class GeminiRemoteDataSource {
  /// Sends a message to Gemini and streams the text response back.
  ///
  /// [systemPrompt] Contains the assembled guardrails, Meta-Context, and Lesson-Context.
  /// [userMessage] The actual question asked by the user.
  /// [model] The user-selected Gemini model (defaults to GeminiModel.flash).
  Stream<String> sendMessage({
    required String systemPrompt,
    required String userMessage,
    GeminiModel model = GeminiModel.flash,
  }) async* {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw const AiTutorException('GEMINI_API_KEY is not set in the .env file.');
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
      throw NetworkException('An unexpected error occurred while communicating with the AI Tutor.', e);
    }
  }
}
