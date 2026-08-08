import 'package:equatable/equatable.dart';

/// Represents a single message in the AI Tutor chat interface.
class ChatMessage extends Equatable {
  /// The content of the message.
  final String text;

  /// Whether this message was sent by the user (true) or the AI (false).
  final bool isUser;

  /// Whether this message represents an error state.
  final bool isError;

  /// Whether this message is currently loading.
  final bool isLoading;

  /// Optional list of suggestion chips to display below the message.
  final List<String>? suggestions;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.isLoading = false,
    this.suggestions,
  });

  /// Creates a copy of this message with the given fields replaced.
  ChatMessage copyWith({
    String? text,
    bool? isUser,
    bool? isError,
    bool? isLoading,
    List<String>? suggestions,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  @override
  List<Object?> get props => [text, isUser, isError, isLoading, suggestions];
}
