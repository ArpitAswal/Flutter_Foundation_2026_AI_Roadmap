import 'package:flutter/material.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';
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
        constraints: BoxConstraints(
          maxWidth:
              (context.isTablet && context.orientation == Orientation.landscape)
              ? context.screenWidth * 0.75
              : double.infinity,
        ),
        builder: (_) => AiTutorBottomSheet(
          contextTitle: contextTitle,
          contextLesson: contextLesson,
          contextContent: contextContent,
        ),
      );
    }

    double fabSize;
    if (context.isTablet) {
      fabSize = (context.screenHeight * 0.1).clamp(60.0, 120.0);
    } else {
      fabSize = (context.screenWidth * 0.12).clamp(40.0, 60.0);
    }

    return SizedBox(
      width: fabSize,
      height: fabSize,
      child: FloatingActionButton(
        onPressed: openBottomSheet,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onSecondary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(fabSize * 0.25),
        ),
        child: Icon(Icons.smart_toy_outlined, size: fabSize * 0.7),
      ),
    );
  }
}
