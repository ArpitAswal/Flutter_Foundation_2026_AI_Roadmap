import 'package:flutter/material.dart';

class CurriculumProgressBar extends StatelessWidget {
  final double fraction;
  final bool isCurrent;
  final double height;

  const CurriculumProgressBar({
    super.key,
    required this.fraction,
    this.isCurrent = true,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraction.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: isCurrent
                ? LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondaryContainer,
                    ],
                  )
                : null,
            color: isCurrent ? null : colorScheme.primary,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(90),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}
