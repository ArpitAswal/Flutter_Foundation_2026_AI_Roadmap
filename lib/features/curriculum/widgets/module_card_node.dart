import 'package:flutter/material.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return CurriculumCard(
      isLocked: isLocked,
      isCompleted: isCompleted,
      isCurrent: isCurrent,
      onTap: () {
        context.goNamed(
          'days',
          pathParameters: {'phaseId': '$phaseId', 'moduleId': '${module.id}'},
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: (context.isTablet) ? 12.0 : 16.0,
          horizontal: (context.isTablet) ? 26.0 : 20.0,
        ),
        child: isGridMode ? _buildGridChild(context) : _buildListChild(context),
      ),
    );
  }

  Widget _buildListChild(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIconColumn(context),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 8),
              _buildTitle(context),
              const SizedBox(height: 12),
              _buildDescription(context, null),
              if (!isLocked) ...[
                const SizedBox(height: 20),
                _buildProgressBar(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridChild(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_buildHeader(context), _buildIconOnly(context)],
        ),
        const SizedBox(height: 2),
        _buildTitle(context),
        const SizedBox(height: 8),
        _buildDescription(context, 4),
        const Spacer(),
        if (!isLocked) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressText(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: _buildProgressBar(),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildIconColumn(BuildContext context) {
    return Column(
      children: [
        _buildIconOnly(context),
        if (!isLocked) ...[
          const SizedBox(height: 16),
          _buildProgressText(context),
        ],
      ],
    );
  }

  Widget _buildIconOnly(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    double width;
    double height;
    if (context.isTablet) {
      width = size.height * 0.08;
      height = size.height * 0.06;
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
          shape: (context.isTablet) ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: (context.isTablet) ? BorderRadius.circular(12) : null,
          border: Border.all(color: colorScheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
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
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          shape: (context.isTablet) ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: (context.isTablet) ? BorderRadius.circular(12) : null,
          border: Border.all(color: colorScheme.onPrimary, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
              blurRadius: 16,
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
          shape: (context.isTablet) ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: (context.isTablet) ? BorderRadius.circular(12) : null,
          border: Border.all(color: colorScheme.outlineVariant, width: 3),
          boxShadow: [
            BoxShadow(
              color: colorScheme.surfaceContainerHighest,
              blurRadius: 16,
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

  Widget _buildProgressText(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrent
            ? colorScheme.secondaryContainer.withAlpha(25)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(context.screenWidth * 0.2),
      ),
      child: Text(
        '$completedDays/${module.totalDays}',
        style: theme.textTheme.labelSmall?.copyWith(
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
    return Text(
      '${StringConstants.modulePrefix} ${module.id}',
      style: theme.textTheme.labelSmall?.copyWith(
        color: isCurrent
            ? colorScheme.secondaryContainer
            : isLocked
            ? colorScheme.outline
            : colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
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
        fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
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
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isLocked ? colorScheme.outline : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildProgressBar() {
    return CurriculumProgressBar(
      fraction: module.totalDays == 0 ? 0.0 : completedDays / module.totalDays,
      isCurrent: isCurrent,
      height: 6.0,
    );
  }
}
