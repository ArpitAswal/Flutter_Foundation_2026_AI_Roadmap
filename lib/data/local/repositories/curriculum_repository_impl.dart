import 'package:injectable/injectable.dart';

import '../../../domain/models/curriculum/lesson_day.dart';
import '../../../domain/models/curriculum/phase.dart';
import '../../../domain/repositories/curriculum_repository.dart';
import '../sources/curriculum_local_data_source.dart';

/// Concrete implementation of [CurriculumRepository].
///
/// Loads all curriculum data from bundled JSON assets via [CurriculumLocalDataSource].
@Injectable(as: CurriculumRepository)
class CurriculumRepositoryImpl implements CurriculumRepository {
  final CurriculumLocalDataSource _dataSource;

  const CurriculumRepositoryImpl(this._dataSource);

  @override
  Future<List<Phase>> getPhases() {
    return _dataSource.getCurriculumIndex();
  }

  @override
  Future<LessonDay> getLessonDay({
    required int phase,
    required int module,
    required int day,
  }) async {
    // Load the manifest to find the correct day file name.
    final phases = await _dataSource.getCurriculumIndex();

    final targetPhase = phases.where((p) => p.id == phase).firstOrNull;
    if (targetPhase == null) {
      throw ArgumentError('Phase $phase not found in manifest.');
    }

    final targetModule = targetPhase.modules
        .where((m) => m.id == module)
        .firstOrNull;
    if (targetModule == null) {
      throw ArgumentError('Module $module not found in phase $phase.');
    }

    // Days are ordered — day 1 maps to index 0.
    final dayIndex = day - 1;
    if (dayIndex < 0 || dayIndex >= targetModule.days.length) {
      throw ArgumentError(
        'Day $day not found in module $module of phase $phase.',
      );
    }

    return targetModule.days[dayIndex];
  }
}
