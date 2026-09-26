import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/utils/curriculum_progress_utils.dart';
import '../../../core/utils/responsive_extension.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/curriculum_bloc.dart';
import '../widgets/curriculum_header.dart';
import '../widgets/curriculum_layouts.dart';
import '../widgets/curriculum_progress_bar.dart';
import '../widgets/module_card_node.dart';

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
        if (state is CurriculumLoaded) {
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
            final isLocked = isModuleLockedAt(
              phase,
              i,
              state.completedLessonIds,
            );
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
              toolbarHeight: context.isTablet ? 90 : kToolbarHeight,
              leadingWidth: context.isTablet ? 90 : kToolbarHeight,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: colorScheme.onSurface,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(phase.title, style: context.appBarTitleStyle),
              centerTitle: true,
            ),
            body: CurriculumListLayout(
              header: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CurriculumHeader(
                    title: StringConstants.modulesTitle,
                    subtitle: StringConstants.modulesSubtitle,
                  ),
                  const SizedBox(height: 20),
                  // Progress Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        StringConstants.progressLabel,
                        style: (context.isTablet
                                ? theme.textTheme.labelLarge
                                : theme.textTheme.labelSmall)
                            ?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                      ),
                      Text(
                        '${(phaseProgress * 100).toInt()}%',
                        style: (context.isTablet
                                ? theme.textTheme.labelLarge
                                : theme.textTheme.labelSmall)
                            ?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CurriculumProgressBar(
                    height: 8.0,
                    fraction: phaseProgress,
                    isCurrent: true,
                  ),
                ],
              ),
              buildGrid: (context, columns) {
                return CurriculumGridBuilder(
                  itemCount: phase.modules.length,
                  crossAxisCount: columns,
                  itemBuilder: (context, index) {
                    final module = phase.modules[index];
                    final isLocked = isModuleLockedAt(phase, index, state.completedLessonIds);
                    final isCompleted = isModuleCompleted(phase, module, state.completedLessonIds);

                    return ModuleCardNode(
                      phaseId: phase.id,
                      module: module,
                      isLocked: isLocked,
                      isCompleted: isCompleted,
                      isCurrent: !isLocked && !isCompleted,
                      completedDays: completedDaysInModule(phase, module, state.completedLessonIds),
                      isGridMode: true,
                    );
                  },
                );
              },
              buildTimeline: (context) {
                return CurriculumTimeline(
                  nodeSize: 36,
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
                    final isLast = index == phase.modules.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: isLast ? 0.0 : 16.0,
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
                );
              },
            ),
            floatingActionButton: AiTutorFab(
              contextTitle: currentTitle ?? phase.title,
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
