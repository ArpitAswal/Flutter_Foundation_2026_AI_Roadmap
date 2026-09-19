import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
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
            leadingWidth: context.isTablet ? 120.0 : 60.0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: colorScheme.onSurface,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(module.title,
              style: context.responsiveTextTheme.headlineMedium
                  ?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              )),
            centerTitle: true,
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: context.screenWidth * 0.03,
              vertical: context.screenHeight * 0.03,
            ),
            children: [
              // Header
              Text(
                StringConstants.daysTitle,
                style: context.responsiveTextTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                StringConstants.daysSubtitle,
                style: context.responsiveTextTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.responsiveHeightSpace(0.02)),

              // Content
              context.isTablet &&
                      (Orientation.landscape ==
                          MediaQuery.of(context).orientation)
                  ? TabletDayGrid(
                      phase: phase,
                      module: module,
                      completed: state.completedLessonIds,
                    )
                  : Stack(
                      children: [
                        Positioned(
                          left: context.screenWidth * 0.035,
                          top: 16,
                          bottom: context.responsiveHeightSpace(0.02),
                          width: context.isTablet ? 6 : 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.outlineVariant.withAlpha(50),
                              borderRadius: BorderRadius.circular(4),
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
                              padding: EdgeInsets.only(
                                bottom: context.responsiveHeightSpace(0.02),
                              ),
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
