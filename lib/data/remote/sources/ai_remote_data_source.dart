import '../../../domain/models/ai_chat_turn.dart';
import '../../../domain/models/ai_model.dart';
import '../../../domain/models/key_validation_result.dart';

/// Base interface for AI Remote Data Sources.
abstract class AiRemoteDataSource {
  /// Sends a message along with bounded conversation [history] to the AI provider
  /// and streams the text response back.
  ///
  /// [systemPrompt] Contains the assembled guardrails, Meta-Context, and Lesson-Context.
  /// [userMessage] The actual question asked by the user.
  /// [model] The user-selected AI model.
  /// [history] Recent prior turns from the current app session.
  Stream<String> sendMessage({
    required String systemPrompt,
    required String userMessage,
    required AiModel model,
    List<ChatTurn> history = const [],
  });

  /// Verifies if the provided [apiKey] is valid by making a lightweight API call
  /// and returns a typed [KeyValidationResult].
  Future<KeyValidationResult> validateKey(String apiKey, AiModel model);
}
