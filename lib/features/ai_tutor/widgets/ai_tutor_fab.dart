import 'package:flutter/material.dart';
import '../../../domain/models/curriculum/lesson_day.dart';
import 'ai_tutor_bottom_sheet.dart';

class AiTutorFab extends StatelessWidget {
  final LessonDay? contextLesson;

  const AiTutorFab({super.key, this.contextLesson});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) =>
              AiTutorBottomSheet(contextLesson: contextLesson),
        );
      },
      backgroundColor: const Color(0xFF192252),
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.smart_toy_outlined),
    );
  }
}
