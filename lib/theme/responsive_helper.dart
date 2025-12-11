import 'package:flutter/material.dart';

class ResponsiveHelper {
  static int getSystemPowerColumns(double width) {
    if (width >= 900) return 8;
    if (width >= 600) return 3;
    return 3;
  }

  static int getMediaColumns(double width) {
    if (width >= 900) return 6;
    if (width >= 600) return 4;
    return 2;
  }

  static double getPadding(double width) {
    if (width >= 900) return 24;
    if (width >= 600) return 20;
    return 16;
  }

  static double getSpacing(double width) {
    if (width >= 900) return 16;
    if (width >= 600) return 14;
    return 12;
  }

  // NEW: Add utility button height
  static double getUtilityButtonHeight(double width) {
    if (width >= 900) return 120;  // Smaller on desktop
    if (width >= 600) return 160;
    return 200;  // Taller on mobile
  }

  // Add these methods to ResponsiveHelper class
  static EdgeInsets getDialogInsetPadding(double width) {
    if (width >= 900) return const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
    if (width >= 600) return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  static EdgeInsets getDialogContentPadding(double width) {
    if (width >= 900) return const EdgeInsets.all(24);
    if (width >= 600) return const EdgeInsets.all(20);
    return const EdgeInsets.all(16);
  }


}
