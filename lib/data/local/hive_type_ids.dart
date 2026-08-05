/// Central registry for all Hive typeId values across the application.
///
/// CRITICAL HIVE RULE:
/// Never change or reuse an existing typeId once data has been saved to disk.
/// Always assign the next available integer for every new @HiveType model.
abstract class HiveTypeIds {
  /// Type ID for [UserProgressRecord] — basic completed curriculum tracking.
  static const int userProgressRecord = 1;
}
