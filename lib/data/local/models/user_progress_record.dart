import 'package:hive_flutter/hive_flutter.dart';
import '../hive_type_ids.dart';

part 'user_progress_record.g.dart';

/// Hive data model for tracking the user's local curriculum progress.
///
/// Stores a flat list of completed lesson IDs in the format "p{phase}_m{module}_d{day}".
/// Example: "p1_m1_d1" means Phase 1, Module 1, Day 1 is completed.
///
/// This simple list-of-strings approach avoids complex nested structures and
/// makes lock/unlock computation straightforward: just check membership.
@HiveType(typeId: HiveTypeIds.userProgressRecord)
class UserProgressRecord extends HiveObject {
  /// List of completed lesson ID strings in format "p{phase}_m{module}_d{day}".
  @HiveField(0)
  late List<String> completedLessonIds;
}
