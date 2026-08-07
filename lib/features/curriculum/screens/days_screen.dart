import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/string_constants.dart';
import '../../../domain/models/curriculum/lesson_day.dart';
import '../../../domain/models/curriculum/lesson_module.dart';
import '../../../domain/models/curriculum/phase.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/curriculum_bloc.dart';
import '../widgets/curriculum_card_node.dart';

class DaysScreen extends StatelessWidget {
  final int phaseId;
  final int moduleId;

  const DaysScreen({super.key, required this.phaseId, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return _DaysView(phaseId: phaseId, moduleId: moduleId);
  }
}

class _DaysView extends StatelessWidget {
  final int phaseId;
  final int moduleId;

  const _DaysView({required this.phaseId, required this.moduleId});

  bool _isDayLockedAt(
    Phase phase,
    LessonModule module,
    int dayIndex,
    Set<String> completedIds,
  ) {
    if (dayIndex == 0) return false;
    final previousDay = module.days[dayIndex - 1];
    return !completedIds.contains(
      'p${phase.id}_m${module.id}_d${previousDay.day}',
    );
  }

  bool _isDayCompleted(
    Phase phase,
    LessonModule module,
    LessonDay day,
    Set<String> completedIds,
  ) {
    return completedIds.contains('p${phase.id}_m${module.id}_d${day.day}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<CurriculumBloc, CurriculumState>(
      builder: (context, state) {
        if (state is! CurriculumLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final phase = state.phases.firstWhere((p) => p.id == phaseId);
        final module = phase.modules.firstWhere((m) => m.id == moduleId);

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.onSurface,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(module.title),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            children: [
              // Header
              Text(
                StringConstants.daysTitle,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                StringConstants.daysSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Timeline
              Stack(
                children: [
                  Positioned(
                    left: 20,
                    top: 16,
                    bottom: 16,
                    width: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant.withAlpha(50),
                      ),
                    ),
                  ),
                  Column(
                    children: module.days.asMap().entries.map((entry) {
                      final index = entry.key;
                      final day = entry.value;
                      final isLocked = _isDayLockedAt(
                        phase,
                        module,
                        index,
                        state.completedLessonIds,
                      );
                      final isCompleted = _isDayCompleted(
                        phase,
                        module,
                        day,
                        state.completedLessonIds,
                      );
                      final isCurrent = !isLocked && !isCompleted;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _DayCardNode(
                          phaseId: phase.id,
                          moduleId: module.id,
                          day: day,
                          isLocked: isLocked,
                          isCompleted: isCompleted,
                          isCurrent: isCurrent,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
          floatingActionButton: const AiTutorFab(),
        );
      },
    );
  }
}

class _DayCardNode extends StatelessWidget {
  final int phaseId;
  final int moduleId;
  final LessonDay day;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;

  const _DayCardNode({
    required this.phaseId,
    required this.moduleId,
    required this.day,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Node
    Widget node;
    if (isCompleted) {
      node = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.check_rounded,
          color: colorScheme.onPrimary,
          size: 18,
        ),
      );
    } else if (isCurrent) {
      node = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow_outlined,
          color: colorScheme.onPrimary,
          size: 18,
        ),
      );
    } else {
      node = Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.outlineVariant, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.surfaceContainerHighest,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.lock_outline,
          color: colorScheme.outline.withValues(alpha: 0.5),
          size: 16,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        node,
        const SizedBox(width: 16),
        Expanded(
          child: CurriculumCard(
            isLocked: isLocked,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            onTap: () {
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
              padding: const EdgeInsets.all(20),
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
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.primary,
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
