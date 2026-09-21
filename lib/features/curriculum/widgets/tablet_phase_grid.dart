import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/curriculum_progress_utils.dart';
import '../../../domain/models/curriculum/phase.dart';
import 'phase_card_node.dart';

class TabletPhaseGrid extends StatelessWidget {
  final List<Phase> phasesList;
  final Set<String> completed;

  const TabletPhaseGrid({
    super.key,
    required this.phasesList,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    // Using IntrinsicHeight ensures that all cards in a row are perfectly identical in height.
    final int crossAxisCount = 2;
    final List<Widget> rows = [];

    for (int i = 0; i < phasesList.length; i += crossAxisCount) {
      final List<Widget> rowChildren = [];

      for (int j = 0; j < crossAxisCount; j++) {
        final phaseIndex = i + j;

        if (phaseIndex < phasesList.length) {
          final phase = phasesList[phaseIndex];
          final isLocked = isPhaseLockedAt(phaseIndex, phasesList, completed);

          rowChildren.add(
            Expanded(
              child: GestureDetector(
                onTap: () => (isLocked)
                    ? null
                    : context.goNamed(
                        'modules',
                        pathParameters: {'phaseId': '${phase.id}'},
                      ),
                child: PhaseCardNode(
                  phase: phase,
                  isLocked: isLocked,
                  isCompleted: isPhaseCompleted(phase, completed),
                  isCurrent: !isLocked && !isPhaseCompleted(phase, completed),
                  completedModules: completedModulesInPhase(phase, completed),
                  isGridMode: true,
                ),
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
          padding: const EdgeInsets.only(bottom: 32.0),
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
