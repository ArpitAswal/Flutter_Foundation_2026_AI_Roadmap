import '../../../domain/models/ai_model.dart';

/// Base interface for AI Remote Data Sources.
abstract class AiRemoteDataSource {
  /// Sends a message to the AI provider and streams the text response back.
  ///
  /// [systemPrompt] Contains the assembled guardrails, Meta-Context, and Lesson-Context.
  /// [userMessage] The actual question asked by the user.
  /// [model] The user-selected AI model.
  Stream<String> sendMessage({
    required String systemPrompt,
    required String userMessage,
    required AiModel model,
  });
}
