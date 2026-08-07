import 'package:equatable/equatable.dart';

import '../../../domain/models/ai_model.dart';
import '../../../domain/models/curriculum/lesson_content.dart';
import '../../../domain/models/curriculum/lesson_day.dart';

/// Base class for all events related to the AI Tutor feature.
sealed class AiTutorEvent extends Equatable {
  const AiTutorEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the AI Tutor bottom sheet is opened to initialize the chat.
final class AiTutorInitialized extends AiTutorEvent {
  /// The title of the current lesson context.
  final String contextText;

  const AiTutorInitialized({required this.contextText});

  @override
  List<Object?> get props => [contextText];
}

/// Dispatched when the user submits a question to the AI Tutor.
final class AiTutorMessageSent extends AiTutorEvent {
  /// The raw question typed by the user.
  final String message;

  /// The lesson context the user is currently studying, if any.
  final LessonDay? currentLesson;

  /// The lesson theory content, if any.
  final LessonContent? currentContent;

  /// The AI model selected by the user for this query (defaults to AiModel.geminiFlash).
  final AiModel model;

  const AiTutorMessageSent({
    required this.message,
    this.currentLesson,
    this.currentContent,
    this.model = AiModel.geminiFlash,
  });

  @override
  List<Object?> get props => [message, currentLesson, currentContent, model];
}
