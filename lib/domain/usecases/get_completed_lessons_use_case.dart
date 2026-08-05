import 'package:injectable/injectable.dart';

import '../models/lesson.dart';
import '../repositories/lesson_repository.dart';

/// Retrieves all lessons the user has completed.
@injectable
class GetCompletedLessonsUseCase {
  final LessonRepository _repository;

  const GetCompletedLessonsUseCase(this._repository);

  Future<List<Lesson>> execute() => _repository.getCompletedLessons();
}
