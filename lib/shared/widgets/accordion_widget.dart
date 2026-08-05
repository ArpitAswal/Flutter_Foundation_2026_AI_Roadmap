import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// An expandable accordion widget that renders Markdown content inside.
///
/// Used in the "Deep Dives" section of the lesson screen for:
/// - Comparisons
/// - Optimization tips
/// - Interview questions
///
/// Renders [markdownContent] as formatted Markdown when expanded.
///
/// Usage:
/// ```dart
/// AccordionWidget(
///   title: 'Comparisons: Bloc vs Provider',
///   markdownContent: '## Bloc\n\nBetter for complex state...',
/// )
/// ```
class AccordionWidget extends StatelessWidget {
  final String title;
  final String markdownContent;

  const AccordionWidget({
    super.key,
    required this.title,
    required this.markdownContent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        // Remove default ExpansionTile dividers
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 12),
            MarkdownBody(
              data: markdownContent,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                h2: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                code: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
