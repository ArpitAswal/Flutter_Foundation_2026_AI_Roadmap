import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/utils/curriculum_progress_utils.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/curriculum_bloc.dart';
import '../widgets/curriculum_progress_bar.dart';
import '../widgets/module_card_node.dart';
import '../widgets/tablet_module_grid.dart';

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
        final completedDays = completedDaysInPhase(
          phase,
          state.completedLessonIds,
        );
        final phaseProgress = phase.totalDays == 0
            ? 0.0
            : completedDays / phase.totalDays;

        String? currentTitle;
        for (int i = 0; i < phase.modules.length; i++) {
          final m = phase.modules[i];
          final isLocked = isModuleLockedAt(phase, i, state.completedLessonIds);
          final isCompleted = isModuleCompleted(
            phase,
            m,
            state.completedLessonIds,
          );
          if (!isLocked && !isCompleted) {
            currentTitle = m.title;
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
            title: Text(phase.title),
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
                StringConstants.modulesTitle,
                style: context.responsiveTextTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              Text(
                StringConstants.modulesSubtitle,
                style: context.responsiveTextTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: context.responsiveHeightSpace(0.02)),
              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    StringConstants.progressLabel,
                    style: context.responsiveTextTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${(phaseProgress * 100).toInt()}%',
                    style: context.responsiveTextTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CurriculumProgressBar(
                height: context.responsiveHeightSpace(0.008),
                fraction: phaseProgress,
                isCurrent: true, // Header progress always colored
              ),
              SizedBox(height: context.responsiveHeightSpace(0.02)),
              // Modules List
              context.isTablet &&
                      (Orientation.landscape ==
                          MediaQuery.of(context).orientation)
                  ? TabletModuleGrid(
                      phase: phase,
                      completed: state.completedLessonIds,
                    )
                  : Column(
                      children: phase.modules.asMap().entries.map((entry) {
                        final index = entry.key;
                        final module = entry.value;
                        final isLocked = isModuleLockedAt(
                          phase,
                          index,
                          state.completedLessonIds,
                        );
                        final isCompleted = isModuleCompleted(
                          phase,
                          module,
                          state.completedLessonIds,
                        );
                        final isCurrent = !isLocked && !isCompleted;

                        final completedModule = completedDaysInModule(
                          phase,
                          module,
                          state.completedLessonIds,
                        );

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: context.responsiveHeightSpace(0.02),
                          ),
                          child: ModuleCardNode(
                            phaseId: phase.id,
                            module: module,
                            isLocked: isLocked,
                            isCompleted: isCompleted,
                            isCurrent: isCurrent,
                            completedDays: completedModule,
                            isGridMode: false,
                          ),
                        );
                      }).toList(),
                    ),
            ],
          ),
          floatingActionButton: AiTutorFab(
            contextTitle: currentTitle ?? phase.title,
          ),
        );
      },
    );
  }
}
