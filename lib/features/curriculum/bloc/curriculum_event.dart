part of 'curriculum_bloc.dart';

abstract class CurriculumEvent {}

/// Triggers loading of all phases and completed lesson IDs.
class CurriculumLoadRequested extends CurriculumEvent {}
