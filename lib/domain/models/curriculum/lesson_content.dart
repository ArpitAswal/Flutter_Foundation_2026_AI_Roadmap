import 'package:equatable/equatable.dart';

/// Pure domain model for lesson content — all fields are optional except [theory].
///
/// Maps directly to the `content` object in each `dayN.json` file.
class LessonContent extends Equatable {
  final String prerequisites;
  final String theory;
  final String? lastUpdated;
  final String? implementation;
  final String? architecture;
  final String? comparisons;
  final String? optimization;
  final String? commonMistakes;
  final String? interviewQuestions;

  const LessonContent({
    required this.prerequisites,
    required this.theory,
    this.lastUpdated,
    this.implementation,
    this.architecture,
    this.comparisons,
    this.optimization,
    this.commonMistakes,
    this.interviewQuestions,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      prerequisites: json['prerequisites'] as String? ?? '',
      theory: json['theory'] as String? ?? '',
      lastUpdated: json['last_updated'] as String?,
      implementation: json['implementation'] as String?,
      architecture: json['architecture'] as String?,
      comparisons: json['comparisons'] as String?,
      optimization: json['optimization'] as String?,
      commonMistakes: json['common_mistakes'] as String?,
      interviewQuestions: json['interview_questions'] as String?,
    );
  }

  /// Returns true if there is any "Deep Dives" section content to display.
  bool get hasDeepDives =>
      (implementation != null && implementation!.isNotEmpty) ||
      (architecture != null && architecture!.isNotEmpty) ||
      (comparisons != null && comparisons!.isNotEmpty) ||
      (optimization != null && optimization!.isNotEmpty) ||
      (commonMistakes != null && commonMistakes!.isNotEmpty) ||
      (interviewQuestions != null && interviewQuestions!.isNotEmpty);

  @override
  List<Object?> get props => [
    prerequisites,
    theory,
    lastUpdated,
    implementation,
    architecture,
    comparisons,
    optimization,
    commonMistakes,
    interviewQuestions,
  ];
}
