import '../../../domain/models/curriculum/lesson_module.dart';
import '../../../domain/models/curriculum/phase.dart';

/// Checks if a phase is locked based on its index in the phases list.
/// A phase is locked if the previous phase is not 100% completed.
bool isPhaseLockedAt(int index, List<Phase> phases, Set<String> completedIds) {
  if (index == 0) return false;
  final previousPhase = phases[index - 1];
  for (final module in previousPhase.modules) {
    for (var day = 1; day <= module.totalDays; day++) {
      final lessonId = 'p${previousPhase.id}_m${module.id}_d$day';
      if (!completedIds.contains(lessonId)) return true;
    }
  }
  return false;
}

/// Checks if a phase is 100% completed by verifying all its lesson days.
bool isPhaseCompleted(Phase phase, Set<String> completedIds) {
  for (final module in phase.modules) {
    for (var day = 1; day <= module.totalDays; day++) {
      final lessonId = 'p${phase.id}_m${module.id}_d$day';
      if (!completedIds.contains(lessonId)) return false;
    }
  }
  return true;
}

/// Calculates the number of completed days in a phase.
int completedDaysInPhase(Phase phase, Set<String> completedIds) {
  int count = 0;
  for (final module in phase.modules) {
    for (var day = 1; day <= module.totalDays; day++) {
      if (completedIds.contains('p${phase.id}_m${module.id}_d$day')) {
        count++;
      }
    }
  }
  return count;
}

/// Checks if a module is locked based on its index within a phase.
bool isModuleLockedAt(Phase phase, int moduleIndex, Set<String> completedIds) {
  if (moduleIndex == 0) {
    if (phase.id == 1) return false;
    // Should check previous phase completion, but simplified here
    return false;
  }
  final previousModule = phase.modules[moduleIndex - 1];
  for (var day = 1; day <= previousModule.totalDays; day++) {
    if (!completedIds.contains('p${phase.id}_m${previousModule.id}_d$day')) {
      return true;
    }
  }
  return false;
}

/// Checks if a module is completely finished.
bool isModuleCompleted(Phase phase, LessonModule module, Set<String> completedIds) {
  if (module.totalDays == 0) return false;
  for (var day = 1; day <= module.totalDays; day++) {
    if (!completedIds.contains('p${phase.id}_m${module.id}_d$day')) {
      return false;
    }
  }
  return true;
}

/// Calculates completed days for a specific module.
int completedDaysInModule(Phase phase, LessonModule module, Set<String> completedIds) {
  int count = 0;
  for (var day = 1; day <= module.totalDays; day++) {
    if (completedIds.contains('p${phase.id}_m${module.id}_d$day')) {
      count++;
    }
  }
  return count;
}
