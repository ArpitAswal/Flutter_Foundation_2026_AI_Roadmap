import 'package:hive_flutter/hive_flutter.dart';

import '../models/lesson_record.dart';

/// Centralized registration for Hive TypeAdapters.
void registerHiveAdapters() {
  Hive.registerAdapter(LessonRecordAdapter());
}
