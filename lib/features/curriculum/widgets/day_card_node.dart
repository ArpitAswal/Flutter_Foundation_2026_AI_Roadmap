import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/string_constants.dart';
import '../../../core/utils/responsive_extension.dart';
import '../../../domain/models/curriculum/lesson_day.dart';
import 'curriculum_card_node.dart';

class DayCardNode extends StatelessWidget {
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
        onTap: _getOnTap(context),
        child: Padding(
          padding: context.responsivePadding(18, 16).padding,
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
            onTap: _getOnTap(context),
            child: Padding(
              padding: context.responsivePadding(16, 8).padding,
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
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: _buildHeader(context)),
            if (context.orientation == Orientation.landscape)
              _buildStatusNode(context)
            else
              _buildChevron(context),
          ],
        ),
        _buildTitle(context),
        const SizedBox(height: 4),
        _buildDescription(context, 6),
        const Spacer(), // Ensure uniform stretch in tablet grid
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
          ? '${StringConstants.dayPrefix} ${day.day} • ${StringConstants.currentLabel}'
          : '${StringConstants.dayPrefix} ${day.day}',
      style: context.responsiveTextTheme.labelLarge?.copyWith(
        color: isCurrent
            ? colorScheme.secondaryContainer
            : (isLocked ? colorScheme.onSurfaceVariant : colorScheme.primary),
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Text(
      day.title,
      style: context.responsiveTextTheme.titleSmall?.copyWith(
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
      day.description,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: context.responsiveTextTheme.labelMedium?.copyWith(
        color: isLocked ? colorScheme.outline : colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildStatusNode(BuildContext context) {
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
        alignment: AlignmentGeometry.center,
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
}
