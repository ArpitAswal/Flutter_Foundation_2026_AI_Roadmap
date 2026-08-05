import 'package:equatable/equatable.dart';

import 'lesson_content.dart';

/// Pure domain model for a single learning day.
///
/// Maps directly to a `dayN.json` file in `assets/curriculum/`.
class LessonDay extends Equatable {
  final int phase;
  final int module;
  final int day;
  final String title;
  final String description;
  final List<String> tags;
  final LessonContent content;

  const LessonDay({
    required this.phase,
    required this.module,
    required this.day,
    required this.title,
    required this.description,
    required this.tags,
    required this.content,
  });

  /// Unique identifier for this lesson used in progress tracking.
  /// Format: "p{phase}_m{module}_d{day}" — e.g., "p1_m1_d1"
  String get lessonId => 'p${phase}_m${module}_d$day';

  /// Returns the first ~120 characters of the theory as a preview for the Days screen.
  String get theoryPreview {
    final plain = content.theory.replaceAll(RegExp(r'#{1,6}\s|[\*\_]'), '');
    return plain.length > 120 ? '${plain.substring(0, 120)}...' : plain;
  }

  factory LessonDay.fromJson(Map<String, dynamic> json) {
    return LessonDay(
      phase: json['phase'] as int,
      module: json['module'] as int,
      day: json['day'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      tags: List<String>.from(json['tags'] as List),
      content: LessonContent.fromJson(json['content'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => [phase, module, day, title, description, tags, content];
}
