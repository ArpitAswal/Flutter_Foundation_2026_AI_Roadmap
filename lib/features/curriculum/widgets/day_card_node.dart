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
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 26.0),
          child: _buildGridChild(context),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusNode(context),
        const SizedBox(width: 12),
        Expanded(
          child: CurriculumCard(
            isLocked: isLocked,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            onTap: _getOnTap(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 20.0,
              ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: _buildHeader(context)),
            if (!isLocked) ...[
              const SizedBox(width: 12),
              _buildChevron(context),
            ],
            // _buildStatusNode(context),
          ],
        ),
        const SizedBox(height: 8),
        _buildTitle(context),
        const SizedBox(height: 4),
        _buildDescription(context, 4),
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
            if (!isLocked) ...[_buildChevron(context)],
          ],
        ),
        const SizedBox(height: 4),
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
      color: isCompleted ? colorScheme.primary : colorScheme.secondaryContainer,
      size: (context.isTablet) ? 40 : 20,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Text(
      isCurrent
          ? '${StringConstants.dayPrefix} ${day.day} • ${StringConstants.currentLabel}'
          : '${StringConstants.dayPrefix} ${day.day}',
      style: theme.textTheme.labelSmall?.copyWith(
        color: isCurrent
            ? colorScheme.secondaryContainer
            : (isLocked ? colorScheme.onSurfaceVariant : colorScheme.primary),
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
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
        color: colorScheme.onSurface,
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
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildStatusNode(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    double width;
    double height;
    if (context.isTablet) {
      width = size.height * 0.08;
      height = size.height * 0.08;
    } else {
      width = size.width * 0.08;
      height = size.width * 0.08;
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
