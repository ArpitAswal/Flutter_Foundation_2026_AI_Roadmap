import 'package:equatable/equatable.dart';
import '../models/chat_message.dart';

/// Base class for all states related to the AI Tutor feature.
sealed class AiTutorState extends Equatable {
  final List<ChatMessage> messages;

  const AiTutorState(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Initial state before any question is asked.
final class AiTutorInitial extends AiTutorState {
  const AiTutorInitial(super.messages);
}

/// Emitted when a question is submitted and context is being gathered or API is connecting.
final class AiTutorLoading extends AiTutorState {
  const AiTutorLoading(super.messages);
}

/// Emitted continuously as the Gemini stream yields new chunks of text.
final class AiTutorResponseStreaming extends AiTutorState {
  /// The accumulated response so far.
  final String partialResponse;

  const AiTutorResponseStreaming(
    super.messages, {
    required this.partialResponse,
  });

  @override
  List<Object?> get props => [messages, partialResponse];
}

/// Emitted when the stream completes successfully.
final class AiTutorResponseComplete extends AiTutorState {
  /// The complete final response.
  final String fullResponse;

  const AiTutorResponseComplete(super.messages, {required this.fullResponse});

  @override
  List<Object?> get props => [messages, fullResponse];
}

/// Emitted when an error occurs during keyword extraction, context building, or API communication.
final class AiTutorError extends AiTutorState {
  /// User-friendly error message.
  final String message;

  const AiTutorError(super.messages, {required this.message});

  @override
  List<Object?> get props => [messages, message];
}
