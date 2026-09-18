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
  final int completedModules;
  final bool isGridMode;

  const PhaseCardNode({
    super.key,
    required this.phase,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.completedModules,
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
          padding: context.responsivePadding(18, 16).padding,
          child: _buildGridChild(context, node: node),
        ),
      );
    }
    // else if (context.isTablet) {
    //   // Tablet single column mode (fallback if not in grid)
    //   return CurriculumCard(
    //     isLocked: isLocked,
    //     isCompleted: isCompleted,
    //     isCurrent: isCurrent,
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 26.0),
    //       child: _buildListChild(context, node: node),
    //     ),
    //   );
    // }
    else {
      // Mobile Timeline layout (node is completely outside on the left)
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          node,
          const SizedBox(width: 8),
          Expanded(
            child: CurriculumCard(
              isLocked: isLocked,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              child: Padding(
                padding: context.responsivePadding(16, 8).padding,
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
    return InkWell(
      onTap: () => context.goNamed(
        'modules',
        pathParameters: {'phaseId': '${phase.id}'},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildTitle(context),
          const SizedBox(height: 4),
          _buildDescription(context, null),
          _buildProgressAndActions(context, node: node),
        ],
      ),
    );
  }

  /// The optimized Grid layout (used exclusively in Tablet Grid View)
  Widget _buildGridChild(BuildContext context, {required Widget node}) {
    return InkWell(
      onTap: () => context.goNamed(
        'modules',
        pathParameters: {'phaseId': '${phase.id}'},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildTitle(context),
          const SizedBox(height: 4),
          // MaxLines restricts vertical growth, while Spacer pushes footer to the bottom.
          _buildDescription(context, 6),
          const Spacer(),
          _buildProgressAndActions(context, node: node),
        ],
      ),
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
          style: context.responsiveTextTheme.labelLarge?.copyWith(
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
            padding: context.responsivePadding(14, 6).padding,
            decoration: BoxDecoration(
              color: isCurrent
                  ? colorScheme.secondaryContainer.withValues(alpha: 0.1)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: context.responsiveCircularRadius,
            ),
            child: Text(
              '$completedModules/${phase.modules.length}',
              style: context.responsiveTextTheme.labelSmall?.copyWith(
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
      style: context.responsiveTextTheme.titleMedium?.copyWith(
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
      phase.description,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: context.responsiveTextTheme.bodySmall?.copyWith(
        color: isLocked ? colorScheme.outline : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (isCompleted) {
      return OutlinedButton.icon(
        onPressed: () => context.goNamed(
          'modules',
          pathParameters: {'phaseId': '${phase.id}'},
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary),
          padding: context.responsivePadding(12, 8).padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
        ),
        icon: Icon(
          Icons.arrow_forward_rounded,
          size: context.responsiveTextTheme.headlineSmall?.fontSize,
        ),
        label: Text(
          StringConstants.reviewPhase,
          style: context.responsiveTextTheme.bodySmall?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () => context.goNamed(
          'modules',
          pathParameters: {'phaseId': '${phase.id}'},
        ),
        icon: Icon(
          Icons.arrow_forward_rounded,
          size: context.responsiveTextTheme.headlineSmall?.fontSize,
        ),
        label: Text(
          StringConstants.continueLearning,
          style: context.responsiveTextTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onPrimary,
          padding: context.responsivePadding(12, 8).padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
        ),
      );
    }
  }

  Widget _buildProgressAndActions(BuildContext context, {Widget? node}) {
    if (isLocked && node != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 18.0),
        child: Align(alignment: AlignmentGeometry.centerRight, child: node),
      );
    } else if (!isLocked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: context.responsivePadding(0, 8.0).padding,
            child: CurriculumProgressBar(
              fraction: phase.modules.isEmpty
                  ? 0.0
                  : completedModules / phase.modules.length,
              isCurrent: isCurrent,
              height: context.responsiveHeightSpace(0.008),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 16,
              children: [
                _buildActionButton(context),
                node ?? const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildStatusNode(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    // Slightly smaller node size when in Grid mode to save space, but still prominent
    double width;
    double height;
    if (context.isTablet) {
      width = (size.height * 0.07).clamp(40.0, 64.0);
      height = width;
    } else {
      width = (size.width * 0.08).clamp(36.0, 48.0);
      height = width;
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
              color: colorScheme.primary.withValues(alpha: 0.3),
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
              color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
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
