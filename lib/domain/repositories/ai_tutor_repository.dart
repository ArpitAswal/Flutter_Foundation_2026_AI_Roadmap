import '../models/ai_model.dart';

/// Abstract repository interface for the AI Tutor feature.
abstract class AiTutorRepository {
  /// Sends a context-injected prompt to the AI and streams the response.
  ///
  /// [systemPrompt] Assembled system instructions containing guardrails, Meta-Context, and Lesson-Context.
  /// [userMessage] The raw query from the user.
  /// [model] The user-selected AI model (defaults to AiModel.geminiFlash).
  Stream<String> askQuestion({
    required String systemPrompt,
    required String userMessage,
    required AiModel model,
  });
}
