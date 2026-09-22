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

  /// Optional list of sub-lesson asset paths for multi-technique branching.
  /// When null or empty, the day has no sub-lessons.
  /// Example: ['assets/curriculum/phase3/module2/day29/getx.json']
  final List<String>? customRoute;

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

  /// Whether this day has sub-lesson branches.
  bool get hasSubLessons => customRoute != null && customRoute!.isNotEmpty;

  /// Extracts a human-readable label from a sub-lesson asset path.
  /// e.g. 'assets/curriculum/phase3/module2/day29/getx.json' → 'GetX'
  static String subLessonLabel(String path) {
    final fileName = path.split('/').last.replaceAll('.json', '');
    const specialCases = {
      'getx': 'GetX',
      'bloc': 'BLoC',
      'cubit': 'Cubit',
      'inherited_model': 'InheritedModel',
      'state_management_matrix': 'State Management Matrix',
    };
    if (specialCases.containsKey(fileName.toLowerCase())) {
      return specialCases[fileName.toLowerCase()]!;
    }
    return fileName
        .split('_')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  factory LessonDay.fromJson(Map<String, dynamic> json) {
    return LessonDay(
      phase: json['phase'] as int,
      module: json['module'] as int,
      day: json['day'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      tags: List<String>.from(json['tags'] as List),
      contentPath: json['content_path'] as String,
      customRoute: (json['custom_route'] as List?)
          ?.map((e) => e as String)
          .toList(),
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
