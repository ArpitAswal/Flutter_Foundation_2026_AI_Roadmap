import 'package:flutter/material.dart';

class CurriculumListLayout extends StatelessWidget {
  final Widget? header;
  final Widget Function(BuildContext context, int columns) buildGrid;
  final Widget Function(BuildContext context) buildTimeline;
  final int maxGridColumns;
  final double minCardWidth;
  final double cardSpacing;
  final double maxContentWidth;

  const CurriculumListLayout({
    super.key,
    this.header,
    required this.buildGrid,
    required this.buildTimeline,
    this.maxGridColumns = 4,
    this.minCardWidth = 340.0,
    this.cardSpacing = 16.0,
    this.maxContentWidth = 1200.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final double clampedMaxContentWidth = availableWidth.clamp(0.0, maxContentWidth);
        final int columns = ((clampedMaxContentWidth + cardSpacing) / (minCardWidth + cardSpacing))
            .floor()
            .clamp(1, maxGridColumns);
        final bool isMultiColumn = columns > 1;

        final horizontalPadding = isMultiColumn
            ? (availableWidth > maxContentWidth ? (availableWidth - maxContentWidth) / 2 + 24.0 : 24.0)
            : 16.0;

        return ListView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 24.0,
          ),
          children: [
            ?header,
            if (header != null) const SizedBox(height: 24.0),
            if (isMultiColumn)
              buildGrid(context, columns)
            else
              Center(
                child: buildTimeline(context),
              ),
            // Add extra spacing at the bottom so the last item can be scrolled above the FAB
            const SizedBox(height: 80.0),
          ],
        );
      },
    );
  }
}

class CurriculumTimeline extends StatelessWidget {
  final double nodeSize;
  final List<Widget> children;

  const CurriculumTimeline({
    super.key,
    required this.nodeSize,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const double lineWidth = 4.0;
    final double lineLeft = (nodeSize - lineWidth) / 2;

    return Stack(
      children: [
        Positioned(
          left: lineLeft,
          top: nodeSize / 2,
          bottom: nodeSize / 4,
          width: lineWidth,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant.withAlpha(50),
              borderRadius: BorderRadius.circular(lineWidth / 2),
            ),
          ),
        ),
        Column(
          children: children,
        ),
      ],
    );
  }
}

class CurriculumGridBuilder extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const CurriculumGridBuilder({
    super.key,
    required this.itemCount,
    required this.crossAxisCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];

    for (int i = 0; i < itemCount; i += crossAxisCount) {
      final List<Widget> rowChildren = [];

      for (int j = 0; j < crossAxisCount; j++) {
        final index = i + j;

        if (index < itemCount) {
          rowChildren.add(
            Expanded(
              child: itemBuilder(context, index),
            ),
          );
        } else {
          // Fill remaining space in the row
          rowChildren.add(const Spacer());
        }

        // Add spacing between columns, except after the last column
        if (j < crossAxisCount - 1) {
          rowChildren.add(const SizedBox(width: 16));
        }
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rowChildren,
            ),
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}
