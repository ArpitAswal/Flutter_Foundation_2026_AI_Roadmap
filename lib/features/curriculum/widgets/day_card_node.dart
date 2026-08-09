import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/string_constants.dart';
import '../../../domain/models/curriculum/lesson_day.dart';
import 'curriculum_card_node.dart';

class DayCardNode extends StatelessWidget {
  final int phaseId;
  final int moduleId;
  final LessonDay day;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback? onTap;

  const DayCardNode({
    super.key,
    required this.phaseId,
    required this.moduleId,
    required this.day,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    // Node
    Widget node;
    if (isCompleted) {
      node = Container(
        width: size.width * 0.09,
        height: size.width * 0.09,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.check_rounded,
          color: colorScheme.onPrimary,
          size: size.width * 0.05,
        ),
      );
    } else if (isCurrent) {
      node = Container(
        width: size.width * 0.09,
        height: size.width * 0.09,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow_outlined,
          color: colorScheme.onPrimary,
          size: size.width * 0.05,
        ),
      );
    } else {
      node = Container(
        width: size.width * 0.09,
        height: size.width * 0.09,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.outlineVariant, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.surfaceContainerHighest,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.lock_outline,
          color: colorScheme.outline.withValues(alpha: 0.5),
          size: size.width * 0.05,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        node,
        const SizedBox(width: 12),
        Expanded(
          child: CurriculumCard(
            isLocked: isLocked,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            onTap:
                onTap ??
                () {
                  context.goNamed(
                    'lesson',
                    pathParameters: {
                      'phaseId': '$phaseId',
                      'moduleId': '$moduleId',
                      'day': '${day.day}',
                    },
                  );
                },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          isCurrent
                              ? '${StringConstants.dayPrefix} ${day.day} • ${StringConstants.currentLabel}'
                              : '${StringConstants.dayPrefix} ${day.day}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isCurrent
                                ? colorScheme.secondaryContainer
                                : (isLocked
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.primary),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      if (!isLocked)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: isCompleted
                                ? colorScheme.primary
                                : colorScheme.secondaryContainer,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
