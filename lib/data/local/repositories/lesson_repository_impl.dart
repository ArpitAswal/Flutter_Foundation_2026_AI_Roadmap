import 'package:injectable/injectable.dart';

import '../../../domain/models/lesson.dart';
import '../../../domain/repositories/lesson_repository.dart';
import '../sources/lesson_local_data_source.dart';

/// Implementation of [LessonRepository] that delegates to the local Hive data source.
@Injectable(as: LessonRepository)
class LessonRepositoryImpl implements LessonRepository {
  final LessonLocalDataSource _localDataSource;

  const LessonRepositoryImpl(this._localDataSource);

  @override
  Future<Lesson?> getLessonById(String lessonId) async {
    final record = await _localDataSource.getLessonById(lessonId);
    return record?.toDomain();
  }

  @override
  Future<List<Lesson>> getCompletedLessons() async {
    final records = await _localDataSource.getCompletedLessons();
    return records.map((r) => r.toDomain()).toList();
  }

  @override
  Future<void> markLessonComplete(String lessonId) async {
    await _localDataSource.markLessonComplete(lessonId);
  }
}
