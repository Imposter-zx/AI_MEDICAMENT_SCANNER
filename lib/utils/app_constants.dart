

/// App-wide constants
class AppConstants {
  // Spacing
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Animation durations
  static const Duration durationVeryFast = Duration(milliseconds: 150);
  static const Duration durationFast = Duration(milliseconds: 300);
  static const Duration durationNormal = Duration(milliseconds: 500);
  static const Duration durationSlow = Duration(milliseconds: 800);

  // Opacity values
  static const double opacityDisabled = 0.5;
  static const double opacityHint = 0.6;
  static const double opacityHover = 0.8;
}

/// App strings (localization happens in app_localizations.dart)
class AppStrings {
  static const String appName = 'AI Medicament Scanner';
  static const String settings = 'Settings';
  static const String language = 'Language';
  static const String theme = 'Theme';
  static const String aboutApp = 'About';
  static const String version = 'Version';
}
