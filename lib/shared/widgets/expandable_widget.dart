import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import 'code_element_builder.dart';

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
class ExpandableWidget extends StatefulWidget {
  final String title;
  final String markdownContent;
  final bool isExpanded;
  final ValueChanged<bool>? onExpansionChanged;

  const ExpandableWidget({
    super.key,
    required this.title,
    required this.markdownContent,
    this.isExpanded = false,
    this.onExpansionChanged,
  });

  @override
  State<ExpandableWidget> createState() => _ExpandableWidgetState();
}

class _ExpandableWidgetState extends State<ExpandableWidget> {
  final ExpansibleController _controller = ExpansibleController();
  bool _isProgrammaticUpdate = false;

  @override
  void didUpdateWidget(covariant ExpandableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      _isProgrammaticUpdate = true;
      if (widget.isExpanded) {
        if (!_controller.isExpanded) _controller.expand();
      } else {
        if (_controller.isExpanded) _controller.collapse();
      }
      _isProgrammaticUpdate = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        // Remove default ExpansionTile dividers
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          controller: _controller,
          initiallyExpanded: widget.isExpanded,
          onExpansionChanged: (expanded) {
            if (!_isProgrammaticUpdate) {
              widget.onExpansionChanged?.call(expanded);
            }
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(
            widget.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 12),
            MarkdownBody(
              data: widget.markdownContent,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                h1Padding: const EdgeInsets.only(top: 16),
                h1: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
                h2Padding: const EdgeInsets.only(top: 16),
                h2: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
                h3Padding: const EdgeInsets.only(top: 16),
                h3: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
                blockSpacing: 12,
                a: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
              builders: {'pre': CodeElementBuilder(context)},
            ),
          ],
        ),
      ),
    );
  }
}
