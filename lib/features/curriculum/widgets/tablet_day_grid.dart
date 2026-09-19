import 'package:flutter/material.dart';

import '../../../core/utils/curriculum_progress_utils.dart';
import '../../../domain/models/curriculum/lesson_module.dart';
import '../../../domain/models/curriculum/phase.dart';
import 'day_card_node.dart';

import '../../../core/utils/responsive_extension.dart';

class TabletDayGrid extends StatelessWidget {
  final Phase phase;
  final LessonModule module;
  final Set<String> completed;

  const TabletDayGrid({
    super.key,
    required this.phase,
    required this.module,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    // Break modules into rows of 1 for portrait tablet or 2 for landscape wide tablet.
    // Using IntrinsicHeight ensures that all cards in a row are perfectly identical in height.
    final int crossAxisCount = context.isWideTablet ? 2 : 1;
    final List<Widget> rows = [];
    final daysList = module.days;

    for (int i = 0; i < daysList.length; i += crossAxisCount) {
      final List<Widget> rowChildren = [];
      
      for (int j = 0; j < crossAxisCount; j++) {
        final dayIndex = i + j;
        
        if (dayIndex < daysList.length) {
          final day = daysList[dayIndex];
          final isLocked = isDayLockedAt(phase, module, dayIndex, completed);
          
          rowChildren.add(
            Expanded(
              child: DayCardNode(
                phaseId: phase.id,
                moduleId: module.id,
                day: day,
                isLocked: isLocked,
                isCompleted: isDayCompleted(phase, module, day, completed),
                isCurrent: !isLocked && !isDayCompleted(phase, module, day, completed),
                isGridMode: true,
              ),
            ),
          );
        } else {
          // Fill remaining space in the row
          rowChildren.add(const Spacer());
        }
        
        // Add spacing between columns, except after the last column
        if (j < crossAxisCount - 1) {
          rowChildren.add(const SizedBox(width: 16));
        }
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rowChildren,
            ),
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}
