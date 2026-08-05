import 'package:hive_flutter/hive_flutter.dart';
import '../hive_type_ids.dart';

part 'lesson_record.g.dart';

/// Hive data model for a single lesson in the learning roadmap.
///
/// Stores both the curriculum content (for display) and the metadata
/// required by the AI context injection pipeline (taughtTechnologies,
/// searchKeywords, contentSummary).
@HiveType(typeId: HiveTypeIds.lessonRecord)
class LessonRecord extends HiveObject {
  /// Unique identifier matching the curriculum (e.g., "day_01").
  @HiveField(0)
  late String lessonId;

  /// Human-readable title (e.g., "Introduction to StatelessWidget").
  @HiveField(1)
  late String title;

  /// Day number in the roadmap (1-indexed).
  @HiveField(2)
  late int dayNumber;

  /// Main topic category (e.g., "Widgets", "State Management", "Local Storage").
  @HiveField(3)
  late String category;

  /// Phase / week number this lesson belongs to.
  @HiveField(4)
  late int phase;

  /// Technologies explicitly taught in this lesson.
  /// Used by AI system prompt as LESSON-CONTEXT.
  /// e.g., ["StatelessWidget", "StatefulWidget", "BuildContext"]
  @HiveField(5)
  late List<String> taughtTechnologies;

  /// Broader keywords for AI keyword-search matching.
  /// A superset of taughtTechnologies — includes related terms.
  /// e.g., ["widget", "build", "context", "tree", "immutable"]
  @HiveField(6)
  late List<String> searchKeywords;

  /// A concise paragraph summary of the lesson content.
  /// Injected into the AI system prompt for historical context.
  /// Keep under 200 words to stay within Gemini context limits.
  @HiveField(7)
  late String contentSummary;

  /// Whether the user has unlocked/completed this lesson.
  @HiveField(8)
  late bool isCompleted;

  /// ISO 8601 timestamp of when the lesson was completed. Null if not done.
  @HiveField(9)
  DateTime? completedAt;
}
