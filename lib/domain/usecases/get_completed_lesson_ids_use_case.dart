import 'package:injectable/injectable.dart';

import '../../data/local/sources/progress_local_data_source.dart';

/// Use case for reading all completed lesson IDs from local Hive storage.
///
/// Returns a [Set<String>] for O(1) membership lookup when computing lock states.
@injectable
class GetCompletedLessonIdsUseCase {
  final ProgressLocalDataSource _dataSource;

  const GetCompletedLessonIdsUseCase(this._dataSource);

  /// Returns all completed lesson IDs as an immutable set.
  Set<String> call() {
    return _dataSource.getCompletedLessonIds();
  }
}
