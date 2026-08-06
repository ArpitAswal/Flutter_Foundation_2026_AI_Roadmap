import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      child: _LessonView(phaseId: phaseId, moduleId: moduleId, dayID: day),
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
    return Scaffold(
      body: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoading) {
            return const _LessonLoadingView();
          }
          if (state is LessonError) {
            return _LessonErrorView(
              phaseId: phaseId,
              moduleId: moduleId,
              day: dayID,
            );
          }
          if (state is LessonLoaded) {
            return _LessonContent(
              lesson: state.lesson,
              content: state.content,
              isComplete: state.isComplete,
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoaded) {
            return AiTutorFab(
              contextLesson: state.lesson,
              contextContent: state.content,
            );
          }
          return const AiTutorFab();
        },
      ),
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
    final size = MediaQuery.sizeOf(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Illustration Icon Container
            Container(
              width: size.width * 0.3,
              height: size.width * 0.3,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                size: size.width * 0.2,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              StringConstants.lessonUnavailable,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            // Apology Message
            Text(
              StringConstants.lessonErrorApology,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

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
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text(StringConstants.goBack),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(StringConstants.tryAgain),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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

  @override
  void initState() {
    super.initState();
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
      return const _LessonLoadingView();
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          // ── Lesson Title ────────────────────────────────────────────────────
          Text(
            widget.lesson.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
            ),
          ),
          const SizedBox(height: 8),

          // ── Last Updated Date Metadata ─────────────────────────────────────
          if (widget.content.lastUpdated != null &&
              widget.content.lastUpdated!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '${StringConstants.lastUpdated} ${widget.content.lastUpdated}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 16),

          // ── Tags ─────────────────────────────────────────────────────────────
          if (widget.lesson.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.lesson.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // ── Prerequisites ────────────────────────────────────────────────────
          if (widget.content.prerequisites.isNotEmpty) ...[
            _PrerequisitesCard(prerequisites: widget.content.prerequisites),
            const SizedBox(height: 20),
          ],

          // ── Theory (Markdown) ─────────────────────────────────────────────
          if (widget.content.theory.isNotEmpty)
            MarkdownBody(
              data: widget.content.theory,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
                h1Padding: const EdgeInsets.only(top: 16),
                h1: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.primary,
                ),
                h2Padding: const EdgeInsets.only(top: 16),
                h2: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
                h3Padding: const EdgeInsets.only(top: 16),
                h3: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
                blockSpacing: 12,
                a: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
                // This targets inline code wrapped in single backticks (e.g., `int`)
                code: TextStyle(
                  fontSize: theme
                      .textTheme
                      .bodyMedium
                      ?.fontSize, // Matches your body text size
                  color: Colors.black, // High contrast for Light Theme
                  backgroundColor:
                      Colors.grey.shade200, // Very subtle gray background
                  fontFamily: 'monospace', // Keeps the developer aesthetic
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
                isExpanded: _expandedTitle == 'Interview Prep: Key Questions',
                onExpansionChanged: (exp) =>
                    _handleExpansion('Interview Prep: Key Questions', exp),
              ),
          ],

          // ── Mark as Complete ─────────────────────────────────────────────────
          const SizedBox(height: 36),
          _MarkCompleteButton(isComplete: widget.isComplete),
        ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: colorScheme.primary, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.task_alt_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                StringConstants.prerequisites,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
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
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isComplete
            ? null
            : () {
                context.read<LessonBloc>().add(LessonMarkCompleteRequested());
                context.read<CurriculumBloc>().add(CurriculumLoadRequested());
                // Navigate back after marking complete so the parent refreshes
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (context.mounted) context.pop();
                });
              },
        icon: Icon(
          isComplete
              ? Icons.check_circle_rounded
              : Icons.check_circle_outline_rounded,
        ),
        label: Text(
          isComplete ? 'Completed' : 'Mark as Complete',
          style: const TextStyle(fontWeight: FontWeight.w700),
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
        ),
      ),
    );
  }
}
