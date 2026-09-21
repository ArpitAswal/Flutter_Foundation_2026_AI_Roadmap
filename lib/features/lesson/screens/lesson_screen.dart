import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/di/injection.dart';
import '../../../domain/models/curriculum/lesson_content.dart';
import '../../../domain/models/curriculum/lesson_day.dart';
import '../../../shared/widgets/expandable_widget.dart';
import '../../../shared/widgets/code_block_widget.dart';
import '../../../shared/widgets/code_element_builder.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/lesson_bloc.dart';
import '../../curriculum/bloc/curriculum_bloc.dart';

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
          return const Scaffold(body: _LessonLoadingView());
        }
        if (state is LessonError) {
          return Scaffold(
            body: _LessonErrorView(
              phaseId: phaseId,
              moduleId: moduleId,
              day: dayID,
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

class _LessonLoadingView extends StatelessWidget {
  const _LessonLoadingView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitThreeBounce(color: colorScheme.primary, size: 36.0),
          const SizedBox(height: 20),
          Text(
            StringConstants.preparingLesson,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonErrorView extends StatelessWidget {
  final int phaseId;
  final int moduleId;
  final int day;

  const _LessonErrorView({
    required this.phaseId,
    required this.moduleId,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: context.responsivePadding(16, 10).padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error Illustration Icon Container
          Container(
            width: context.isTablet ? 200 : 100,
            height: context.isTablet ? 200 : 100,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            alignment: AlignmentGeometry.center,
            child: Icon(
              Icons.auto_stories_outlined,
              color: colorScheme.error,
              size: context.isTablet ? 140 : 60,
            ),
          ),

          SizedBox(height: context.responsiveHeightSpace(0.01)),

          // Title
          Text(
            StringConstants.lessonUnavailable,
            textAlign: TextAlign.center,
            style: context.responsiveTextTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: context.responsiveHeightSpace(0.01)),

          // Apology Message
          Text(
            StringConstants.lessonErrorApology,
            textAlign: TextAlign.center,
            style: context.responsiveTextTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          SizedBox(height: context.responsiveHeightSpace(0.02)),

          // Navigation and Retry Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/roadmap/phases');
                  }
                },
                icon: Icon(
                  Icons.arrow_back_rounded,
                  size: context.isTablet ? 38 : 21,
                ),
                label: Text(
                  StringConstants.goBack,
                  style: context.responsiveTextTheme.bodyLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: context.responsivePadding(16, 12).padding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: colorScheme.primary),
                  ),
                ),
              ),
              SizedBox(width: context.screenWidth * 0.04),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<LessonBloc>().add(
                    LessonLoadRequested(
                      phase: phaseId,
                      module: moduleId,
                      day: day,
                      again: true,
                    ),
                  );
                },
                icon: Icon(
                  Icons.refresh_rounded,
                  size: context.isTablet ? 38 : 21,
                ),
                label: Text(
                  StringConstants.tryAgain,
                  style: context.responsiveTextTheme.bodyLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: context.responsivePadding(16, 12).padding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
      return const Scaffold(body: _LessonLoadingView());
    }
    double fabSize;
    if (context.isTablet) {
      fabSize = (context.screenHeight * 0.1).clamp(60.0, 120.0);
    } else if (context.isSmallPhone) {
      fabSize = (context.screenWidth * 0.09).clamp(20.0, 40.0);
    } else {
      fabSize = (context.screenWidth * 0.12).clamp(40.0, 60.0);
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: ListView(
                controller: _scrollController,
                padding: context.responsivePadding(16, 21).padding,
                children: [
                  // ── Lesson Title ────────────────────────────────────────────────────
                  Text(
                    widget.lesson.title,
                    style: context.responsiveTextTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                    ),
                  ),
                  SizedBox(height: context.responsiveHeightSpace(0.01)),

                  // ── Last Updated Date Metadata ─────────────────────────────────────
                  if (widget.content.lastUpdated != null &&
                      widget.content.lastUpdated!.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: context.isTablet ? 28 : 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${StringConstants.lastUpdated} ${widget.content.lastUpdated}',
                          style: context.responsiveTextTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    SizedBox(height: context.responsiveHeightSpace(0.02)),
                  ],

                  // ── Tags ─────────────────────────────────────────────────────────────
                  if (widget.lesson.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: context.isTablet ? 16 : 8,
                      runSpacing: context.isTablet ? 12 : 8,
                      children: widget.lesson.tags.map((tag) {
                        return Container(
                          padding: context.responsivePadding(12, 6).padding,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(
                              alpha: 0.6,
                            ),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            tag,
                            style: context.responsiveTextTheme.labelMedium
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: context.responsiveHeightSpace(0.02)),
                  ],

                  // ── Prerequisites ────────────────────────────────────────────────────
                  if (widget.content.prerequisites.isNotEmpty) ...[
                    _PrerequisitesCard(
                      prerequisites: widget.content.prerequisites,
                    ),
                  ],
                  SizedBox(height: context.responsiveHeightSpace(0.02)),
                  // ── Theory (Markdown) ─────────────────────────────────────────────
                  MarkdownBody(
                    data: widget.content.theory,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: context.responsiveTextTheme.bodyMedium?.copyWith(
                        height: 1.7,
                      ),
                      h1Padding: const EdgeInsets.only(top: 16),
                      h1: context.responsiveTextTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.primary,
                      ),
                      h2Padding: const EdgeInsets.only(top: 16),
                      h2: context.responsiveTextTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                      h3Padding: const EdgeInsets.only(top: 16),
                      h3: context.responsiveTextTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                      blockSpacing: 12,
                      a: context.responsiveTextTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      // This targets inline code wrapped in single backticks (e.g., `int`)
                      code: TextStyle(
                        fontSize:
                            context.responsiveTextTheme.bodyMedium?.fontSize,
                        color: Colors.black, // High contrast for Light Theme
                        backgroundColor:
                            Colors.grey.shade200, // Very subtle gray background
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
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    opacity: _showScrollToTop ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: fabSize,
                      height: fabSize,
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
                          borderRadius: BorderRadius.circular(fabSize * 0.25),
                        ),
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          size: fabSize * 0.7,
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
      ),
      bottomNavigationBar: widget.isComplete
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
      padding: context.responsivePadding(16, 12).padding,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: context.responsiveCircularRadius,
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
                size: context.isTablet
                    ? 36.0
                    : context.isSmallPhone
                    ? 16
                    : 22.0,
              ),
              const SizedBox(width: 8),
              Text(
                StringConstants.prerequisites,
                style: context.responsiveTextTheme.titleMedium?.copyWith(
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
                    width: context.isTablet ? 28.0 : 22.0,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: context.isTablet ? 8 : 6),
                    child: Container(
                      width: context.isTablet ? 10 : 6,
                      height: context.isTablet ? 10 : 6,
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
                      style: context.responsiveTextTheme.bodyMedium?.copyWith(
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
      height: context.isTablet
          ? 64
          : context.isSmallPhone
          ? 36
          : 48,
      child: ElevatedButton.icon(
        onPressed: () {
          final lessonBloc = context.read<LessonBloc>();

          lessonBloc.add(LessonMarkCompleteRequested());

          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lesson marked as complete!',
                style: context.responsiveTextTheme.labelLarge?.copyWith(
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
          size: context.isTablet
              ? 42
              : context.isSmallPhone
              ? 18
              : 24,
        ),
        label: Text(
          isComplete ? 'Marked as Complete' : 'Mark as Complete',
          style: context.responsiveTextTheme.titleMedium?.copyWith(
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
