import 'package:flutter/material.dart';

import '../../../core/utils/curriculum_progress_utils.dart';
import '../../../domain/models/curriculum/phase.dart';
import 'module_card_node.dart';

class TabletModuleGrid extends StatelessWidget {
  final Phase phase;
  final Set<String> completed;

  const TabletModuleGrid({
    super.key,
    required this.phase,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    // Break modules into rows of 2 for the tablet grid.
    // Using IntrinsicHeight ensures that both cards in a row are perfectly identical in height.
    final List<Widget> rows = [];
    final modulesList = phase.modules;

    for (int i = 0; i < modulesList.length; i += 2) {
      final firstModule = modulesList[i];
      final firstIsLocked = isModuleLockedAt(phase, i, completed);

      final secondExists = i + 1 < modulesList.length;
      final secondModule = secondExists ? modulesList[i + 1] : null;
      final secondIsLocked = secondExists
          ? isModuleLockedAt(phase, i + 1, completed)
          : false;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ModuleCardNode(
                    phaseId: phase.id,
                    module: firstModule,
                    isLocked: firstIsLocked,
                    isCompleted: isModuleCompleted(
                      phase,
                      firstModule,
                      completed,
                    ),
                    isCurrent:
                        !firstIsLocked &&
                        !isModuleCompleted(phase, firstModule, completed),
                    completedDays: completedDaysInModule(
                      phase,
                      firstModule,
                      completed,
                    ),
                    isGridMode: true,
                  ),
                ),
                const SizedBox(width: 16),
                if (secondExists)
                  Expanded(
                    child: ModuleCardNode(
                      phaseId: phase.id,
                      module: secondModule!,
                      isLocked: secondIsLocked,
                      isCompleted: isModuleCompleted(
                        phase,
                        secondModule,
                        completed,
                      ),
                      isCurrent:
                          !secondIsLocked &&
                          !isModuleCompleted(phase, secondModule, completed),
                      completedDays: completedDaysInModule(
                        phase,
                        secondModule,
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
