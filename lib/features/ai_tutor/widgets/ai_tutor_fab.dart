import 'package:flutter/material.dart';
import '../../../domain/models/curriculum/lesson_content.dart';
import '../../../domain/models/curriculum/lesson_day.dart';
import 'ai_tutor_bottom_sheet.dart';

class AiTutorFab extends StatelessWidget {
  final String? contextTitle;
  final LessonDay? contextLesson;
  final LessonContent? contextContent;

  const AiTutorFab({
    super.key,
    this.contextTitle,
    this.contextLesson,
    this.contextContent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    void openBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AiTutorBottomSheet(
          contextTitle: contextTitle,
          contextLesson: contextLesson,
          contextContent: contextContent,
        ),
      );
    }

    return FloatingActionButton(
      onPressed: openBottomSheet,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onSecondary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.smart_toy_outlined),
    );
  }
}
