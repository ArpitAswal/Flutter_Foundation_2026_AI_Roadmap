import 'package:equatable/equatable.dart';

import '../../../domain/models/gemini_model.dart';
import '../../../domain/models/lesson.dart';

/// Base class for all events related to the AI Tutor feature.
sealed class AiTutorEvent extends Equatable {
  const AiTutorEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user submits a question to the AI Tutor.
final class AiTutorMessageSent extends AiTutorEvent {
  /// The raw question typed by the user.
  final String userMessage;

  /// The lesson context the user is currently studying.
  final Lesson currentLesson;

  /// The Gemini model selected by the user for this query (defaults to GeminiModel.flash).
  final GeminiModel model;

  const AiTutorMessageSent({
    required this.userMessage,
    required this.currentLesson,
    this.model = GeminiModel.flash,
  });

  @override
  List<Object?> get props => [userMessage, currentLesson, model];
}
