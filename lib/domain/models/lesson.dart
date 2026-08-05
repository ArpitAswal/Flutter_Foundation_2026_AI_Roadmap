import 'package:equatable/equatable.dart';
import '../../data/local/models/lesson_record.dart';

/// Pure domain representation of a Lesson.
///
/// Stripped of all Hive database annotations, this model is safe to pass
/// into Blocs and presentation layers.
class Lesson extends Equatable {
  final String id;
  final String title;
  final int dayNumber;
  final String category;
  final int phase;
  final List<String> taughtTechnologies;
  final String contentSummary;
  final bool isCompleted;
  final DateTime? completedAt;

  const Lesson({
    required this.id,
    required this.title,
    required this.dayNumber,
    required this.category,
    required this.phase,
    required this.taughtTechnologies,
    required this.contentSummary,
    required this.isCompleted,
    this.completedAt,
  });

  @override
  List<Object?> get props => [
    id, title, dayNumber, category, phase, 
    taughtTechnologies, contentSummary, isCompleted, completedAt
  ];
}

/// Extension mapping the Hive data model to the pure domain model.
extension LessonRecordX on LessonRecord {
  Lesson toDomain() {
    return Lesson(
      id: lessonId,
      title: title,
      dayNumber: dayNumber,
      category: category,
      phase: phase,
      taughtTechnologies: taughtTechnologies,
      contentSummary: contentSummary,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
  }
}
