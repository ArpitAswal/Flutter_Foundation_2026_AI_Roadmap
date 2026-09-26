import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';

import '../../../core/constants/asset_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../core/utils/curriculum_progress_utils.dart';
import '../../../domain/models/curriculum/phase.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/curriculum_bloc.dart';

import '../widgets/curriculum_header.dart';
import '../widgets/curriculum_layouts.dart';
import '../widgets/curriculum_state_views.dart';
import '../widgets/phase_card_node.dart';
import '../widgets/search_results_list.dart';
// Removed import

class PhasesScreen extends StatefulWidget {
  const PhasesScreen({super.key});

  @override
  State<PhasesScreen> createState() => _PhasesScreenState();
}

class _PhasesScreenState extends State<PhasesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  ValueNotifier<bool> isSearching = ValueNotifier(false);
  DateTime? _lastBackPressTime;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    isSearching.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  void _onSearchSubmit(String query) {
    if (query.isEmpty) {
      isSearching.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
          _lastBackPressTime = now;
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                StringConstants.doubleTapToExit,
                textAlign: TextAlign.center,
              ),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.fixed,
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor:
            theme.colorScheme.surface, // Matches surface-container-low
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          toolbarHeight: context.isTablet ? 90 : kToolbarHeight,
          leadingWidth: context.isTablet ? 90 : kToolbarHeight,
          leading: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  AssetConstants.logo,
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          title: ValueListenableBuilder(
            valueListenable: isSearching,
            builder: (BuildContext context, value, Widget? child) {
              return isSearching.value
                  ? Center(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onSubmitted: _onSearchSubmit,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          hintText: 'Search lessons by title or description...',
                          suffixIcon: null,
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      StringConstants.appName,
                      style: context.appBarTitleStyle,
                    );
            },
          ),
          actions: [
            ValueListenableBuilder(
              valueListenable: isSearching,
              builder: (BuildContext context, value, Widget? child) {
                return IconButton(
                  onPressed: () {
                    if (isSearching.value) {
                      _searchController.clear();
                      _onSearchChanged('');
                      isSearching.value = false;
                      _onSearchSubmit('');
                    } else {
                      isSearching.value = true;
                    }
                  },
                  icon: Icon(
                    isSearching.value
                        ? Icons.close_rounded
                        : Icons.manage_search_outlined,
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<CurriculumBloc, CurriculumState>(
          builder: (context, state) {
            if (state is CurriculumLoading) {
              return const CurriculumLoadingView();
            }
            if (state is CurriculumError) {
              return CurriculumErrorView(
                message: state.message,
                onRetry: () {
                  context.read<CurriculumBloc>().add(CurriculumLoadRequested());
                },
                showBackButton: true,
              );
            }
            if (state is CurriculumLoaded) {
              if (_searchQuery.isNotEmpty) {
                return SearchResultsList(
                  query: _searchQuery,
                  phases: state.phases,
                  completedIds: state.completedLessonIds,
                );
              }

              return _PhaseList(
                phases: state.phases,
                completedIds: state.completedLessonIds,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<CurriculumBloc, CurriculumState>(
          builder: (context, state) {
            if (state is CurriculumLoaded) {
              String? currentTitle;
              for (final phase in state.phases) {
                if (!isPhaseCompleted(phase, state.completedLessonIds)) {
                  currentTitle = phase.title;
                  break;
                }
              }
              return AiTutorFab(
                contextTitle: currentTitle ?? StringConstants.phasesTitle,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _PhaseList extends StatelessWidget {
  final List<Phase> phases;
  final Set<String> completedIds;

  const _PhaseList({required this.phases, required this.completedIds});

  @override
  Widget build(BuildContext context) {
    return CurriculumListLayout(
      header: const CurriculumHeader(
        title: StringConstants.phasesTitle,
        subtitle: StringConstants.phasesSubtitle,
      ),
      buildGrid: (context, columns) {
        return CurriculumGridBuilder(
          itemCount: phases.length,
          crossAxisCount: columns,
          itemBuilder: (context, index) {
            final phase = phases[index];
            final isLocked = isPhaseLockedAt(index, phases, completedIds);
            return PhaseCardNode(
              phase: phase,
              isLocked: isLocked,
              isCompleted: isPhaseCompleted(phase, completedIds),
              isCurrent: !isLocked && !isPhaseCompleted(phase, completedIds),
              completedModules: completedModulesInPhase(phase, completedIds),
              isGridMode: true,
            );
          },
        );
      },
      buildTimeline: (context) {
        return _buildTimelineList(context);
      },
    );
  }

  Widget _buildTimelineList(BuildContext context) {
    return CurriculumTimeline(
      nodeSize: PhaseCardNode.nodeSize,
      children: phases.asMap().entries.map((entry) {
        final index = entry.key;
        final phase = entry.value;
        final isLocked = isPhaseLockedAt(index, phases, completedIds);
        final isCompleted = isPhaseCompleted(phase, completedIds);
        final completedModules = completedModulesInPhase(
          phase,
          completedIds,
        );
        final isCurrent = !isLocked && !isCompleted;
        final isLast = index == phases.length - 1;

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0.0 : 16.0),
          child: PhaseCardNode(
            phase: phase,
            isLocked: isLocked,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            completedModules: completedModules,
            isGridMode: false,
          ),
        );
      }).toList(),
    );
  }
}
