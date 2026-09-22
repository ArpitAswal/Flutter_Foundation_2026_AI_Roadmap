import 'package:flutter/material.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
      body: FutureBuilder<LessonContent>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
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

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: context.responsivePadding(16, 10).padding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: context.isTablet ? 200 : 100,
                      height: context.isTablet ? 200 : 100,
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 0.4,
                        ),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.auto_stories_outlined,
                        color: colorScheme.error,
                        size: context.isTablet ? 140 : 60,
                      ),
                    ),
                    SizedBox(height: context.responsiveHeightSpace(0.02)),
                    Text(
                      StringConstants.lessonUnavailable,
                      textAlign: TextAlign.center,
                      style: context.responsiveTextTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    SizedBox(height: context.responsiveHeightSpace(0.01)),
                    Text(
                      StringConstants.lessonErrorApology,
                      textAlign: TextAlign.center,
                      style: context.responsiveTextTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: context.responsiveHeightSpace(0.02)),
                    OutlinedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
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
                  ],
                ),
              ),
            );
          }

          final content = snapshot.data!;
          double fabSize;
          if (context.isTablet) {
            fabSize = (context.screenHeight * 0.1).clamp(60.0, 120.0);
          } else if (context.isSmallPhone) {
            fabSize = (context.screenWidth * 0.09).clamp(20.0, 40.0);
          } else {
            fabSize = (context.screenWidth * 0.12).clamp(40.0, 60.0);
          }

          return Stack(
            children: [
              Positioned.fill(
                child: SafeArea(
                  child: ListView(
                    controller: _scrollController,
                    padding: context.responsivePadding(16, 21).padding,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            child: Icon(
                              Icons.arrow_back_rounded,
                              size: context.isTablet ? 44 : 28,
                            ),
                            onTap: () => context.pop(),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: context.responsiveTextTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: GoogleFonts.hankenGrotesk()
                                          .fontFamily,
                                    ),
                                children: [
                                  TextSpan(text: label),

                                  TextSpan(text: " "),
                                  if (widget.parentTitle.isNotEmpty)
                                    TextSpan(
                                      text: "(${widget.parentTitle})",
                                      style: context
                                          .responsiveTextTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.responsiveHeightSpace(0.01)),

                      // Last Updated Date Metadata
                      if (content.lastUpdated != null &&
                          content.lastUpdated!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: context.isTablet ? 28 : 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${StringConstants.lastUpdated} ${content.lastUpdated}',
                              style: context.responsiveTextTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.responsiveHeightSpace(0.02)),
                      ],

                      // Prerequisites
                      if (content.prerequisites.isNotEmpty) ...[
                        _SubLessonPrerequisitesCard(
                          prerequisites: content.prerequisites,
                        ),
                        SizedBox(height: context.responsiveHeightSpace(0.02)),
                      ],

                      // Theory (Markdown)
                      MarkdownBody(
                        data: content.theory,
                        styleSheet: MarkdownStyleSheet.fromTheme(theme)
                            .copyWith(
                              p: context.responsiveTextTheme.bodyMedium
                                  ?.copyWith(height: 1.7),
                              h1Padding: const EdgeInsets.only(top: 16),
                              h1: context.responsiveTextTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.primary,
                                  ),
                              h2Padding: const EdgeInsets.only(top: 16),
                              h2: context.responsiveTextTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                              h3Padding: const EdgeInsets.only(top: 16),
                              h3: context.responsiveTextTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                              blockSpacing: 12,
                              a: context.responsiveTextTheme.bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                              code: TextStyle(
                                fontSize: context
                                    .responsiveTextTheme
                                    .bodyMedium
                                    ?.fontSize,
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
                              borderRadius: BorderRadius.circular(
                                fabSize * 0.25,
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_upward_rounded,
                              size: fabSize * 0.7,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AiTutorFab(contextTitle: label, contextContent: content),
                    ],
                  ),
                ),
              ),
            ],
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
      padding: context.responsivePadding(16, 12).padding,
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
                size: context.isTablet ? 30 : 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                StringConstants.prerequisites,
                style: context.responsiveTextTheme.titleSmall?.copyWith(
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
                      style: context.responsiveTextTheme.bodySmall?.copyWith(
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
