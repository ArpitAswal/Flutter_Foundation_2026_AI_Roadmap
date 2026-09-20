import 'package:equatable/equatable.dart';

import '../services/question_scope_policy.dart';

/// Represents the role of a message participant.
enum ChatRole {
  user,
  assistant,
  system,
}

/// Immutable domain model representing a single turn in an AI Tutor conversation.
class ChatTurn extends Equatable {
  /// Unique identifier for this turn.
  final String id;

  /// Role of the sender (user, assistant, system).
  final ChatRole role;

  /// Content text of the turn.
  final String text;

  /// Timestamp when the turn occurred.
  final DateTime timestamp;

  /// Scope policy outcome for user queries.
  final QuestionScopeResult? scopeOutcome;

  /// Optional active lesson ID when the message was sent.
  final String? lessonId;

  /// Whether this turn represents an error.
  final bool isError;

  const ChatTurn({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.scopeOutcome,
    this.lessonId,
    this.isError = false,
  });

  ChatTurn copyWith({
    String? id,
    ChatRole? role,
    String? text,
    DateTime? timestamp,
    QuestionScopeResult? scopeOutcome,
    String? lessonId,
    bool? isError,
  }) {
    return ChatTurn(
      id: id ?? this.id,
      role: role ?? this.role,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      scopeOutcome: scopeOutcome ?? this.scopeOutcome,
      lessonId: lessonId ?? this.lessonId,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [
        id,
        role,
        text,
        timestamp,
        scopeOutcome,
        lessonId,
        isError,
      ];
}
