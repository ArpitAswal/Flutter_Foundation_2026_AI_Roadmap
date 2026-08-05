import 'package:hive_flutter/hive_flutter.dart';

import '../models/lesson_record.dart';
import '../models/user_progress_record.dart';

/// Centralized registration for all Hive TypeAdapters.
///
/// Must be called once before any Hive boxes are opened.
void registerHiveAdapters() {
  Hive.registerAdapter(LessonRecordAdapter());
  Hive.registerAdapter(UserProgressRecordAdapter());
}
