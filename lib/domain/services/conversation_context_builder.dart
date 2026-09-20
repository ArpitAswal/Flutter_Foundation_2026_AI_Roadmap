import 'package:injectable/injectable.dart';

import '../models/ai_chat_turn.dart';

/// Service responsible for preparing a bounded, sanitized recent-turn
/// conversation window to provide conversational continuity without
/// exceeding context budgets or persisting unbounded memory.
@singleton
class ConversationContextBuilder {
  /// Maximum number of completed turns to include in the context window.
  final int maxTurns;

  /// Maximum total characters allowed across all formatted turns.
  final int maxCharacters;

  const ConversationContextBuilder({
    this.maxTurns = 6,
    this.maxCharacters = 4000,
  });

  @factoryMethod
  static ConversationContextBuilder create() => const ConversationContextBuilder();

  /// Sanitizes and trims [history] to fit within the configured turn and character budget,
  /// preserving chronological order and trimming oldest turns first.
  List<ChatTurn> buildWindow({
    required List<ChatTurn> history,
    required String activeQuestion,
    String? currentLessonId,
  }) {
    // 1. Filter out turns that should not be sent to the provider
    // (errors, loading placeholders, empty messages, or system prompts)
    final sanitized = history.where((turn) {
      if (turn.isError) return false;
      if (turn.text.trim().isEmpty) return false;
      // Skip system messages or internal diagnostics
      if (turn.role == ChatRole.system) return false;
      return true;
    }).toList();

    // 2. Bound by max turns (taking the most recent turns)
    var candidateTurns = sanitized.length > maxTurns
        ? sanitized.sublist(sanitized.length - maxTurns)
        : List<ChatTurn>.from(sanitized);

    // 3. Add active question as the newest turn
    final activeTurn = ChatTurn(
      id: 'active_question',
      role: ChatRole.user,
      text: activeQuestion.trim(),
      timestamp: DateTime.now(),
      lessonId: currentLessonId,
    );
    candidateTurns.add(activeTurn);

    // 4. Enforce character budget by trimming oldest candidate turns first (never trimming the active turn)
    int totalLength() => candidateTurns.fold(0, (sum, turn) => sum + turn.text.length);

    while (candidateTurns.length > 1 && totalLength() > maxCharacters) {
      candidateTurns.removeAt(0);
    }

    return candidateTurns;
  }
}
