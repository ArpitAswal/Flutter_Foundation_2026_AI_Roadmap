import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/models/curriculum/lesson_day.dart';
import '../../../domain/usecases/get_completed_lesson_ids_use_case.dart';
import '../../../domain/usecases/get_lesson_day_use_case.dart';
import '../../../domain/usecases/mark_lesson_complete_use_case.dart';

part 'lesson_event.dart';
part 'lesson_state.dart';

/// Bloc for loading and interacting with a single lesson day.
///
/// Handles two events:
/// - [LessonLoadRequested] — loads lesson content + checks completion status.
/// - [LessonMarkCompleteRequested] — persists completion and updates UI state.
@injectable
class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final GetLessonDayUseCase _getLessonDay;
  final MarkLessonCompleteUseCase _markComplete;
  final GetCompletedLessonIdsUseCase _getCompletedIds;

  LessonBloc(this._getLessonDay, this._markComplete, this._getCompletedIds)
      : super(LessonInitial()) {
    on<LessonLoadRequested>(_onLoadRequested);
    on<LessonMarkCompleteRequested>(_onMarkComplete);
  }

  Future<void> _onLoadRequested(
    LessonLoadRequested event,
    Emitter<LessonState> emit,
  ) async {
    emit(LessonLoading());
    try {
      final lesson = await _getLessonDay(
        phase: event.phase,
        module: event.module,
        day: event.day,
      );
      final completedIds = _getCompletedIds();
      final isComplete = completedIds.contains(lesson.lessonId);
      emit(LessonLoaded(lesson: lesson, isComplete: isComplete));
    } catch (e) {
      emit(LessonError('Failed to load lesson: ${e.toString()}'));
    }
  }

  Future<void> _onMarkComplete(
    LessonMarkCompleteRequested event,
    Emitter<LessonState> emit,
  ) async {
    final current = state;
    if (current is! LessonLoaded) return;

    try {
      await _markComplete(current.lesson.lessonId);
      emit(current.copyWith(isComplete: true));
    } catch (e) {
      // Non-critical failure — lesson display is unaffected
    }
  }
}
