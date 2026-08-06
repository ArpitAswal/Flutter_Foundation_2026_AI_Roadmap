import 'package:injectable/injectable.dart';

import '../models/curriculum/lesson_content.dart';
import '../repositories/curriculum_repository.dart';

/// Use case for lazily loading the full content of a single lesson day.
///
/// Called by [LessonBloc] after the skeleton [LessonDay] has been loaded
/// and the user has navigated to the Lesson Screen.
@injectable
class GetDayContentUseCase {
  final CurriculumRepository _repository;

  const GetDayContentUseCase(this._repository);

  Future<LessonContent> call(String contentPath) {
    return _repository.getDayContent(contentPath);
  }
}
