import '../../domain/models/curriculum/lesson_day.dart';
import '../../domain/models/curriculum/phase.dart';

/// Abstract repository interface for curriculum data.
///
/// Abstracts the data layer from the domain and presentation layers.
/// The implementation reads from local JSON asset files.
abstract class CurriculumRepository {
  /// Returns the full list of [Phase] objects from the curriculum manifest.
  Future<List<Phase>> getPhases();

  /// Returns the [LessonDay] for a specific lesson, identified by its
  /// [phase], [module], and [day] numbers.
  ///
  /// The implementation locates the correct day file from the manifest
  /// and parses it on demand.
  Future<LessonDay> getLessonDay({
    required int phase,
    required int module,
    required int day,
  });
}
