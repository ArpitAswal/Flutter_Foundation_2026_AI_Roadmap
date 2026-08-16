import 'package:flutter/material.dart';

import '../../../core/utils/curriculum_progress_utils.dart';
import '../../../domain/models/curriculum/lesson_module.dart';
import '../../../domain/models/curriculum/phase.dart';
import 'day_card_node.dart';

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
    // Break days into rows of 2 for the tablet grid.
    final List<Widget> rows = [];
    final daysList = module.days;

    for (int i = 0; i < daysList.length; i += 2) {
      final firstDay = daysList[i];
      final firstIsLocked = isDayLockedAt(phase, module, i, completed);

      final secondExists = i + 1 < daysList.length;
      final secondDay = secondExists ? daysList[i + 1] : null;
      final secondIsLocked = secondExists
          ? isDayLockedAt(phase, module, i + 1, completed)
          : false;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DayCardNode(
                    phaseId: phase.id,
                    moduleId: module.id,
                    day: firstDay,
                    isLocked: firstIsLocked,
                    isCompleted: isDayCompleted(
                      phase,
                      module,
                      firstDay,
                      completed,
                    ),
                    isCurrent:
                        !firstIsLocked &&
                        !isDayCompleted(phase, module, firstDay, completed),
                    isGridMode: true,
                  ),
                ),
                const SizedBox(width: 16),
                if (secondExists)
                  Expanded(
                    child: DayCardNode(
                      phaseId: phase.id,
                      moduleId: module.id,
                      day: secondDay!,
                      isLocked: secondIsLocked,
                      isCompleted: isDayCompleted(
                        phase,
                        module,
                        secondDay,
                        completed,
                      ),
                      isCurrent:
                          !secondIsLocked &&
                          !isDayCompleted(phase, module, secondDay, completed),
                      isGridMode: true,
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}
