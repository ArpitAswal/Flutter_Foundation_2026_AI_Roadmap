part of 'curriculum_bloc.dart';

abstract class CurriculumState {}

class CurriculumInitial extends CurriculumState {}

class CurriculumLoading extends CurriculumState {}

/// Loaded state — carries all phases and the set of completed lesson IDs.
///
/// The UI uses [completedLessonIds] to compute lock states without additional
/// Bloc events or repository calls.
class CurriculumLoaded extends CurriculumState {
  final List<Phase> phases;
  final Set<String> completedLessonIds;

  CurriculumLoaded({
    required this.phases,
    required this.completedLessonIds,
  });
}

class CurriculumError extends CurriculumState {
  final String message;
  CurriculumError(this.message);
}
