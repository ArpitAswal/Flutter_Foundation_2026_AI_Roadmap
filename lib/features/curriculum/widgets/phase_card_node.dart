import 'package:flutter/material.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/string_constants.dart';
import '../../../domain/models/curriculum/phase.dart';
import 'curriculum_card_node.dart';
import 'curriculum_progress_bar.dart';

class PhaseCardNode extends StatelessWidget {
  final Phase phase;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;
  final int completedDays;
  final bool isGridMode;

  const PhaseCardNode({
    super.key,
    required this.phase,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.completedDays,
    this.isGridMode = false,
  });

  @override
  Widget build(BuildContext context) {
    // The timeline status node icon
    final Widget node = _buildStatusNode(context);

    if (isGridMode) {
      // Clean, structured layout specifically for the tablet grid to remove empty space
      return CurriculumCard(
        isLocked: isLocked,
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 26.0),
          child: _buildGridChild(context, node: node),
        ),
      );
    } else if (context.isTablet) {
      // Tablet single column mode (fallback if not in grid)
      return CurriculumCard(
        isLocked: isLocked,
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 26.0),
          child: _buildListChild(context, node: node),
        ),
      );
    } else {
      // Mobile Timeline layout (node is completely outside on the left)
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          node,
          const SizedBox(width: 12),
          Expanded(
            child: CurriculumCard(
              isLocked: isLocked,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 20.0,
                ),
                child: _buildListChild(context),
              ),
            ),
          ),
        ],
      );
    }
  }

  /// The standard list-based layout (used in Mobile and single-column tablet views)
  Widget _buildListChild(BuildContext context, {Widget? node}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 8),
        _buildTitle(context),
        const SizedBox(height: 12),
        _buildDescription(context, null),
        _buildProgressAndActions(context, node: node),
      ],
    );
  }

  /// The optimized Grid layout (used exclusively in Tablet Grid View)
  Widget _buildGridChild(BuildContext context, {required Widget node}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 12),
        _buildTitle(context),
        const SizedBox(height: 8),
        // MaxLines restricts vertical growth, while Spacer pushes footer to the bottom.
        _buildDescription(context, 6),
        const Spacer(),
        _buildProgressAndActions(context, node: node),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Text(
      phase.title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: isLocked ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
        fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
      ),
    );
  }

  Widget _buildDescription(BuildContext context, int? maxLines) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Text(
      isLocked
          ? 'Unlock by completing Phase ${phase.id - 1}. ${phase.description}'
          : phase.description,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isLocked ? colorScheme.outline : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isCompleted) {
      return OutlinedButton(
        onPressed: () => context.goNamed(
          'modules',
          pathParameters: {'phaseId': '${phase.id}'},
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          StringConstants.reviewPhase,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return ElevatedButton.icon(
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Widget _buildProgressAndActions(BuildContext context, {Widget? node}) {
    if (isLocked) {
      return Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Align(
          alignment: AlignmentGeometry.centerRight,
          child: node ?? const SizedBox.shrink(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 18),
        CurriculumProgressBar(
          fraction: phase.totalDays == 0
              ? 0.0
              : completedDays / phase.totalDays,
          isCurrent: isCurrent,
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionButton(context),
            node ?? const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusNode(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    // Slightly smaller node size when in Grid mode to save space, but still prominent
    double width;
    double height;
     if (context.isTablet) {
      width = size.height * 0.08;
      height = size.height * 0.08;
    } else {
      width = size.width * 0.1;
      height = size.width * 0.1;
    }

    if (isCompleted) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.check_rounded,
          color: colorScheme.onPrimary,
          size: width * 0.6,
        ),
      );
    } else if (isCurrent) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.play_arrow_outlined,
          color: colorScheme.onPrimary,
          size: width * 0.6,
        ),
      );
    } else {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.outlineVariant, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.surfaceContainerHighest,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.lock_outline,
          color: colorScheme.outline.withValues(alpha: 0.5),
          size: width * 0.6,
        ),
      );
    }
  }
}
