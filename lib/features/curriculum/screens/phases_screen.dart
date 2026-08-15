import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../core/constants/asset_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../core/utils/curriculum_progress_utils.dart';
import '../../../domain/models/curriculum/phase.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/curriculum_bloc.dart';

import '../widgets/phase_card_node.dart';
import '../widgets/search_results_list.dart';
import '../widgets/tablet_phase_grid.dart';

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
    final colorScheme = theme.colorScheme;

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
        backgroundColor: colorScheme.surface, // Matches surface-container-low
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          leadingWidth: context.isTablet ? 120.0 : 80.0,
          leading: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
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
              return (isSearching.value)
                  ? TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      onSubmitted: _onSearchSubmit,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                        ),
                        hintText: 'Search lessons by title or description...',
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                  _onSearchSubmit('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    )
                  : const Text(StringConstants.appName);
            },
          ),
          actions: [
            ValueListenableBuilder(
              valueListenable: isSearching,
              builder: (BuildContext context, value, Widget? child) {
                return (isSearching.value)
                    ? const SizedBox.shrink()
                    : IconButton(
                        onPressed: () {
                          isSearching.value = !isSearching.value;
                        },
                        icon: Icon(
                          Icons.manage_search_outlined,
                          color: Theme.of(context).primaryColor,
                          size: context.isTablet ? 40.0 : 32.0,
                        ),
                      );
              },
            ),
          ],
        ),
        body: BlocBuilder<CurriculumBloc, CurriculumState>(
          builder: (context, state) {
            if (state is CurriculumLoading) {
              return Center(
                child: SpinKitCircle(
                  color: Theme.of(context).colorScheme.primary,
                  size: 40.0,
                ),
              );
            }
            if (state is CurriculumError) {
              return Center(child: Text(state.message));
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
                bool isCompleted = true;
                for (final module in phase.modules) {
                  for (var day = 1; day <= module.totalDays; day++) {
                    if (!state.completedLessonIds.contains(
                      'p${phase.id}_m${module.id}_d$day',
                    )) {
                      isCompleted = false;
                      break;
                    }
                  }
                  if (!isCompleted) break;
                }
                if (!isCompleted) {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
        const SizedBox(height: 30),
        context.isTablet
            ? TabletPhaseGrid(phasesList: phases, completed: completedIds)
            : Stack(
                children: [
                  // Vertical timeline line
                  Positioned(
                    left: MediaQuery.of(context).size.width * 0.05,
                    top: 16,
                    bottom: 20,
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
                      final isLocked = isPhaseLockedAt(
                        index,
                        phases,
                        completedIds,
                      );
                      final isCompleted = isPhaseCompleted(phase, completedIds);
                      final completedDays = completedDaysInPhase(
                        phase,
                        completedIds,
                      );
                      final isCurrent = !isLocked && !isCompleted;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: PhaseCardNode(
                          phase: phase,
                          isLocked: isLocked,
                          isCompleted: isCompleted,
                          isCurrent: isCurrent,
                          completedDays: completedDays,
                          isGridMode: false,
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
