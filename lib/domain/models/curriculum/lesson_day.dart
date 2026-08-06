import 'package:equatable/equatable.dart';

/// Pure domain model for a single learning day — skeleton only.
///
/// Heavy content (theory, implementation, etc.) is loaded on demand from
/// [contentPath] via [CurriculumLocalDataSource.getDayContent].
class LessonDay extends Equatable {
  final int phase;
  final int module;
  final int day;
  final String title;
  final String description;
  final List<String> tags;

  /// Asset path to the per-day JSON file, e.g.
  /// `assets/curriculum/phase1/module1/day1.json`.
  final String contentPath;

  /// Optional named route for fully custom interactive screens.
  /// When null the generic [LessonScreen] is used instead.
  final String? customRoute;

  const LessonDay({
    required this.phase,
    required this.module,
    required this.day,
    required this.title,
    required this.description,
    required this.tags,
    required this.contentPath,
    this.customRoute,
  });

  /// Unique identifier for this lesson used in progress tracking.
  /// Format: "p{phase}_m{module}_d{day}" — e.g., "p1_m1_d1"
  String get lessonId => 'p${phase}_m${module}_d$day';

  factory LessonDay.fromJson(Map<String, dynamic> json) {
    return LessonDay(
      phase: json['phase'] as int,
      module: json['module'] as int,
      day: json['day'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      tags: List<String>.from(json['tags'] as List),
      contentPath: json['content_path'] as String,
      customRoute: json['custom_route'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    module,
    day,
    title,
    description,
    tags,
    contentPath,
    customRoute,
  ];
}
