import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../models/user_progress_record.dart';

/// Local data source for reading and writing the user's curriculum progress.
///
/// Progress is stored entirely in Hive — no remote sync.
/// Completed lessons are stored as ID strings in the format "p{phase}_m{module}_d{day}".
@singleton
class ProgressLocalDataSource {
  Box<UserProgressRecord> get _box =>
      Hive.box<UserProgressRecord>(AppConstants.progressBox);

  /// Returns the single [UserProgressRecord] for this device, creating it if absent.
  UserProgressRecord get _record {
    if (_box.isEmpty) {
      final record = UserProgressRecord()..completedLessonIds = [];
      _box.add(record);
      return record;
    }
    return _box.getAt(0)!;
  }

  /// Returns all completed lesson IDs as an immutable set.
  Set<String> getCompletedLessonIds() {
    return _record.completedLessonIds.toSet();
  }

  /// Returns true if the lesson with [lessonId] (e.g., "p1_m1_d1") is complete.
  bool isLessonComplete(String lessonId) {
    return _record.completedLessonIds.contains(lessonId);
  }

  /// Marks the lesson with [lessonId] as complete.
  ///
  /// Idempotent — calling this multiple times has no side effect.
  Future<void> markLessonComplete(String lessonId) async {
    final record = _record;
    if (!record.completedLessonIds.contains(lessonId)) {
      record.completedLessonIds = [...record.completedLessonIds, lessonId];
      await record.save();
    }
  }
}
