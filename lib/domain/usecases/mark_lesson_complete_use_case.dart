import 'package:injectable/injectable.dart';

import '../repositories/lesson_repository.dart';

/// Marks a lesson as completed by its ID.
@injectable
class MarkLessonCompleteUseCase {
  final LessonRepository _repository;

  const MarkLessonCompleteUseCase(this._repository);

  Future<void> execute(String lessonId) => _repository.markLessonComplete(lessonId);
}
