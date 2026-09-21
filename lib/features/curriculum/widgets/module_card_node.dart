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
        padding: context.responsivePadding(18, 10).padding,
        child: isGridMode ? _buildGridChild(context) : _buildListChild(context),
      ),
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
        _buildProgressBar(context),
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
        _buildProgressBar(context),
      ],
    );
  }

  Widget _buildIconOnly(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    double width;
    double height;
    if (context.isTablet && context.orientation == Orientation.landscape) {
      width = (size.width * 0.1).clamp(40, 80);
      height = (size.height * 0.08).clamp(40, 60);
    } else if (context.isSmallPhone) {
      width = (size.width * 0.07).clamp(20, 50);
      height = width;
    } else {
      width = (size.width * 0.08).clamp(30.0, 60.0);
      height = width;
    }

    if (isCompleted) {
      return Container(
        width: width,
        height: height,
        alignment: AlignmentGeometry.center,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          shape:
              (context.isTablet && context.orientation == Orientation.landscape)
              ? BoxShape.rectangle
              : BoxShape.circle,
          borderRadius:
              (context.isTablet && context.orientation == Orientation.landscape)
              ? BorderRadius.circular(12)
              : null,
          border: Border.all(
            color: colorScheme.onPrimary,
            width: (context.isSmallPhone) ? 2 : 3,
          ),
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
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          shape:
              (context.isTablet && context.orientation == Orientation.landscape)
              ? BoxShape.rectangle
              : BoxShape.circle,
          borderRadius:
              (context.isTablet && context.orientation == Orientation.landscape)
              ? BorderRadius.circular(12)
              : null,
          border: Border.all(
            color: colorScheme.onPrimary,
            width: (context.isSmallPhone) ? 2 : 3,
          ),
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
        alignment: AlignmentGeometry.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape:
              (context.isTablet && context.orientation == Orientation.landscape)
              ? BoxShape.rectangle
              : BoxShape.circle,
          borderRadius:
              (context.isTablet && context.orientation == Orientation.landscape)
              ? BorderRadius.circular(12)
              : null,
          border: Border.all(
            color: colorScheme.outlineVariant,
            width: (context.isSmallPhone) ? 2 : 3,
          ),
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

  Widget _buildProgressText(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: context.responsivePadding(14, 6).padding,
      decoration: BoxDecoration(
        color: isCurrent
            ? colorScheme.secondaryContainer.withValues(alpha: 0.1)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: context.responsiveCircularRadius,
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
        Text(
          '${StringConstants.modulePrefix} ${module.id}',
          style: context.responsiveTextTheme.labelSmall?.copyWith(
            color: isCurrent
                ? colorScheme.secondaryContainer
                : isLocked
                ? colorScheme.outline
                : colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        (!isLocked) ? _buildProgressText(context) : _buildIconOnly(context),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Text(
      module.title,
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
      module.subtitle,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: context.responsiveTextTheme.bodySmall?.copyWith(
        color: isLocked ? colorScheme.outline : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    if (!isLocked) {
      return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: CurriculumProgressBar(
              fraction: module.totalDays == 0
                  ? 0.0
                  : completedDays / module.totalDays,
              isCurrent: isCurrent,
              height: context.responsiveHeightSpace(
                  context.isSmallPhone ? 0.015 : 0.008
              ),
            ),
          ),
          SizedBox(width: 12.0),
          _buildIconOnly(context),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
