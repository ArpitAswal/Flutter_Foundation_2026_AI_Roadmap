import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  /// The current screen width
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// The current screen height
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Returns true if the device is a tablet (width >= 600px)
  bool get isTablet => screenWidth >= 600;

  /// Returns true if the device is a small phone (width <= 360px)
  bool get isSmallPhone => screenWidth <= 360;

  /// Returns true if the device is a normal phone (width > 360px and < 600px)
  bool get isNormalPhone => !isSmallPhone && !isTablet;

  /// Returns true if the device is a wide tablet/landscape iPad (width >= 1024px)
  bool get isWideTablet => screenWidth >= 1024;

  /// Returns the current device orientation
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Responsive app bar title style
  TextStyle get appBarTitleStyle {
    final theme = Theme.of(this);

    return (isTablet
                ? theme.textTheme.headlineMedium
                : theme.textTheme.titleMedium)
            ?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ) ??
        const TextStyle();
  }

  /// Responsive body subtitle style
  TextStyle get subDescriptionStyle {
    final theme = Theme.of(this);

    return (isTablet ? theme.textTheme.bodyMedium : theme.textTheme.bodySmall)
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant) ??
        const TextStyle();
  }

  /// Provides stable EdgeInsets based on horizontal and vertical values.
  EdgeInsets responsiveInsets(double horizontal, double vertical) {
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  /// Provides a scaled Padding based on the current device dimensions.
  /// Retained for backwards compatibility across existing call sites.
  Padding responsivePadding(double x, double y) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: x, vertical: y),
    );
  }

  /// Provides a stable BorderRadius design token across devices.
  BorderRadiusGeometry get responsiveCircularRadius =>
      const BorderRadius.all(Radius.circular(16.0));

  /// Provides stable semantic TextTheme design tokens across viewports.
  /// Preserves readability and system accessibility scaling.
  TextTheme get responsiveTextTheme {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 64 / 57,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 52 / 45,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 44 / 36,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 40 / 32,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 36 / 28,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 32 / 24,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 28 / 22,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 24 / 16,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 20 / 14,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 24 / 16,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 20 / 14,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 16 / 12,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 20 / 14,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 16 / 12,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 16 / 11,
      ),
    );
  }
}
