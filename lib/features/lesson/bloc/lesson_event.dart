part of 'lesson_bloc.dart';

abstract class LessonEvent {}

/// Triggers loading of a specific lesson day's content.
class LessonLoadRequested extends LessonEvent {
  final int phase;
  final int module;
  final int day;
  final bool again;

  LessonLoadRequested({
    required this.phase,
    required this.module,
    required this.day,
    this.again = false
  });
}

/// Triggers marking the current lesson as complete in local progress storage.
class LessonMarkCompleteRequested extends LessonEvent {}
