import 'package:equatable/equatable.dart';

import 'lesson_day.dart';

/// Pure domain model for a curriculum Module (a group of days within a Phase).
class LessonModule extends Equatable {
  final int id;
  final String title;
  final String subtitle;

  /// Lesson days belonging to this module.
  final List<LessonDay> days;

  const LessonModule({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.days,
  });

  /// Total number of days in this module.
  int get totalDays => days.length;

  factory LessonModule.fromJson(Map<String, dynamic> json) {
    return LessonModule(
      id: json['id'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      days: (json['days'] as List)
          .map((d) => LessonDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, title, subtitle, days];
}

/// A [LessonModule] enriched with its actual [LessonDay] content and lock state.
///
/// Computed at runtime by combining manifest data with Hive progress.
class LessonModuleWithDays extends Equatable {
  final LessonModule module;
  final List<LessonDay> days;

  /// How many days in this module the user has completed.
  final int completedDayCount;

  const LessonModuleWithDays({
    required this.module,
    required this.days,
    required this.completedDayCount,
  });

  bool get isComplete => completedDayCount >= module.totalDays;
  bool get isLocked => false; // computed externally based on previous module completion
  double get progressFraction =>
      module.totalDays == 0 ? 0.0 : completedDayCount / module.totalDays;

  @override
  List<Object?> get props => [module, days, completedDayCount];
}
