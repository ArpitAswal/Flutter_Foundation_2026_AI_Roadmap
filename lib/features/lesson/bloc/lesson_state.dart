part of 'lesson_bloc.dart';

abstract class LessonState {}

class LessonInitial extends LessonState {}

class LessonLoading extends LessonState {}

/// Lesson loaded successfully — holds skeleton metadata and full content separately.
class LessonLoaded extends LessonState {
  /// Skeleton data: phase, module, day, title, tags, contentPath, customRoute.
  final LessonDay lesson;

  /// Full lesson content loaded lazily from [LessonDay.contentPath].
  final LessonContent content;

  /// Whether the user has already completed this lesson.
  final bool isComplete;

  LessonLoaded({
    required this.lesson,
    required this.content,
    required this.isComplete,
  });

  /// Returns a copy with [isComplete] updated.
  LessonLoaded copyWith({bool? isComplete}) {
    return LessonLoaded(
      lesson: lesson,
      content: content,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class LessonError extends LessonState {
  final String message;
  LessonError(this.message);
}
