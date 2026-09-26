import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/utils/responsive_extension.dart';
import '../../../domain/models/curriculum/lesson_day.dart';
import 'curriculum_card_node.dart';

class DayCardNode extends StatelessWidget {
  /// Stable design token for the status node circle across viewports
  static const double nodeSize = 36.0;

  final int phaseId;
  final int moduleId;
  final LessonDay day;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;
  final bool isGridMode;
  final VoidCallback? onTap;

  const DayCardNode({
    super.key,
    required this.phaseId,
    required this.moduleId,
    required this.day,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
    this.isGridMode = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridMode) {
      return CurriculumCard(
        isLocked: isLocked,
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 15),
          child: _buildGridChild(context),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusNode(context),
        const SizedBox(width: 8),
        Expanded(
          child: CurriculumCard(
            isLocked: isLocked,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildContent(context),
            ),
          ),
        ),
      ],
    );
  }

  VoidCallback? _getOnTap(BuildContext context) {
    if (onTap != null) return onTap;
    return () {
      context.goNamed(
        'lesson',
        pathParameters: {
          'phaseId': '$phaseId',
          'moduleId': '$moduleId',
          'day': '${day.day}',
        },
      );
    };
  }

  Widget _buildGridChild(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildHeader(context)),
            const SizedBox(width: 8),
            // _buildStatusNode(context),
          ],
        ),
        const SizedBox(height: 4),
        _buildTitle(context),
        const SizedBox(height: 4),
        _buildDescription(context, 4),
        const Spacer(),
        _buildActionButton(context, buildIcon: true),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: _buildHeader(context)),
            _buildChevron(context),
          ],
        ),
        _buildTitle(context),
        const SizedBox(height: 4),
        _buildDescription(context, null),
        _buildActionButton(context),
      ],
    );
  }

  Widget _buildChevron(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Icon(
      Icons.chevron_right_rounded,
      color: isCompleted
          ? colorScheme.primary
          : isCurrent
          ? colorScheme.secondaryContainer
          : colorScheme.outlineVariant,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Text(
      isCurrent
          ? '${StringConstants.dayPrefix} ${day.day}'
          : '${StringConstants.dayPrefix} ${day.day}',
      style: theme.textTheme.labelLarge?.copyWith(
        color: isCurrent
            ? colorScheme.secondaryContainer
            : isLocked
            ? colorScheme.outline
            : colorScheme.primary,
        fontWeight: FontWeight.bold,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Text(
      day.title,
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
      day.description,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: context.subDescriptionStyle.copyWith(
        color: isLocked ? colorScheme.outline : colorScheme.onSurfaceVariant,
      ),
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
          border: Border.all(color: colorScheme.surface, width: 2),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
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
          border: Border.all(color: colorScheme.surface, width: 2),
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
          border: Border.all(color: colorScheme.outlineVariant, width: 2),
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

  Widget _buildActionButton(BuildContext context, {bool buildIcon = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            (isCompleted)
                ? SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed:  _getOnTap(context),
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.center,
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                        StringConstants.reviewDay,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : (isCurrent)
                ? SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed:  _getOnTap(context),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            if (buildIcon) _buildStatusNode(context),
          ],
        ),
      ),
    );
  }
}
