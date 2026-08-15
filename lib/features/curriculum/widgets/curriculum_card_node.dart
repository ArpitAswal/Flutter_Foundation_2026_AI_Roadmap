import 'package:flutter/material.dart';
import 'package:flutter_foundation/core/utils/responsive_extension.dart';

class CurriculumCard extends StatelessWidget {
  final bool isLocked;
  final bool isCompleted;
  final bool isCurrent;
  final Widget child;
  final VoidCallback? onTap;

  const CurriculumCard({
    super.key,
    required this.isLocked,
    required this.isCompleted,
    required this.isCurrent,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final curve = (context.screenWidth * (context.isTablet ? 0.02 : 0.04));

    final cardDecoration = isCurrent
        ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(curve),
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(51)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.secondaryContainer.withAlpha(25),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          )
        : isCompleted
        ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(curve),
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(51)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withAlpha(8),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          )
        : BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(curve),
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(51)),
          );

    Widget cardContent = Container(
      decoration: cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(curve),
        child: Stack(
          children: [
            child,
            if (isCompleted)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: (context.isTablet) ? 12 : 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(curve),
                      bottomLeft: Radius.circular(curve),
                    ),
                  ),
                ),
              ),
            if (isCurrent)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: (context.isTablet) ? 12 : 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(curve),
                      bottomLeft: Radius.circular(curve),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (onTap != null && !isLocked) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(curve),
        child: cardContent,
      );
    }

    return Opacity(opacity: isLocked ? 0.5 : 1.0, child: cardContent);
  }
}
