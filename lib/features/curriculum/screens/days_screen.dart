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
import '../widgets/day_card_node.dart';
// Removed import

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
        if (state is CurriculumLoaded) {
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
              toolbarHeight: context.isTablet ? 90 : kToolbarHeight,
              leadingWidth: context.isTablet ? 90 : kToolbarHeight,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: colorScheme.onSurface,
                ),
                onPressed: () => context.pop(),
              ),
              title: Text(module.title, style: context.appBarTitleStyle),
              centerTitle: true,
            ),
            body: CurriculumListLayout(
              header: const CurriculumHeader(
                title: StringConstants.daysTitle,
                subtitle: StringConstants.daysSubtitle,
              ),
              maxGridColumns: 3,
              buildGrid: (context, columns) {
                return CurriculumGridBuilder(
                  itemCount: module.days.length,
                  crossAxisCount: columns,
                  itemBuilder: (context, index) {
                    final day = module.days[index];
                    final isLocked = isDayLockedAt(phase, module, index, state.completedLessonIds);
                    final isCompleted = isDayCompleted(phase, module, day, state.completedLessonIds);

                    return DayCardNode(
                      phaseId: phase.id,
                      moduleId: module.id,
                      day: day,
                      isLocked: isLocked,
                      isCompleted: isCompleted,
                      isCurrent: !isLocked && !isCompleted,
                      isGridMode: true,
                      onTap: () => (isLocked)
                          ? null
                          : context.pushNamed(
                              'lesson',
                              pathParameters: {
                                'phaseId': '${phase.id}',
                                'moduleId': '${module.id}',
                                'day': '${day.day}'
                              },
                            ),
                    );
                  },
                );
              },
              buildTimeline: (context) {
                return CurriculumTimeline(
                  nodeSize: DayCardNode.nodeSize,
                  children: module.days.asMap().entries.map<Widget>((entry) {
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
                    final isLast = index == module.days.length - 1;

                    return Padding(
                      padding: EdgeInsets.only(bottom: isLast ? 0.0 : 16.0),
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
                );
              },
            ),
            floatingActionButton: AiTutorFab(
              contextTitle: currentTitle ?? module.title,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
