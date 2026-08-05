import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/di/injection.dart';
import '../../../domain/models/curriculum/lesson_module.dart';
import '../../../domain/models/curriculum/phase.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/curriculum_bloc.dart';

class ModulesScreen extends StatelessWidget {
  final int phaseId;

  const ModulesScreen({super.key, required this.phaseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CurriculumBloc>()..add(CurriculumLoadRequested()),
      child: _ModulesView(phaseId: phaseId),
    );
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

  int _completedDaysInPhase(Phase phase, Set<String> completedIds) {
    int count = 0;
    for (final module in phase.modules) {
      for (var day = 1; day <= module.totalDays; day++) {
        if (completedIds.contains('p${phase.id}_m${module.id}_d$day')) {
          count++;
        }
      }
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
              phase.title,
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
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: phaseProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: colorScheme.primary,
                    ),
                  ),
                ),
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

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ModuleCard(
                    phaseId: phase.id,
                    module: module,
                    isLocked: isLocked,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
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

  const _ModuleCard({
    required this.phaseId,
    required this.module,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
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
          color: colorScheme.primary.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.check_circle_rounded, color: colorScheme.primary),
      );
    } else if (isCurrent) {
      icon = Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondaryContainer.withAlpha(100),
              blurRadius: 15,
            ),
          ],
        ),
        child: Icon(Icons.data_object_rounded, color: colorScheme.onSecondary),
      );
    } else {
      icon = Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.account_tree_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    final cardDecoration = isCurrent
        ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withAlpha(25),
                blurRadius: 25,
                offset: const Offset(0, 10),
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

    return InkWell(
      onTap: isLocked
          ? null
          : () {
              context.goNamed(
                'days',
                pathParameters: {
                  'phaseId': '$phaseId',
                  'moduleId': '${module.id}',
                },
              );
            },
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: isLocked ? 0.75 : 1.0,
        child: Container(
          decoration: cardDecoration,
          child: Stack(
            children: [
              if (isCompleted)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    icon,
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCurrent
                                ? '${StringConstants.modulePrefix} ${module.id} • ${StringConstants.currentLabel}'
                                : '${StringConstants.modulePrefix} ${module.id}',
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
                          const SizedBox(height: 4),
                          Text(
                            module.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              fontFamily:
                                  GoogleFonts.hankenGrotesk().fontFamily,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            module.subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      isLocked
                          ? Icons.lock_rounded
                          : Icons.chevron_right_rounded,
                      color: isCurrent
                          ? colorScheme.primary
                          : (isLocked
                                ? colorScheme.onSurfaceVariant.withAlpha(128)
                                : colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
