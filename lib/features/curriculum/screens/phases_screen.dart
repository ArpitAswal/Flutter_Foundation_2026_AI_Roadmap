import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/asset_constants.dart';
import '../../../core/constants/string_constants.dart';
import '../../../domain/models/curriculum/lesson_day.dart';
import '../../../domain/models/curriculum/phase.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/curriculum_bloc.dart';
import '../widgets/curriculum_card_node.dart';
import '../widgets/curriculum_progress_bar.dart';
import '../widgets/day_card_node.dart';

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

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
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

    return Scaffold(
      backgroundColor: colorScheme.surface, // Matches surface-container-low
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Image.asset(
            AssetConstants.avatar,
            filterQuality: FilterQuality.high,
            fit: BoxFit.contain,
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
                      fillColor: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                : Text(StringConstants.appName);
          },
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: isSearching,
            builder: (BuildContext context, value, Widget? child) {
              return (isSearching.value)
                  ? SizedBox.shrink()
                  : IconButton(
                      onPressed: () {
                        isSearching.value = !isSearching.value;
                      },
                      icon: Icon(
                        Icons.manage_search_outlined,
                        color: Theme.of(context).primaryColor,
                        size: 32,
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
              return _SearchResultsList(
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
          border: Border.all(color: colorScheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: Offset(0, 4),
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
          color: colorScheme.secondaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow_outlined,
          color: colorScheme.onPrimary,
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
          border: Border.all(color: colorScheme.outlineVariant, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.surfaceContainerHighest,
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.lock_outline,
          color: colorScheme.outline.withValues(alpha: 0.5),
          size: 28,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        node,
        const SizedBox(width: 16),
        Expanded(
          child: CurriculumCard(
            isLocked: isLocked,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
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
                    CurriculumProgressBar(
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

class _SearchResultItem {
  final int phaseId;
  final int moduleId;
  final LessonDay day;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;

  _SearchResultItem({
    required this.phaseId,
    required this.moduleId,
    required this.day,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
  });
}

class _SearchResultsList extends StatelessWidget {
  final String query;
  final List<Phase> phases;
  final Set<String> completedIds;

  const _SearchResultsList({
    required this.query,
    required this.phases,
    required this.completedIds,
  });

  @override
  Widget build(BuildContext context) {
    final lowerQuery = query.toLowerCase();
    final List<_SearchResultItem> results = [];

    for (final phase in phases) {
      for (int mIndex = 0; mIndex < phase.modules.length; mIndex++) {
        final module = phase.modules[mIndex];
        for (int dIndex = 0; dIndex < module.days.length; dIndex++) {
          final day = module.days[dIndex];
          if (day.title.toLowerCase().contains(lowerQuery) ||
              day.description.toLowerCase().contains(lowerQuery)) {
            // Calculate status
            final lessonId = 'p${phase.id}_m${module.id}_d${day.day}';
            final isCompleted = completedIds.contains(lessonId);

            // Simplified locked logic for search results:
            // In a linear curriculum, a lesson is locked if the PREVIOUS lesson is NOT completed.
            bool isLocked = false;
            if (phase.id == 1 && module.id == 1 && day.day == 1) {
              isLocked = false;
            } else {
              // Find previous lesson ID
              String prevLessonId = '';
              if (day.day > 1) {
                prevLessonId = 'p${phase.id}_m${module.id}_d${day.day - 1}';
              } else if (mIndex > 0) {
                final prevModule = phase.modules[mIndex - 1];
                prevLessonId =
                    'p${phase.id}_m${prevModule.id}_d${prevModule.totalDays}';
              } else if (phase.id > 1) {
                final prevPhase = phases.firstWhere(
                  (p) => p.id == phase.id - 1,
                );
                final prevModule = prevPhase.modules.last;
                prevLessonId =
                    'p${prevPhase.id}_m${prevModule.id}_d${prevModule.totalDays}';
              }
              isLocked =
                  prevLessonId.isNotEmpty &&
                  !completedIds.contains(prevLessonId);
            }

            final isCurrent = !isLocked && !isCompleted;

            results.add(
              _SearchResultItem(
                phaseId: phase.id,
                moduleId: module.id,
                day: day,
                isLocked: isLocked,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
              ),
            );
          }
        }
      }
    }

    if (results.isEmpty) {
      return Center(
        child: Text(
          'No lessons found matching "$query"',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        Stack(
          children: [
            // Vertical timeline line
            Positioned(
              left:
                  16, // Matches the center of the DayCardNode circle (width is 36, so center is roughly at 18)
              top: 16,
              bottom: 16,
              width: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Column(
              children: results.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: DayCardNode(
                    phaseId: item.phaseId,
                    moduleId: item.moduleId,
                    day: item.day,
                    isLocked: item.isLocked,
                    isCompleted: item.isCompleted,
                    isCurrent: item.isCurrent,
                    onTap: () {
                      context.pushNamed(
                        'lesson',
                        pathParameters: {
                          'phaseId': '${item.phaseId}',
                          'moduleId': '${item.moduleId}',
                          'day': '${item.day.day}',
                        },
                      );
                    },
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
