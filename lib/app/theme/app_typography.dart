import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized Typography configuration for AYOVAANI.
///
/// Follows Master Visual Design Reference:
/// - Headings: DM Serif Display (elegant, Indian editorial heritage, warm)
/// - Body/UI: Inter (clean, modern, highly readable interface typography)
/// - Proper fallback chain for offline environments and Indian regional scripts
abstract final class AppTypography {
  // ==========================================
  // 1. Font Families
  // ==========================================

  /// Heading Font Family: DM Serif Display
  static String get headingFontFamily =>
      GoogleFonts.dmSerifDisplay().fontFamily ?? 'serif';

  /// Body & UI Font Family: Inter
  static String get bodyFontFamily =>
      GoogleFonts.inter().fontFamily ?? 'sans-serif';

  // ==========================================
  // 2. Headings (DM Serif Display)
  // ==========================================

  /// Hero Display Heading (30sp, DM Serif Display)
  static TextStyle get displayLarge => TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 30.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.2,
      );

  /// Main Screen Heading (26sp, DM Serif Display)
  static TextStyle get headlineLarge => TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 26.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.25,
      );

  /// Section Heading (21sp, DM Serif Display)
  static TextStyle get headlineMedium => TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 21.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: -0.15,
        height: 1.3,
      );

  /// Sub-section Heading (18sp, DM Serif Display)
  static TextStyle get headlineSmall => TextStyle(
        fontFamily: headingFontFamily,
        fontSize: 18.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        letterSpacing: -0.1,
        height: 1.35,
      );

  // ==========================================
  // 3. Card Titles & Subtitles (Inter)
  // ==========================================

  /// Major Card Title (16sp, SemiBold, Inter)
  static TextStyle get titleLarge => TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.1,
        height: 1.35,
      );

  /// Standard Card / Item Title (15sp, SemiBold, Inter)
  static TextStyle get titleMedium => TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 15.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  /// Secondary Title / Form Label (13.5sp, Medium, Inter)
  static TextStyle get titleSmall => TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // ==========================================
  // 4. Body Content (Inter)
  // ==========================================

  /// Primary Body Text (15sp, Regular, Inter)
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  /// Standard Body Text (14sp, Regular, Inter)
  static TextStyle get bodyMedium => TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.45,
      );

  /// Small Metadata & Captions (12sp, Regular, Inter)
  static TextStyle get bodySmall => TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // ==========================================
  // 5. Buttons, Badges & Labels (Inter SemiBold)
  // ==========================================

  /// Button Label (14.5sp, SemiBold, Inter)
  static TextStyle get labelLarge => TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBurgundy,
        letterSpacing: 0.1,
      );

  /// Badge & Tag Label (12sp, SemiBold, Inter)
  static TextStyle get labelMedium => TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.2,
      );

  /// Micro Label / Overline (11sp, SemiBold, Inter)
  static TextStyle get labelSmall => TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 11.0,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.3,
      );

  // ==========================================
  // 6. Complete TextTheme
  // ==========================================
  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );

  // Backward compatibility alias
  static String get serifFontFamily => headingFontFamily;
  static String get sansFontFamily => bodyFontFamily;
}
