import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

/// Centralized Material 3 ThemeData configuration for AYOVAANI.
abstract final class AppTheme {
  /// Light Theme with rich warm parchment background (#EEDABC),
  /// deep burgundy primary (#671D21), terracotta accents (#A85B4F),
  /// and DM Serif Display + Inter typography.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryBurgundy,
      onPrimary: Colors.white,
      primaryContainer: AppColors.burgundyLight,
      onPrimaryContainer: AppColors.primaryBurgundy,
      secondary: AppColors.secondaryTerracotta,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.terracottaLight,
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.warmGold,
      onTertiary: AppColors.textPrimary,
      tertiaryContainer: AppColors.goldLight,
      onTertiaryContainer: AppColors.textPrimary,
      error: AppColors.errorRust,
      onError: Colors.white,
      errorContainer: AppColors.errorRustLight,
      onErrorContainer: AppColors.errorRust,
      surface: AppColors.cardSurface,
      onSurface: AppColors.textPrimary,
      surfaceContainerLowest: AppColors.surfaceElevated,
      surfaceContainerLow: AppColors.cardSurface,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surfaceContainer,
      surfaceContainerHighest: AppColors.borderWarm,
      outline: AppColors.borderWarm,
      outlineVariant: AppColors.borderLight,
      shadow: AppColors.cardShadow,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,

      // Centralized Typography
      textTheme: AppTypography.textTheme,
      fontFamily: AppTypography.bodyFontFamily,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMedium,
        iconTheme: const IconThemeData(
          color: AppColors.primaryBurgundy,
          size: 22,
        ),
      ),

      // Card Theme (Paper panel styling)
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: AppBorders.cardBorder,
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Navigation Bar (Phone)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryBurgundy,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        height: 72,
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white, size: 24);
          }
          return const IconThemeData(color: AppColors.warmBrown, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBurgundy,
            );
          }
          return TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.warmBrown,
          );
        }),
      ),

      // Navigation Rail (Tablet)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        indicatorColor: AppColors.primaryBurgundy,
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 24),
        unselectedIconTheme: const IconThemeData(color: AppColors.warmBrown, size: 24),
        selectedLabelTextStyle: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBurgundy,
        ),
        unselectedLabelTextStyle: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.warmBrown,
        ),
        useIndicator: true,
      ),

      // Primary Button Style (Deep Burgundy, 12px radius)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBurgundy,
          foregroundColor: AppColors.surfaceElevated,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md + 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Outlined Button Style (Parchment surface, Burgundy border)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primaryBurgundy,
          side: const BorderSide(
            color: AppColors.primaryBurgundy,
            width: AppBorders.medium,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration (Dropdowns & Form Fields)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: AppBorders.cardBorder,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: AppBorders.cardBorder,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: AppBorders.activeBurgundyBorder,
        ),
        labelStyle: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 14.0,
          color: AppColors.textSecondary,
        ),
        hintStyle: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 14.0,
          color: AppColors.textMuted,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        disabledColor: AppColors.borderLight,
        selectedColor: AppColors.primaryBurgundy,
        secondarySelectedColor: AppColors.primaryBurgundy,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.xs + 2,
        ),
        labelStyle: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          side: const BorderSide(color: AppColors.borderWarm, width: 0.8),
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.borderWarm,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }
}
