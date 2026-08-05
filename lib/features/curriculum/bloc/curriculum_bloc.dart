import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/models/curriculum/phase.dart';
import '../../../domain/usecases/get_completed_lesson_ids_use_case.dart';
import '../../../domain/usecases/get_phases_use_case.dart';

part 'curriculum_event.dart';
part 'curriculum_state.dart';

/// Bloc responsible for loading the curriculum index and user progress.
///
/// Emits [CurriculumLoaded] with both the phase list and the set of completed
/// lesson IDs so the UI can compute lock states without additional async calls.
@injectable
class CurriculumBloc extends Bloc<CurriculumEvent, CurriculumState> {
  final GetPhasesUseCase _getPhases;
  final GetCompletedLessonIdsUseCase _getCompletedIds;

  CurriculumBloc(this._getPhases, this._getCompletedIds)
      : super(CurriculumInitial()) {
    on<CurriculumLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    CurriculumLoadRequested event,
    Emitter<CurriculumState> emit,
  ) async {
    emit(CurriculumLoading());
    try {
      final phases = await _getPhases();
      final completedIds = _getCompletedIds();
      emit(CurriculumLoaded(phases: phases, completedLessonIds: completedIds));
    } catch (e) {
      emit(CurriculumError('Failed to load curriculum: ${e.toString()}'));
    }
  }
}
