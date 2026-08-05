import 'package:injectable/injectable.dart';

import '../../data/local/sources/progress_local_data_source.dart';

/// Use case for marking a lesson as complete in local Hive storage.
///
/// Idempotent — safe to call multiple times for the same lesson.
@injectable
class MarkLessonCompleteUseCase {
  final ProgressLocalDataSource _dataSource;

  const MarkLessonCompleteUseCase(this._dataSource);

  /// Marks the lesson identified by [lessonId] (format: "p{phase}_m{module}_d{day}") as complete.
  Future<void> call(String lessonId) {
    return _dataSource.markLessonComplete(lessonId);
  }
}
