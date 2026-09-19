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

  /// Provides a scaled Padding based on the current device dimensions.
  Padding responsivePadding(double x, double y) {
    double getResponsiveVerticalPadding(double value) {
      if (value == 0) {
        return 0;
      } else if (isWideTablet) {
        return value + 4;
      } else if (isTablet) {
        return value + 4;
      } else if (isSmallPhone) {
        return value - 4;
      } else {
        return value;
      }
    }

    double getResponsiveHorizontalPadding(value) {
      if (value == 0) {
        return 0;
      }
      if (isWideTablet) {
        return value + 10.0;
      } else if (isTablet) {
        return value + 6.0;
      } else if (isSmallPhone) {
        return value - 4.0;
      } else {
        return value;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getResponsiveHorizontalPadding(x),
        vertical: getResponsiveVerticalPadding(y),
      ),
    );
  }

  /// Provides a scaled Height based on the current device dimensions.
  double responsiveHeightSpace(double h) {
    if (isTablet || isWideTablet) {
      return screenHeight * (h * 1.4);
    } else if (isSmallPhone) {
      return screenHeight * (h * 0.6);
    } else {
      return screenHeight * h;
    }
  }

  /// Provides a scaled BorderRadius based on the current device dimensions.
  BorderRadiusGeometry get responsiveCircularRadius {
    double getResponsiveRadius(double base, double tablet, double small) {
      if (isWideTablet) {
        return tablet + (tablet / 2);
      } else if (isTablet) {
        return tablet;
      } else if (isSmallPhone) {
        return small;
      } else {
        return base;
      }
    }

    return BorderRadiusGeometry.circular(getResponsiveRadius(16, 24, 12));
  }

  /// Provides a scaled TextTheme based on the current device dimensions.
  /// Base sizes assume a normal phone.
  TextTheme get responsiveTextTheme {
    final theme = Theme.of(this).textTheme;

    double getResponsiveSize(
      double baseSize,
      double tabletSize,
      double smallSize,
    ) {
      if (isWideTablet) {
        return tabletSize * 1.1; // Slightly larger on wide screens
      }
      if (isTablet) return tabletSize;
      if (isSmallPhone) return smallSize;
      return baseSize;
    }

    return theme.copyWith(
      // Display
      displayLarge: theme.displayLarge?.copyWith(
        fontSize: getResponsiveSize(48, 56, 36),
      ),
      displayMedium: theme.displayMedium?.copyWith(
        fontSize: getResponsiveSize(36, 44, 28),
      ),
      displaySmall: theme.displaySmall?.copyWith(
        fontSize: getResponsiveSize(32, 40, 24),
      ),

      // Headline
      headlineLarge: theme.headlineLarge?.copyWith(
        fontSize: getResponsiveSize(28, 34, 22),
      ),
      headlineMedium: theme.headlineMedium?.copyWith(
        fontSize: getResponsiveSize(24, 28, 20),
      ),
      headlineSmall: theme.headlineSmall?.copyWith(
        fontSize: getResponsiveSize(20, 24, 18),
      ),

      // Title
      titleLarge: theme.titleLarge?.copyWith(
        fontSize: getResponsiveSize(24, 28, 20),
      ),
      titleMedium: theme.titleMedium?.copyWith(
        fontSize: getResponsiveSize(18, 22, 16),
      ),
      titleSmall: theme.titleSmall?.copyWith(
        fontSize: getResponsiveSize(16, 18, 14),
      ),

      // Body
      bodyLarge: theme.bodyLarge?.copyWith(
        fontSize: getResponsiveSize(18, 20, 16),
      ),
      bodyMedium: theme.bodyMedium?.copyWith(
        fontSize: getResponsiveSize(16, 18, 14),
      ),
      bodySmall: theme.bodySmall?.copyWith(
        fontSize: getResponsiveSize(14, 16, 12),
      ),

      // Label
      labelLarge: theme.labelLarge?.copyWith(
        fontSize: getResponsiveSize(14, 16, 12),
      ),
      labelMedium: theme.labelMedium?.copyWith(
        fontSize: getResponsiveSize(12, 14, 10),
      ),
      labelSmall: theme.labelSmall?.copyWith(
        fontSize: getResponsiveSize(12, 14, 10),
      ),
    );
  }
}
