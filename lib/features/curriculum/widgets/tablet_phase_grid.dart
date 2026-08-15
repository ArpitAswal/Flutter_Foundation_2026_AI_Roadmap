import 'package:flutter/material.dart';

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
    // Break phases into rows of 2 for the tablet grid.
    // Using IntrinsicHeight ensures that both cards in a row are perfectly identical in height.
    final List<Widget> rows = [];
    for (int i = 0; i < phasesList.length; i += 2) {
      final firstPhase = phasesList[i];
      final firstIsLocked = isPhaseLockedAt(i, phasesList, completed);

      final secondExists = i + 1 < phasesList.length;
      final secondPhase = secondExists ? phasesList[i + 1] : null;
      final secondIsLocked = secondExists
          ? isPhaseLockedAt(i + 1, phasesList, completed)
          : false;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: PhaseCardNode(
                    phase: firstPhase,
                    isLocked: firstIsLocked,
                    isCompleted: isPhaseCompleted(firstPhase, completed),
                    isCurrent:
                        !firstIsLocked &&
                        !isPhaseCompleted(firstPhase, completed),
                    completedDays: completedDaysInPhase(firstPhase, completed),
                    isGridMode: true,
                  ),
                ),
                const SizedBox(width: 16),
                if (secondExists)
                  Expanded(
                    child: PhaseCardNode(
                      phase: secondPhase!,
                      isLocked: secondIsLocked,
                      isCompleted: isPhaseCompleted(secondPhase, completed),
                      isCurrent:
                          !secondIsLocked &&
                          !isPhaseCompleted(secondPhase, completed),
                      completedDays: completedDaysInPhase(
                        secondPhase,
                        completed,
                      ),
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
