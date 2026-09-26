import 'package:flutter/material.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';
import 'package:go_router/go_router.dart';

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
  final VoidCallback? onTap;

  /// Stable design token for node size in mobile timeline mode
  static const double nodeSize = 36.0;

  const PhaseCardNode({
    super.key,
    required this.phase,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.completedModules,
    this.isGridMode = false, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // The timeline status node icon
    final Widget node = _buildStatusNode(context);

    if (isGridMode) {
      // Clean, structured layout specifically for grid mode
      return CurriculumCard(
        isLocked: isLocked,
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 15),
          child: _buildGridChild(context, node: node),
        ),
      );
    } else {
      // Mobile Timeline layout (node is positioned on the left at fixed width)
      return Row(
        mainAxisSize: MainAxisSize.max,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
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
        _buildTitle(context),
        const SizedBox(height: 4),
        _buildDescription(context, null),
        _buildProgressAndActions(context, node: node),
      ],
    );
  }

  /// The optimized Grid layout (used in multi-column view)
  Widget _buildGridChild(BuildContext context, {required Widget node}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, node: node),
        _buildTitle(context),
        const SizedBox(height: 4),
        _buildDescription(context, 4),
        const Spacer(),
        _buildProgressAndActions(context, node: node),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, {Widget? node}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '${StringConstants.phasePrefix} ${phase.id}',
            style: theme.textTheme.labelLarge?.copyWith(
              color: isCurrent
                  ? colorScheme.secondaryContainer
                  : isLocked
                  ? colorScheme.outline
                  : colorScheme.primary,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isCurrent
                ? colorScheme.secondaryContainer.withValues(alpha: 0.1)
                : isLocked
                ? colorScheme.onPrimary
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$completedModules/${phase.modules.length}',
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
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: isLocked ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
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
      style: context.subDescriptionStyle.copyWith(
        color: isLocked ? colorScheme.outline : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (isCompleted) {
      return SizedBox(
        height: 40,
        child: OutlinedButton.icon(
          onPressed: () => context.goNamed(
            'modules',
            pathParameters: {'phaseId': '${phase.id}'},
          ),
          style: OutlinedButton.styleFrom(
            alignment: Alignment.center,
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(
            StringConstants.reviewPhase,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (isCurrent) {
      return SizedBox(
        height: 40,
        child: ElevatedButton.icon(
          onPressed: () => context.goNamed(
            'modules',
            pathParameters: {'phaseId': '${phase.id}'},
          ),
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(
            StringConstants.continueLearning,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            alignment: Alignment.center,
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  Widget _buildProgressAndActions(BuildContext context, {Widget? node}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: CurriculumProgressBar(
            fraction: phase.modules.isEmpty
                ? 0.0
                : completedModules / phase.modules.length,
            isCurrent: isCurrent,
            height: 6.0,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton(context),
              node ?? const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusNode(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double size = context.isTablet ? 44.0 : nodeSize;

    if (isCompleted) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.surface, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(Icons.check_rounded, color: colorScheme.onPrimary),
      );
    } else if (isCurrent) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.surface, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(Icons.play_arrow_rounded, color: colorScheme.onPrimary),
      );
    } else {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.outlineVariant, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.lock_outline_rounded,
          color: colorScheme.outline.withValues(alpha: 0.6),
        ),
      );
    }
  }
}
