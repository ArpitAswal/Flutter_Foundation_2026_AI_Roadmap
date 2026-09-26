import 'package:flutter/material.dart';

import '../../../core/utils/curriculum_progress_utils.dart';
import '../../../domain/models/curriculum/phase.dart';
import 'module_card_node.dart';

class TabletModuleGrid extends StatelessWidget {
  final Phase phase;
  final Set<String> completed;
  final int crossAxisCount;

  const TabletModuleGrid({
    super.key,
    required this.phase,
    required this.completed,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    // Break modules into rows according to crossAxisCount.
    // Using IntrinsicHeight ensures that all cards in a row are perfectly identical in height.
    final List<Widget> rows = [];
    final modulesList = phase.modules;

    for (int i = 0; i < modulesList.length; i += crossAxisCount) {
      final List<Widget> rowChildren = [];
      
      for (int j = 0; j < crossAxisCount; j++) {
        final moduleIndex = i + j;
        
        if (moduleIndex < modulesList.length) {
          final module = modulesList[moduleIndex];
          final isLocked = isModuleLockedAt(phase, moduleIndex, completed);
          
          rowChildren.add(
            Expanded(
              child: ModuleCardNode(
                phaseId: phase.id,
                module: module,
                isLocked: isLocked,
                isCompleted: isModuleCompleted(phase, module, completed),
                isCurrent: !isLocked && !isModuleCompleted(phase, module, completed),
                completedDays: completedDaysInModule(phase, module, completed),
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
