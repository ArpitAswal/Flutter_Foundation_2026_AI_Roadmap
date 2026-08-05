import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundation/core/constants/string_constants.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/di/injection.dart';
import '../../../domain/models/curriculum/lesson_day.dart';
import '../../../shared/widgets/expandable_widget.dart';
import '../../../shared/widgets/code_block_widget.dart';
import '../../../shared/widgets/code_element_builder.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../bloc/lesson_bloc.dart';

/// Renders the full content of a single lesson day.
///
/// Content sections rendered in order:
/// 1. Prerequisites — info card
/// 2. Theory — Markdown rendered body
/// 3. Code Instruction — [CodeBlockWidget] (if present)
/// 4. Deep Dives section header (if any accordion content exists)
/// 5. Comparisons — [ExpandableWidget]
/// 6. Optimization — [ExpandableWidget]
/// 7. Interview Questions — [ExpandableWidget]
/// 8. Mark as Complete button
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
      child: _LessonView(dayID: day),
    );
  }
}

class _LessonView extends StatelessWidget {
  final int dayID;

  const _LessonView({required this.dayID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(200),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${StringConstants.dayPrefix} $dayID',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.6,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LessonError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(state.message),
              ),
            );
          }
          if (state is LessonLoaded) {
            return _LessonContent(
              lesson: state.lesson,
              isComplete: state.isComplete,
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoaded) {
            return AiTutorFab(contextLesson: state.lesson);
          }
          return const AiTutorFab();
        },
      ),
    );
  }
}

class _LessonContent extends StatelessWidget {
  final LessonDay lesson;
  final bool isComplete;

  const _LessonContent({required this.lesson, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    final content = lesson.content;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // ── Lesson Title ────────────────────────────────────────────────────
        Text(
          lesson.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
          ),
        ),
        const SizedBox(height: 20),

        // ── Prerequisites ────────────────────────────────────────────────────
        if (content.prerequisites.isNotEmpty) ...[
          _PrerequisitesCard(prerequisites: content.prerequisites),
          const SizedBox(height: 20),
        ],

        // ── Theory (Markdown) ─────────────────────────────────────────────
        if (content.theory.isNotEmpty)
          MarkdownBody(
            data: content.theory,
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
              h3: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
              blockSpacing: 12,
              a: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
            builders: {'pre': CodeElementBuilder(context)},
          ),

        // ── Additional Sections (Accordions) ─────────────────────────────────
        if (content.comparisons != null ||
            content.implementation != null ||
            content.hasDeepDives) ...[
          const SizedBox(height: 32),

          if (content.comparisons != null && content.comparisons!.isNotEmpty)
            ExpandableWidget(
              title: 'Comparisons',
              markdownContent: content.comparisons!,
            ),
          if (content.implementation != null &&
              content.implementation!.isNotEmpty)
            ExpandableWidget(
              title: 'Implementation',
              markdownContent: content.implementation!,
            ),
          if (content.architecture != null && content.architecture!.isNotEmpty)
            ExpandableWidget(
              title: 'Architecture',
              markdownContent: content.architecture!,
            ),
          if (content.optimization != null && content.optimization!.isNotEmpty)
            ExpandableWidget(
              title: 'Optimization',
              markdownContent: content.optimization!,
            ),
          if (content.commonMistakes != null &&
              content.commonMistakes!.isNotEmpty)
            ExpandableWidget(
              title: 'Common Mistakes',
              markdownContent: content.commonMistakes!,
            ),
          if (content.interviewQuestions != null &&
              content.interviewQuestions!.isNotEmpty)
            ExpandableWidget(
              title: 'Interview Prep: Key Questions',
              markdownContent: content.interviewQuestions!,
            ),
        ],

        // ── Mark as Complete ─────────────────────────────────────────────────
        const SizedBox(height: 36),
        _MarkCompleteButton(isComplete: isComplete),
      ],
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.primaryContainer),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              prerequisites,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
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
