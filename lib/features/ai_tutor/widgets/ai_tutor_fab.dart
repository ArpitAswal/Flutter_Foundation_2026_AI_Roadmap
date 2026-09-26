import 'package:flutter/material.dart';

import '../../../core/utils/responsive_extension.dart';
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
    final fabSize = context.isTablet ? 64.0 : 44.0;

    void openBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints(maxWidth: 680.0),
        builder: (_) => SafeArea(
          child: AiTutorBottomSheet(
            contextTitle: contextTitle,
            contextLesson: contextLesson,
            contextContent: contextContent,
          ),
        ),
      );
    }

    return SizedBox(
      width: fabSize,
      height: fabSize,
      child: FloatingActionButton(
        heroTag: 'aiTutorFab',
        onPressed: openBottomSheet,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onSecondary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            context.isTablet ? 18 : 12
          ),
        ),
        child: Icon(Icons.smart_toy_outlined, size: context.isTablet ? 40 : 28),
      ),
    );
  }
}
