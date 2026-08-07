import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/string_constants.dart';
import '../../../domain/models/curriculum/lesson_module.dart';
import '../../../domain/models/curriculum/phase.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/curriculum_bloc.dart';
import '../widgets/curriculum_card_node.dart';
import '../widgets/curriculum_progress_bar.dart';

class ModulesScreen extends StatelessWidget {
  final int phaseId;

  const ModulesScreen({super.key, required this.phaseId});

  @override
  Widget build(BuildContext context) {
    return _ModulesView(phaseId: phaseId);
  }
}

class _ModulesView extends StatelessWidget {
  final int phaseId;

  const _ModulesView({required this.phaseId});

  bool _isModuleLockedAt(
    Phase phase,
    int moduleIndex,
    Set<String> completedIds,
  ) {
    if (moduleIndex == 0) {
      if (phase.id == 1) return false;
      // Should check previous phase completion, but simplified here
      return false;
    }
    final previousModule = phase.modules[moduleIndex - 1];
    for (var day = 1; day <= previousModule.totalDays; day++) {
      if (!completedIds.contains('p${phase.id}_m${previousModule.id}_d$day')) {
        return true;
      }
    }
    return false;
  }

  bool _isModuleCompleted(
    Phase phase,
    LessonModule module,
    Set<String> completedIds,
  ) {
    if (module.totalDays == 0) return false;
    for (var day = 1; day <= module.totalDays; day++) {
      if (!completedIds.contains('p${phase.id}_m${module.id}_d$day')) {
        return false;
      }
    }
    return true;
  }

  int _completedDaysInModule(
    Phase phase,
    LessonModule module,
    Set<String> completedIds,
  ) {
    int count = 0;
    for (var day = 1; day <= module.totalDays; day++) {
      if (completedIds.contains('p${phase.id}_m${module.id}_d$day')) {
        count++;
      }
    }
    return count;
  }

  int _completedDaysInPhase(Phase phase, Set<String> completedIds) {
    int count = 0;
    for (final module in phase.modules) {
      count += _completedDaysInModule(phase, module, completedIds);
    }
    return count;
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
        final completedDays = _completedDaysInPhase(
          phase,
          state.completedLessonIds,
        );
        final phaseProgress = phase.totalDays == 0
            ? 0.0
            : completedDays / phase.totalDays;

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
            title: Text(phase.title),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            children: [
              // Header
              Text(
                StringConstants.modulesTitle,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              Text(
                StringConstants.modulesSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    StringConstants.progressLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(phaseProgress * 100).toInt()}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CurriculumProgressBar(
                fraction: phaseProgress,
                isCurrent: true, // Header progress always colored
              ),
              const SizedBox(height: 40),
              // Modules List
              ...phase.modules.asMap().entries.map((entry) {
                final index = entry.key;
                final module = entry.value;
                final isLocked = _isModuleLockedAt(
                  phase,
                  index,
                  state.completedLessonIds,
                );
                final isCompleted = _isModuleCompleted(
                  phase,
                  module,
                  state.completedLessonIds,
                );
                final isCurrent = !isLocked && !isCompleted;

                final completedDaysInModule = _completedDaysInModule(
                  phase,
                  module,
                  state.completedLessonIds,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ModuleCard(
                    phaseId: phase.id,
                    module: module,
                    isLocked: isLocked,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    completedDays: completedDaysInModule,
                  ),
                );
              }),
            ],
          ),
          floatingActionButton: const AiTutorFab(),
        );
      },
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final int phaseId;
  final LessonModule module;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;
  final int completedDays;

  const _ModuleCard({
    required this.phaseId,
    required this.module,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.completedDays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget icon;
    if (isCompleted) {
      icon = Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.check_rounded,
          color: colorScheme.onPrimary,
          size: 21,
        ),
      );
    } else if (isCurrent) {
      icon = Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow_outlined,
          color: colorScheme.onPrimary,
          size: 21,
        ),
      );
    } else {
      icon = Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.outlineVariant, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.surfaceContainerHighest,
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.lock_outline,
          color: colorScheme.outline.withValues(alpha: 0.5),
          size: 18,
        ),
      );
    }

    return CurriculumCard(
      isLocked: isLocked,
      isCompleted: isCompleted,
      isCurrent: isCurrent,
      onTap: () {
        context.goNamed(
          'days',
          pathParameters: {'phaseId': '$phaseId', 'moduleId': '${module.id}'},
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                icon,
                if (!isLocked) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? colorScheme.secondaryContainer.withAlpha(25)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$completedDays/${module.totalDays}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isCurrent
                            ? colorScheme.secondaryContainer
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${StringConstants.modulePrefix} ${module.id}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCurrent
                          ? colorScheme.secondaryContainer
                          : isLocked
                          ? colorScheme.outline
                          : colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    module.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLocked
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                      fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isLocked
                        ? 'Unlock by completing previous modules.'
                        : module.subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isLocked
                          ? colorScheme.outline
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!isLocked) ...[
                    const SizedBox(height: 20),
                    CurriculumProgressBar(
                      fraction: module.totalDays == 0
                          ? 0.0
                          : completedDays / module.totalDays,
                      isCurrent: isCurrent,
                      height: 6.0,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
