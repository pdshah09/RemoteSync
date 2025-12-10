class ResponsiveHelper {
  static int getSystemPowerColumns(double width) {
    if (width >= 900) return 8;
    if (width >= 600) return 2;
    return 2;
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
}
