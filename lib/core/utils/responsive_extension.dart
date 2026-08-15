import 'package:flutter/widgets.dart';

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
}
