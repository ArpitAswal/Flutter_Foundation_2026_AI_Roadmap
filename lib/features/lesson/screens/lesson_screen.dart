import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/responsive_extension.dart';
import '../../../domain/models/curriculum/lesson_content.dart';
import '../../../domain/models/curriculum/lesson_day.dart';
import '../../../shared/widgets/expandable_widget.dart';
import '../../../shared/widgets/code_block_widget.dart';
import '../../../shared/widgets/code_element_builder.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/lesson_bloc.dart';
import '../../curriculum/bloc/curriculum_bloc.dart';
import '../../curriculum/widgets/curriculum_state_views.dart';

/// Renders the full content of a single lesson day.
///
/// Content sections rendered in order:
/// 1. Prerequisites & Tags — info card and bubbles
/// 2. Theory — Markdown rendered body
/// 3. Code Instruction — [CodeBlockWidget] (if present)
/// 4. Architecture — [ExpandableWidget] (if present)
/// 5. Comparisons — [ExpandableWidget]
/// 6. Optimization — [ExpandableWidget]
/// 7. Common Mistakes — [ExpandableWidget]
/// 8. Interview Questions — [ExpandableWidget]
/// 9. Mark as Complete button

class LessonScreen extends StatelessWidget {
  final int phaseId;
  final int moduleId;
  final int day;

  const LessonScreen({
    super.key,
    required this.phaseId,
    required this.moduleId,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LessonBloc>()
        ..add(LessonLoadRequested(phase: phaseId, module: moduleId, day: day)),
      child: ScaffoldMessenger(
        child: _LessonView(phaseId: phaseId, moduleId: moduleId, dayID: day),
      ),
    );
  }
}

class _LessonView extends StatelessWidget {
  final int phaseId;
  final int moduleId;
  final int dayID;

  const _LessonView({
    required this.phaseId,
    required this.moduleId,
    required this.dayID,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LessonBloc, LessonState>(
      listener: (context, state) {
        if (state is LessonLoaded) {
          // Sync global curriculum state AFTER the local hive db has been updated
          context.read<CurriculumBloc>().add(CurriculumLoadRequested());
        }
      },
      builder: (context, state) {
        if (state is LessonLoading) {
          return const Scaffold(
            body: CurriculumLoadingView(
              message: StringConstants.preparingLesson,
            ),
          );
        }
        if (state is LessonError) {
          return Scaffold(
            body: CurriculumErrorView(
              title: StringConstants.lessonUnavailable,
              message: StringConstants.lessonErrorApology,
              showBackButton: true,
              onRetry: () {
                context.read<LessonBloc>().add(
                  LessonLoadRequested(
                    phase: phaseId,
                    module: moduleId,
                    day: dayID,
                    again: true,
                  ),
                );
              },
            ),
          );
        }
        if (state is LessonLoaded) {
          return _LessonContent(
            lesson: state.lesson,
            content: state.content,
            isComplete: state.isComplete,
          );
        }
        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }
}

// Removed _LessonLoadingView and _LessonErrorView

class _LessonContent extends StatefulWidget {
  final LessonDay lesson;
  final LessonContent content;
  final bool isComplete;

  const _LessonContent({
    required this.lesson,
    required this.content,
    required this.isComplete,
  });

  @override
  State<_LessonContent> createState() => _LessonContentState();
}

class _LessonContentState extends State<_LessonContent> {
  String? _expandedTitle;
  bool _isTransitioning = true;
  late final ScrollController _scrollController;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 400 && !_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      } else if (_scrollController.offset <= 400 && _showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    });

    // Delay rendering heavy Markdown content until route transition finishes
    // to prevent screen freeze/stutter during navigation.
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          _isTransitioning = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleExpansion(String title, bool isExpanded) {
    setState(() {
      if (isExpanded) {
        _expandedTitle = title;
      } else if (_expandedTitle == title) {
        _expandedTitle = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isTransitioning) {
      return const Scaffold(
        body: CurriculumLoadingView(
          message: StringConstants.preparingLesson,
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          theme.colorScheme.surface, // Matches surface-container-low
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        toolbarHeight: context.isTablet ? 90 : kToolbarHeight,
        leadingWidth: context.isTablet ? 90 : kToolbarHeight,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.lesson.title, style: context.appBarTitleStyle),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = context.screenWidth * 0.05;

          return Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: context.isTablet ? 24 : 16,
                  ),
                  children: [
                    // ── Lesson Title ────────────────────────────────────────────────────
                    Text(
                      widget.lesson.title,
                      style:
                          (context.isTablet
                                  ? theme.textTheme.headlineMedium
                                  : theme.textTheme.titleLarge)
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                    ),

                    // ── Last Updated Date Metadata ─────────────────────────────────────
                    if (widget.content.lastUpdated != null &&
                        widget.content.lastUpdated!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.history_rounded,
                            color: colorScheme.onSurfaceVariant,
                            size: context.subDescriptionStyle.fontSize,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              '${StringConstants.lastUpdated} ${widget.content.lastUpdated}',
                              style: context.subDescriptionStyle.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // ── Tags ─────────────────────────────────────────────────────────────
                    if (widget.lesson.tags.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.lesson.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(
                                  alpha: 0.6,
                                ),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Text(
                                tag,
                                style: context.subDescriptionStyle.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    // ── Sub-Lesson Navigation Section ─────────────────────────────
                    if (widget.lesson.hasSubLessons) ...[
                      const SizedBox(height: 16),
                      _SubLessonNavigationSection(
                        lesson: widget.lesson,
                        subLessonPaths: widget.lesson.customRoute!,
                      ),
                    ],

                    // ── Prerequisites ────────────────────────────────────────────────────
                    _PrerequisitesCard(
                      prerequisites: widget.content.prerequisites,
                    ),

                    // ── Theory (Markdown) ─────────────────────────────────────────────
                    MarkdownBody(
                      data: widget.content.theory,
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        p:
                            (context.isTablet
                                    ? theme.textTheme.bodyLarge
                                    : theme.textTheme.bodySmall)
                                ?.copyWith(height: 1.7),

                        h1Padding: const EdgeInsets.only(top: 16),
                        h1: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                        h2Padding: const EdgeInsets.only(top: 16),
                        h2:
                            (context.isTablet
                                    ? theme.textTheme.titleLarge
                                    : theme.textTheme.titleMedium)
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                ),
                        h3Padding: const EdgeInsets.only(top: 16),
                        h3:
                            (context.isTablet
                                    ? theme.textTheme.titleMedium
                                    : theme.textTheme.titleSmall)
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                        blockSpacing: 12,
                        a: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                        // This targets inline code wrapped in single backticks (e.g., `int`)
                        code:
                            (context.isTablet
                                    ? theme.textTheme.bodyLarge
                                    : theme.textTheme.bodySmall)
                                ?.copyWith(
                                  color: Colors
                                      .black, // High contrast for Light Theme
                                  backgroundColor: Colors
                                      .grey
                                      .shade200, // Very subtle gray background
                                  fontFamily:
                                      'monospace', // Keeps the developer aesthetic
                                ),
                      ),
                      builders: {'pre': CodeElementBuilder(context)},
                    ),

                    // ── Additional Sections (Accordions) ─────────────────────────────────
                    if (widget.content.hasDeepDives) ...[
                      const SizedBox(height: 32),

                      if (widget.content.implementation != null &&
                          widget.content.implementation!.isNotEmpty)
                        ExpandableWidget(
                          title: 'Implementation',
                          markdownContent: widget.content.implementation!,
                          isExpanded: _expandedTitle == 'Implementation',
                          onExpansionChanged: (exp) =>
                              _handleExpansion('Implementation', exp),
                        ),
                      if (widget.content.architecture != null &&
                          widget.content.architecture!.isNotEmpty)
                        ExpandableWidget(
                          title: 'Architecture',
                          markdownContent: widget.content.architecture!,
                          isExpanded: _expandedTitle == 'Architecture',
                          onExpansionChanged: (exp) =>
                              _handleExpansion('Architecture', exp),
                        ),
                      if (widget.content.comparisons != null &&
                          widget.content.comparisons!.isNotEmpty)
                        ExpandableWidget(
                          title: 'Comparisons',
                          markdownContent: widget.content.comparisons!,
                          isExpanded: _expandedTitle == 'Comparisons',
                          onExpansionChanged: (exp) =>
                              _handleExpansion('Comparisons', exp),
                        ),
                      if (widget.content.optimization != null &&
                          widget.content.optimization!.isNotEmpty)
                        ExpandableWidget(
                          title: 'Optimization',
                          markdownContent: widget.content.optimization!,
                          isExpanded: _expandedTitle == 'Optimization',
                          onExpansionChanged: (exp) =>
                              _handleExpansion('Optimization', exp),
                        ),
                      if (widget.content.commonMistakes != null &&
                          widget.content.commonMistakes!.isNotEmpty)
                        ExpandableWidget(
                          title: 'Common Mistakes',
                          markdownContent: widget.content.commonMistakes!,
                          isExpanded: _expandedTitle == 'Common Mistakes',
                          onExpansionChanged: (exp) =>
                              _handleExpansion('Common Mistakes', exp),
                        ),
                      if (widget.content.interviewQuestions != null &&
                          widget.content.interviewQuestions!.isNotEmpty)
                        ExpandableWidget(
                          title: 'Interview Prep: Key Questions',
                          markdownContent: widget.content.interviewQuestions!,
                          isExpanded:
                              _expandedTitle == 'Interview Prep: Key Questions',
                          onExpansionChanged: (exp) => _handleExpansion(
                            'Interview Prep: Key Questions',
                            exp,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
              Positioned(
                right: 24,
                bottom: 24,
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedOpacity(
                        opacity: _showScrollToTop ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: SizedBox(
                          width: context.isTablet ? 64.0 : 44.0,
                          height: context.isTablet ? 64.0 : 44.0,
                          child: FloatingActionButton(
                            heroTag: 'scrollToTop',
                            onPressed: () {
                              if (_showScrollToTop) {
                                _scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOutCubic,
                                );
                              }
                            },
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onSecondary,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.arrow_upward_rounded,
                              size: context.isTablet ? 36 : 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AiTutorFab(
                        contextLesson: widget.lesson,
                        contextContent: widget.content,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: widget.isComplete
          ? null
          : SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenWidth * 0.05,
                  vertical: 12.0,
                ),
                child: _MarkCompleteButton(isComplete: widget.isComplete),
              ),
            ),
    );
  }
}

class _PrerequisitesCard extends StatelessWidget {
  final String prerequisites;

  const _PrerequisitesCard({required this.prerequisites});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Split by newlines in case there are multiple prerequisites in the string
    final items = prerequisites
        .split('\n')
        .map(
          (s) => s.trim().replaceFirst(RegExp(r'^- '), ''),
        ) // clean up existing markdown bullets if any
        .where((s) => s.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: colorScheme.primary, width: 4)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.task_alt_rounded,
                color: colorScheme.primary,
                size: 22.0,
              ),
              const SizedBox(width: 8),
              Text(
                StringConstants.prerequisites,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20.0,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkCompleteButton extends StatelessWidget {
  final bool isComplete;

  const _MarkCompleteButton({required this.isComplete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 50.0,
      child: ElevatedButton.icon(
        onPressed: () {
          final lessonBloc = context.read<LessonBloc>();

          lessonBloc.add(LessonMarkCompleteRequested());

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lesson marked as complete!',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary,
                ),
              ),
              behavior: SnackBarBehavior.floating,
              width: null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () {
                  lessonBloc.add(LessonMarkIncompleteRequested());
                },
              ),
            ),
          );
        },
        icon: Icon(
          isComplete
              ? Icons.check_circle_rounded
              : Icons.check_circle_outline_rounded,
          size:
              (context.isTablet
                      ? theme.textTheme.titleLarge
                      : theme.textTheme.titleMedium)
                  ?.fontSize,
        ),
        label: Text(
          isComplete ? 'Marked as Complete' : 'Mark as Complete',
          style:
              (context.isTablet
                      ? theme.textTheme.titleLarge
                      : theme.textTheme.titleMedium)
                  ?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isComplete
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primary,
          foregroundColor: isComplete
              ? colorScheme.onSurfaceVariant
              : colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isComplete ? 0 : 2,
          alignment: AlignmentGeometry.center,
        ),
      ),
    );
  }
}

class _SubLessonNavigationSection extends StatelessWidget {
  final LessonDay lesson;
  final List<String> subLessonPaths;

  const _SubLessonNavigationSection({
    required this.lesson,
    required this.subLessonPaths,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.alt_route_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                StringConstants.exploreApproaches,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: subLessonPaths.map((path) {
              final label = LessonDay.subLessonLabel(path);
              return InkWell(
                onTap: () {
                  context.pushNamed(
                    'subLesson',
                    pathParameters: {
                      'phaseId': lesson.phase.toString(),
                      'moduleId': lesson.module.toString(),
                      'day': lesson.day.toString(),
                      'subLessonPath': Uri.encodeComponent(path),
                    },
                    queryParameters: {'parentTitle': lesson.title},
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: colorScheme.outlineVariant,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
