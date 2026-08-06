import '../../domain/models/curriculum/lesson_content.dart';
import '../../domain/models/curriculum/lesson_day.dart';
import '../../domain/models/curriculum/phase.dart';

/// Abstract repository interface for curriculum data.
///
/// Abstracts the data layer from the domain and presentation layers.
/// The implementation reads from local JSON asset files.
abstract class CurriculumRepository {
  /// Returns the full list of [Phase] objects from the curriculum skeleton index.
  /// Day content is NOT included — only titles, tags, and asset paths.
  Future<List<Phase>> getPhases();

  /// Returns the skeleton [LessonDay] for a specific lesson, identified by its
  /// [phase], [module], and [day] numbers.
  Future<LessonDay> getLessonDay({
    required int phase,
    required int module,
    required int day,
  });

  /// Lazily loads the full [LessonContent] from the day's individual asset file.
  ///
  /// [contentPath] is the value of [LessonDay.contentPath], e.g.
  /// `assets/curriculum/phase1/module1/day1.json`.
  Future<LessonContent> getDayContent(String contentPath);
}
