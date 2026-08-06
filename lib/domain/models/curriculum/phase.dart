import 'package:equatable/equatable.dart';

import 'lesson_module.dart';

/// Pure domain model for a curriculum Phase (a collection of Modules).
class Phase extends Equatable {
  final int id;
  final String title;
  final String description;
  final List<LessonModule> modules;

  const Phase({
    required this.id,
    required this.title,
    required this.description,
    required this.modules,
  });

  /// Total number of days across all modules in this phase.
  int get totalDays => modules.fold(0, (sum, m) => sum + m.totalDays);

  factory Phase.fromJson(Map<String, dynamic> json) {
    final moduleList = (json['modules'] as List)
        .map((m) => LessonModule.fromJson(m as Map<String, dynamic>))
        .toList();
    return Phase(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      modules: moduleList,
    );
  }

  @override
  List<Object?> get props => [id, title, description, modules];
}
