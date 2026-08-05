import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/app_exception.dart';
import '../models/lesson_record.dart';

/// Local data source for accessing and querying lessons stored in Hive.
@singleton
class LessonLocalDataSource {
  /// Opens the Hive box securely using dependency injection via singleton initialization.
  Box<LessonRecord> get _box => Hive.box<LessonRecord>(AppConstants.lessonsBox);

  /// Saves or updates a lesson record in the database.
  Future<void> saveLesson(LessonRecord lesson) async {
    try {
      await _box.put(lesson.lessonId, lesson);
    } catch (e) {
      throw DatabaseException('Failed to save lesson: ${lesson.lessonId}', e);
    }
  }

  /// Retrieves a lesson by its unique curriculum ID.
  Future<LessonRecord?> getLessonById(String lessonId) async {
    try {
      return _box.get(lessonId);
    } catch (e) {
      throw DatabaseException('Failed to get lesson: $lessonId', e);
    }
  }

  /// Retrieves all lessons the user has marked as completed.
  Future<List<LessonRecord>> getCompletedLessons() async {
    try {
      return _box.values.where((lesson) => lesson.isCompleted).toList();
    } catch (e) {
      throw DatabaseException('Failed to fetch completed lessons', e);
    }
  }

  /// Filters completed lessons by searching their `searchKeywords` against the provided [keywords].
  ///
  /// This is used heavily by the AI Context Pipeline to inject historical knowledge
  /// based on the user's current question.
  Future<List<LessonRecord>> searchByKeywords(List<String> keywords) async {
    try {
      if (keywords.isEmpty) return [];

      final lowerKeywords = keywords.map((k) => k.toLowerCase()).toSet();
      
      final matchingLessons = _box.values.where((lesson) {
        if (!lesson.isCompleted) return false;

        // Check if any extracted keyword matches any keyword in the lesson's search scope.
        return lesson.searchKeywords.any((lessonKw) => 
            lowerKeywords.contains(lessonKw.toLowerCase()));
      }).toList();

      // Sort by dayNumber descending (most recent first) and cap at max configured limit.
      matchingLessons.sort((a, b) => b.dayNumber.compareTo(a.dayNumber));
      
      return matchingLessons.take(AppConstants.maxHistoricalLessons).toList();
    } catch (e) {
      throw DatabaseException('Failed to search lessons by keywords', e);
    }
  }

  /// Marks a specific lesson as completed.
  Future<void> markLessonComplete(String lessonId) async {
    try {
      final lesson = await getLessonById(lessonId);
      if (lesson != null) {
        lesson.isCompleted = true;
        lesson.completedAt = DateTime.now();
        await lesson.save();
      }
    } catch (e) {
      throw DatabaseException('Failed to mark lesson as complete: $lessonId', e);
    }
  }
}
