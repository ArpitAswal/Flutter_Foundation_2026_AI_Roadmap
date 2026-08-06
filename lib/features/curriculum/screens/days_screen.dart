import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/di/injection.dart';
import '../../../domain/models/curriculum/lesson_day.dart';
import '../../../domain/models/curriculum/lesson_module.dart';
import '../../../domain/models/curriculum/phase.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/curriculum_bloc.dart';

class DaysScreen extends StatelessWidget {
  final int phaseId;
  final int moduleId;

  const DaysScreen({super.key, required this.phaseId, required this.moduleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CurriculumBloc>()..add(CurriculumLoadRequested()),
      child: _DaysView(phaseId: phaseId, moduleId: moduleId),
    );
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
            backgroundColor: colorScheme.surface.withAlpha(200),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.onSurface,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              module.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
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
              const SizedBox(height: 40),
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
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.surface, width: 4),
        ),
        child: Icon(
          Icons.check_outlined,
          color: colorScheme.onPrimary,
          size: 20,
        ),
      );
    } else if (isCurrent) {
      node = Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.secondaryContainer, width: 3),
        ),
        child: Icon(
          Icons.play_arrow_outlined,
          color: colorScheme.secondaryContainer,
          size: 20,
        ),
      );
    } else {
      node = Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.surface, width: 4),
        ),
        child: Icon(Icons.lock_outline, color: colorScheme.outline, size: 16),
      );
    }

    final cardDecoration = isCurrent
        ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(51)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.secondaryContainer.withAlpha(25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          )
        : isCompleted
        ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(76)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(51)),
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        node,
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: isLocked
                ? null
                : () {
                    context.goNamed(
                      'lesson',
                      pathParameters: {
                        'phaseId': '$phaseId',
                        'moduleId': '$moduleId',
                        'day': '${day.day}',
                      },
                    );
                  },
            borderRadius: BorderRadius.circular(12),
            child: Opacity(
              opacity: isLocked ? 0.5 : 1.0,
              child: Container(
                decoration: cardDecoration,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Padding(
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
                                if (isCompleted)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      color: colorScheme.onSurfaceVariant,
                                      size: 20,
                                    ),
                                  )
                                else if (isCurrent)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      color: colorScheme.secondaryContainer,
                                      size: 20,
                                    ),
                                  )
                                else
                                  SizedBox.shrink(),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontFamily:
                                    GoogleFonts.hankenGrotesk().fontFamily,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              day.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrent)
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 4,
                            color: colorScheme.secondaryContainer,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
