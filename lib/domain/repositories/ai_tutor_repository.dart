import '../models/gemini_model.dart';

/// Abstract repository interface for the AI Tutor feature.
abstract class AiTutorRepository {
  /// Sends a context-injected prompt to the AI and streams the response.
  ///
  /// [systemPrompt] Assembled system instructions containing guardrails, Meta-Context, and Lesson-Context.
  /// [userMessage] The raw query from the user.
  /// [model] The user-selected Gemini model (defaults to GeminiModel.flash).
  Stream<String> askQuestion({
    required String systemPrompt,
    required String userMessage,
    GeminiModel model = GeminiModel.flash,
  });
}
