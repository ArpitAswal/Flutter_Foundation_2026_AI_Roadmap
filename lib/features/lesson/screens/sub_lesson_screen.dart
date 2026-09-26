import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/di/injection.dart';
import '../../../domain/models/curriculum/lesson_content.dart';
import '../../../domain/models/curriculum/lesson_day.dart';
import '../../../domain/usecases/get_day_content_use_case.dart';
import '../../../shared/widgets/code_element_builder.dart';
import '../../../shared/widgets/expandable_widget.dart';
import '../../ai_tutor/widgets/ai_tutor_fab.dart';
import '../../curriculum/widgets/curriculum_state_views.dart';

/// Screen for rendering sub-lesson branches (e.g., GetX, Provider, BLoC)
/// navigated to from a parent lesson that declares a `custom_route` list.
///
/// Sub-lessons share the same [LessonContent] schema as regular days, but
/// are loaded directly via [GetDayContentUseCase] without a dedicated BLoC.
/// Completion tracking is retained at the parent lesson level.
class SubLessonScreen extends StatefulWidget {
  final String assetPath;
  final String parentTitle;

  const SubLessonScreen({
    super.key,
    required this.assetPath,
    required this.parentTitle,
  });

  @override
  State<SubLessonScreen> createState() => _SubLessonScreenState();
}

class _SubLessonScreenState extends State<SubLessonScreen> {
  late final Future<LessonContent> _contentFuture;
  late final ScrollController _scrollController;
  String? _expandedTitle;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _contentFuture = getIt<GetDayContentUseCase>()(widget.assetPath);
  }

  void _onScroll() {
    if (_scrollController.offset > 400 && !_showScrollToTop) {
      setState(() => _showScrollToTop = true);
    } else if (_scrollController.offset <= 400 && _showScrollToTop) {
      setState(() => _showScrollToTop = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
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
    final label = LessonDay.subLessonLabel(widget.assetPath);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.parentTitle.isNotEmpty
              ? '$label (${widget.parentTitle})'
              : label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leadingWidth: 56.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<LessonContent>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CurriculumLoadingView(
              message: StringConstants.preparingLesson,
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return CurriculumErrorView(
              title: StringConstants.lessonUnavailable,
              message: StringConstants.lessonErrorApology,
              showBackButton: true,
              onRetry: () {
                setState(() {
                  _contentFuture = getIt<GetDayContentUseCase>()(widget.assetPath);
                });
              },
            );
          }

          final content = snapshot.data!;

          return LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              const maxContentWidth = 860.0;
              final horizontalPadding = availableWidth > maxContentWidth
                  ? (availableWidth - maxContentWidth) / 2 + 24.0
                  : 16.0;

              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: ListView(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 20.0,
                      ),
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                          ),
                        ),
                        if (widget.parentTitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.parentTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),

                        // Last Updated Date Metadata
                        if (content.lastUpdated != null &&
                            content.lastUpdated!.isNotEmpty) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${StringConstants.lastUpdated} ${content.lastUpdated}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Prerequisites
                        if (content.prerequisites.isNotEmpty) ...[
                          _SubLessonPrerequisitesCard(
                            prerequisites: content.prerequisites,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Theory (Markdown)
                        MarkdownBody(
                          data: content.theory,
                          styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                            p: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.7,
                            ),
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
                            code: TextStyle(
                              fontSize: theme.textTheme.bodyMedium?.fontSize,
                              color: Colors.black,
                              backgroundColor: Colors.grey.shade200,
                              fontFamily: 'monospace',
                            ),
                          ),
                          builders: {'pre': CodeElementBuilder(context)},
                        ),

                        // Deep Dive Accordions
                        if (content.hasDeepDives) ...[
                          const SizedBox(height: 32),

                          if (content.implementation != null &&
                              content.implementation!.isNotEmpty)
                            ExpandableWidget(
                              title: 'Practical Implementation',
                              markdownContent: content.implementation!,
                              isExpanded:
                                  _expandedTitle == 'Practical Implementation',
                              onExpansionChanged: (exp) => _handleExpansion(
                                'Practical Implementation',
                                exp,
                              ),
                            ),
                          if (content.architecture != null &&
                              content.architecture!.isNotEmpty)
                            ExpandableWidget(
                              title: 'Architecture & Mental Model',
                              markdownContent: content.architecture!,
                              isExpanded:
                                  _expandedTitle == 'Architecture & Mental Model',
                              onExpansionChanged: (exp) => _handleExpansion(
                                'Architecture & Mental Model',
                                exp,
                              ),
                            ),
                          if (content.comparisons != null &&
                              content.comparisons!.isNotEmpty)
                            ExpandableWidget(
                              title: 'Comparisons & Trade-offs',
                              markdownContent: content.comparisons!,
                              isExpanded:
                                  _expandedTitle == 'Comparisons & Trade-offs',
                              onExpansionChanged: (exp) => _handleExpansion(
                                'Comparisons & Trade-offs',
                                exp,
                              ),
                            ),
                          if (content.optimization != null &&
                              content.optimization!.isNotEmpty)
                            ExpandableWidget(
                              title: 'Optimization & Best Practices',
                              markdownContent: content.optimization!,
                              isExpanded:
                                  _expandedTitle ==
                                  'Optimization & Best Practices',
                              onExpansionChanged: (exp) => _handleExpansion(
                                'Optimization & Best Practices',
                                exp,
                              ),
                            ),
                          if (content.commonMistakes != null &&
                              content.commonMistakes!.isNotEmpty)
                            ExpandableWidget(
                              title: 'Common Mistakes & Gotchas',
                              markdownContent: content.commonMistakes!,
                              isExpanded:
                                  _expandedTitle == 'Common Mistakes & Gotchas',
                              onExpansionChanged: (exp) => _handleExpansion(
                                'Common Mistakes & Gotchas',
                                exp,
                              ),
                            ),
                          if (content.interviewQuestions != null &&
                              content.interviewQuestions!.isNotEmpty)
                            ExpandableWidget(
                              title: 'Interview Prep: Key Questions',
                              markdownContent: content.interviewQuestions!,
                              isExpanded:
                                  _expandedTitle ==
                                  'Interview Prep: Key Questions',
                              onExpansionChanged: (exp) => _handleExpansion(
                                'Interview Prep: Key Questions',
                                exp,
                              ),
                            ),
                        ],
                        // Extra bottom padding for FAB clearance
                        const SizedBox(height: 80),
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
                              width: 48.0,
                              height: 48.0,
                              child: FloatingActionButton(
                                heroTag: 'subLessonScrollToTop',
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
                                child: const Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AiTutorFab(
                            contextTitle: label,
                            contextContent: content,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _SubLessonPrerequisitesCard extends StatelessWidget {
  final String prerequisites;

  const _SubLessonPrerequisitesCard({required this.prerequisites});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final items = prerequisites
        .split('\n')
        .map((s) => s.trim().replaceFirst(RegExp(r'^- '), ''))
        .where((s) => s.isNotEmpty)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                StringConstants.prerequisites,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
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
