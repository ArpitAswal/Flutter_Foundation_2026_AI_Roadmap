import 'package:injectable/injectable.dart';

import '../models/curriculum/lesson_day.dart';
import '../repositories/curriculum_repository.dart';

/// Use case for loading a specific lesson day's full content.
///
/// Used by [LessonBloc] to populate the Lesson Screen.
@injectable
class GetLessonDayUseCase {
  final CurriculumRepository _repository;

  const GetLessonDayUseCase(this._repository);

  Future<LessonDay> call({
    required int phase,
    required int module,
    required int day,
  }) {
    return _repository.getLessonDay(phase: phase, module: module, day: day);
  }
}
