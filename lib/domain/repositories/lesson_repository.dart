import '../models/lesson.dart';

/// Abstract repository interface for lesson data operations.
///
/// Ensures the domain layer remains decoupled from the specific
/// data source implementation (Hive, in this case).
abstract class LessonRepository {
  /// Retrieves a lesson by its unique curriculum ID.
  Future<Lesson?> getLessonById(String lessonId);

  /// Retrieves all lessons the user has marked as completed.
  Future<List<Lesson>> getCompletedLessons();

  /// Marks a specific lesson as completed.
  Future<void> markLessonComplete(String lessonId);
}
