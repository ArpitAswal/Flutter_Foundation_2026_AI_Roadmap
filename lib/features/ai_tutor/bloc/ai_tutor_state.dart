import 'package:equatable/equatable.dart';

/// Base class for all states related to the AI Tutor feature.
sealed class AiTutorState extends Equatable {
  const AiTutorState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any question is asked.
final class AiTutorInitial extends AiTutorState {}

/// Emitted when a question is submitted and context is being gathered or API is connecting.
final class AiTutorLoading extends AiTutorState {}

/// Emitted continuously as the Gemini stream yields new chunks of text.
final class AiTutorResponseStreaming extends AiTutorState {
  /// The accumulated response so far.
  final String partialResponse;

  const AiTutorResponseStreaming({required this.partialResponse});

  @override
  List<Object?> get props => [partialResponse];
}

/// Emitted when the stream completes successfully.
final class AiTutorResponseComplete extends AiTutorState {
  /// The complete final response.
  final String fullResponse;

  const AiTutorResponseComplete({required this.fullResponse});

  @override
  List<Object?> get props => [fullResponse];
}

/// Emitted when an error occurs during keyword extraction, context building, or API communication.
final class AiTutorError extends AiTutorState {
  /// User-friendly error message.
  final String message;

  const AiTutorError({required this.message});

  @override
  List<Object?> get props => [message];
}
