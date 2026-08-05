import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/asset_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../core/di/injection.dart';
import '../../../domain/models/curriculum/phase.dart';
import '../bloc/curriculum_bloc.dart';

class PhasesScreen extends StatelessWidget {
  const PhasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CurriculumBloc>()..add(CurriculumLoadRequested()),
      child: const _PhasesView(),
    );
  }
}

class _PhasesView extends StatelessWidget {
  const _PhasesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Matches surface-container-low
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
          child: CircleAvatar(
            backgroundImage: AssetImage(AssetConstants.avatar),
          ),
        ),
        title: Text(
          StringConstants.appName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 24),
            icon: Icon(
              Icons.query_stats_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<CurriculumBloc, CurriculumState>(
        builder: (context, state) {
          if (state is CurriculumLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CurriculumError) {
            return Center(child: Text(state.message));
          }
          if (state is CurriculumLoaded) {
            return _PhaseList(
              phases: state.phases,
              completedIds: state.completedLessonIds,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PhaseList extends StatelessWidget {
  final List<Phase> phases;
  final Set<String> completedIds;

  const _PhaseList({required this.phases, required this.completedIds});

  bool _isPhaseLockedAt(int index) {
    if (index == 0) return false;
    final previousPhase = phases[index - 1];
    for (final module in previousPhase.modules) {
      for (var day = 1; day <= module.totalDays; day++) {
        final lessonId = 'p${previousPhase.id}_m${module.id}_d$day';
        if (!completedIds.contains(lessonId)) return true;
      }
    }
    return false;
  }

  bool _isPhaseCompleted(Phase phase) {
    for (final module in phase.modules) {
      for (var day = 1; day <= module.totalDays; day++) {
        final lessonId = 'p${phase.id}_m${module.id}_d$day';
        if (!completedIds.contains(lessonId)) return false;
      }
    }
    return true;
  }

  int _completedDaysInPhase(Phase phase) {
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

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      children: [
        Text(
          StringConstants.phasesTitle,
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontSize: 32,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          StringConstants.phasesSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        Stack(
          children: [
            // Vertical timeline line
            Positioned(
              left: 28,
              top: 16,
              bottom: 16,
              width: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Column(
              children: phases.asMap().entries.map((entry) {
                final index = entry.key;
                final phase = entry.value;
                final isLocked = _isPhaseLockedAt(index);
                final isCompleted = _isPhaseCompleted(phase);
                final completedDays = _completedDaysInPhase(phase);
                final isCurrent = !isLocked && !isCompleted;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: _PhaseCardNode(
                    phase: phase,
                    isLocked: isLocked,
                    isCompleted: isCompleted,
                    isCurrent: isCurrent,
                    completedDays: completedDays,
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

class _PhaseCardNode extends StatelessWidget {
  final Phase phase;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;
  final int completedDays;

  const _PhaseCardNode({
    required this.phase,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.completedDays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Timeline Node
    Widget node;
    if (isCompleted) {
      node = Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.surface, width: 4),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withAlpha(76),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.check_rounded,
          color: colorScheme.onPrimary,
          size: 28,
        ),
      );
    } else if (isCurrent) {
      node = Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.secondaryContainer, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
              blurRadius: 15,
            ),
          ],
        ),
        child: Icon(
          Icons.school_outlined,
          color: colorScheme.secondaryContainer,
          size: 28,
        ),
      );
    } else {
      node = Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.surface, width: 4),
        ),
        child: Icon(Icons.lock_rounded, color: colorScheme.outline, size: 28),
      );
    }

    // Card styling
    final cardDecoration = isCurrent
        ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.primary),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        node,
        const SizedBox(width: 16),
        Expanded(
          child: Opacity(
            opacity: isLocked ? 0.7 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${StringConstants.phasePrefix} ${phase.id}',
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
                      if (!isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? colorScheme.secondaryContainer.withAlpha(25)
                                : colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$completedDays/${phase.totalDays}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isCurrent
                                  ? colorScheme.secondaryContainer
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    phase.title,
                    style: theme.textTheme.titleLarge?.copyWith(
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
                        ? 'Unlock by completing Phase ${phase.id - 1}. ${phase.description}'
                        : phase.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isLocked
                          ? colorScheme.outline
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!isLocked) ...[
                    const SizedBox(height: 24),
                    _ProgressBar(
                      fraction: phase.totalDays == 0
                          ? 0.0
                          : completedDays / phase.totalDays,
                      isCurrent: isCurrent,
                    ),
                  ],
                  if (isCurrent) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.goNamed(
                        'modules',
                        pathParameters: {'phaseId': '${phase.id}'},
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text(
                        StringConstants.continueLearning,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                  if (isCompleted) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => context.goNamed(
                        'modules',
                        pathParameters: {'phaseId': '${phase.id}'},
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        StringConstants.reviewPhase,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double fraction;
  final bool isCurrent;

  const _ProgressBar({required this.fraction, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraction,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: isCurrent
                ? LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondaryContainer,
                    ],
                  )
                : null,
            color: isCurrent ? null : colorScheme.primary,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(128),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
