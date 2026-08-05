import 'package:equatable/equatable.dart';

/// Pure domain model for lesson content — all fields are optional except [theory].
///
/// Maps directly to the `content` object in each `dayN.json` file.
class LessonContent extends Equatable {
  final String prerequisites;
  final String theory;
  final String? codeInstruction;
  final String? comparisons;
  final String? optimization;
  final String? interviewQuestions;

  const LessonContent({
    required this.prerequisites,
    required this.theory,
    this.codeInstruction,
    this.comparisons,
    this.optimization,
    this.interviewQuestions,
  });

  factory LessonContent.fromJson(Map<String, dynamic> json) {
    return LessonContent(
      prerequisites: json['prerequisites'] as String? ?? '',
      theory: json['theory'] as String? ?? '',
      codeInstruction: json['code_instruction'] as String?,
      comparisons: json['comparisons'] as String?,
      optimization: json['optimization'] as String?,
      interviewQuestions: json['interview_questions'] as String?,
    );
  }

  /// Returns true if there is any "Deep Dives" section content to display.
  bool get hasDeepDives =>
      (comparisons != null && comparisons!.isNotEmpty) ||
      (optimization != null && optimization!.isNotEmpty) ||
      (interviewQuestions != null && interviewQuestions!.isNotEmpty);

  @override
  List<Object?> get props => [
        prerequisites,
        theory,
        codeInstruction,
        comparisons,
        optimization,
        interviewQuestions,
      ];
}
