import 'package:flutter/material.dart';
import '../../../core/utils/responsive_extension.dart';

class CurriculumHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

  const CurriculumHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            textAlign: textAlign,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: context.subDescriptionStyle,
            textAlign: textAlign,
          ),
        ],
      ),
    );
  }
}
