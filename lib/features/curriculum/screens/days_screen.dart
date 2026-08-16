import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/utils/curriculum_progress_utils.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/curriculum_bloc.dart';
import '../widgets/day_card_node.dart';
import '../widgets/tablet_day_grid.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<CurriculumBloc, CurriculumState>(
      builder: (context, state) {
        if (state is! CurriculumLoaded) {
          return Scaffold(
            body: Center(
              child: SpinKitCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 40.0,
              ),
            ),
          );
        }

        final phase = state.phases.firstWhere((p) => p.id == phaseId);
        final module = phase.modules.firstWhere((m) => m.id == moduleId);

        String? currentTitle;
        for (int i = 0; i < module.days.length; i++) {
          final d = module.days[i];
          final isLocked = isDayLockedAt(
            phase,
            module,
            i,
            state.completedLessonIds,
          );
          final isCompleted = isDayCompleted(
            phase,
            module,
            d,
            state.completedLessonIds,
          );
          if (!isLocked && !isCompleted) {
            currentTitle = d.title;
            break;
          }
        }

        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.onSurface,
                size: context.screenWidth * (context.isTablet ? 0.03 : 0.06),
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

              // Content
              context.isTablet
                  ? TabletDayGrid(
                      phase: phase,
                      module: module,
                      completed: state.completedLessonIds,
                    )
                  : Stack(
                      children: [
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.04,
                          top: 16,
                          bottom: 20,
                          width: 4,
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
                            final isLocked = isDayLockedAt(
                              phase,
                              module,
                              index,
                              state.completedLessonIds,
                            );
                            final isCompleted = isDayCompleted(
                              phase,
                              module,
                              day,
                              state.completedLessonIds,
                            );
                            final isCurrent = !isLocked && !isCompleted;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: DayCardNode(
                                phaseId: phase.id,
                                moduleId: module.id,
                                day: day,
                                isLocked: isLocked,
                                isCompleted: isCompleted,
                                isCurrent: isCurrent,
                                isGridMode: false,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
            ],
          ),
          floatingActionButton: AiTutorFab(
            contextTitle: currentTitle ?? module.title,
          ),
        );
      },
    );
  }
}
