import 'package:flutter/material.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/string_constants.dart';
import '../../../domain/models/curriculum/lesson_module.dart';
import 'curriculum_card_node.dart';
import 'curriculum_progress_bar.dart';

class ModuleCardNode extends StatelessWidget {
  final int phaseId;
  final LessonModule module;
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;
  final int completedDays;
  final bool isGridMode;

  const ModuleCardNode({
    super.key,
    required this.phaseId,
    required this.module,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.completedDays,
    this.isGridMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return (isGridMode)
        ? CurriculumCard(
            isLocked: isLocked,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 15),
              child: _buildGridChild(context),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIconOnly(context),
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

  Widget _buildListChild(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        _buildTitle(context),
        const SizedBox(height: 4),
        _buildDescription(context, null),
        _buildActionButtons(context),
      ],
    );
  }

  Widget _buildGridChild(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        _buildTitle(context),
        const SizedBox(height: 4),
        _buildDescription(context, 6),
        Spacer(),
        _buildActionButtons(context, buildIcon: true),
      ],
    );
  }

  Widget _buildIconOnly(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final double size = context.isTablet ? 44.0 : 36.0;

    if (isCompleted) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape: BoxShape.circle,
          border: Border.all(color: colorScheme.onPrimary, width: 2),
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
          border: Border.all(color: colorScheme.onPrimary, width: 2),
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

  Widget _buildProgressText(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
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
        '$completedDays/${module.totalDays}',
        style: context.responsiveTextTheme.labelSmall?.copyWith(
          color: isCurrent
              ? colorScheme.secondaryContainer
              : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '${StringConstants.modulePrefix} ${module.id}',
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
        _buildProgressText(context),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Text(
      module.title,
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
      module.subtitle,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: context.subDescriptionStyle.copyWith(
        color: isLocked ? colorScheme.outline : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, {bool buildIcon = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: CurriculumProgressBar(
            fraction: module.totalDays == 0
                ? 0.0
                : completedDays / module.totalDays,
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
              if (buildIcon) _buildIconOnly(context),
            ],
          ),
        ),
      ],
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
            'days',
            pathParameters: {'phaseId': '$phaseId', 'moduleId': '${module.id}'},
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
            StringConstants.reviewModule,
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
            'days',
            pathParameters: {'phaseId': '$phaseId', 'moduleId': '${module.id}'},
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
}
