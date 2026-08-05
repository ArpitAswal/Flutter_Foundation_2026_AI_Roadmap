part of 'lesson_bloc.dart';

abstract class LessonState {}

class LessonInitial extends LessonState {}

class LessonLoading extends LessonState {}

/// Lesson content loaded successfully.
class LessonLoaded extends LessonState {
  final LessonDay lesson;

  /// Whether the user has already completed this lesson.
  final bool isComplete;

  LessonLoaded({required this.lesson, required this.isComplete});

  /// Returns a copy with [isComplete] updated.
  LessonLoaded copyWith({bool? isComplete}) {
    return LessonLoaded(
      lesson: lesson,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class LessonError extends LessonState {
  final String message;
  LessonError(this.message);
}
