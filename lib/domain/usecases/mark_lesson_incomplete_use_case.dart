import 'package:injectable/injectable.dart';

import '../../data/local/sources/progress_local_data_source.dart';

/// Use case for marking a lesson as incomplete in local Hive storage.
@injectable
class MarkLessonIncompleteUseCase {
  final ProgressLocalDataSource _dataSource;

  const MarkLessonIncompleteUseCase(this._dataSource);

  /// Marks the lesson identified by [lessonId] (format: "p{phase}_m{module}_d{day}") as incomplete.
  Future<void> call(String lessonId) {
    return _dataSource.markLessonIncomplete(lessonId);
  }
}
