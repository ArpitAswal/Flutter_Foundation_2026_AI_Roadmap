import 'package:flutter/material.dart';
import 'package:flutter_foundation/core/utils/curriculum_progress_utils.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/curriculum/lesson_day.dart';
import '../../../domain/models/curriculum/phase.dart';
import 'day_card_node.dart';

class SearchResultItem {
  final int phaseId;
  final int moduleId;
  final LessonDay day;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;

  SearchResultItem({
    required this.phaseId,
    required this.moduleId,
    required this.day,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
  });
}

class SearchResultsList extends StatelessWidget {
  final String query;
  final List<Phase> phases;
  final Set<String> completedIds;

  const SearchResultsList({
    super.key,
    required this.query,
    required this.phases,
    required this.completedIds,
  });

  @override
  Widget build(BuildContext context) {
    final lowerQuery = query.toLowerCase();
    final List<SearchResultItem> results = [];
    final size = MediaQuery.of(context).size;

    for (final phase in phases) {
      for (int mIndex = 0; mIndex < phase.modules.length; mIndex++) {
        final module = phase.modules[mIndex];
        for (int dIndex = 0; dIndex < module.days.length; dIndex++) {
          final day = module.days[dIndex];
          if (day.title.toLowerCase().contains(lowerQuery) ||
              day.description.toLowerCase().contains(lowerQuery)) {
            // Calculate status
            final lessonId = 'p${phase.id}_m${module.id}_d${day.day}';
            final isCompleted = completedIds.contains(lessonId);

            // Use robust progress utilities instead of hardcoded day.day - 1 assumptions
            bool isLocked =
                isModuleLockedAt(phase, mIndex, completedIds) ||
                isDayLockedAt(phase, module, dIndex, completedIds);

            final isCurrent = !isLocked && !isCompleted;

            results.add(
              SearchResultItem(
                phaseId: phase.id,
                moduleId: module.id,
                day: day,
                isLocked: isLocked,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
              ),
            );
          }
        }
      }
    }

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No lessons found matching "$query"',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        Stack(
          children: [
            // Vertical timeline line
            Positioned(
              left: size.width * 0.04,
              top: 16,
              bottom: 20,
              width: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Column(
              children: results.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: DayCardNode(
                    phaseId: item.phaseId,
                    moduleId: item.moduleId,
                    day: item.day,
                    isLocked: item.isLocked,
                    isCompleted: item.isCompleted,
                    isCurrent: item.isCurrent,
                    onTap: () {
                      context.pushNamed(
                        'lesson',
                        pathParameters: {
                          'phaseId': '${item.phaseId}',
                          'moduleId': '${item.moduleId}',
                          'day': '${item.day.day}',
                        },
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}
