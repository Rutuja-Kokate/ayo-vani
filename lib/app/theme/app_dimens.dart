import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Spacing constants for consistent layout throughout AYOVAANI.
abstract final class AppSpacing {
  /// 2.0 dp - Micro padding or tiny divider gap
  static const double xxs = 2.0;

  /// 4.0 dp - Extra small gap (icon-to-text)
  static const double xs = 4.0;

  /// 8.0 dp - Small spacing (badge padding, compact gap)
  static const double sm = 8.0;

  /// 12.0 dp - Medium-small spacing
  static const double md = 12.0;

  /// 16.0 dp - Standard spacing (screen margins, standard card padding)
  static const double lg = 16.0;

  /// 20.0 dp - Generous card padding & section gaps
  static const double xl = 20.0;

  /// 24.0 dp - Section gaps & tablet horizontal padding
  static const double xxl = 24.0;

  /// 32.0 dp - Major module separator
  static const double xxxl = 32.0;

  /// 44.0 dp - Hero spacing
  static const double huge = 44.0;
}

/// Centralized Corner Radius constants.
/// Designed for refined paper-panel and button aesthetics (14-18px for cards, 12px for buttons).
abstract final class AppRadius {
  /// 4.0 dp - Subtle rounded tags
  static const double xs = 4.0;

  /// 8.0 dp - Small badges and compact controls
  static const double sm = 8.0;

  /// 12.0 dp - Standard buttons, inputs, and action tiles
  static const double md = 12.0;

  /// 16.0 dp - Standard cards and paper panels (14-18px range)
  static const double lg = 16.0;

  /// 20.0 dp - Elevated dialogs and bottom sheets
  static const double xl = 20.0;

  /// 24.0 dp - Prominent modal sheets
  static const double xxl = 24.0;

  /// 999.0 dp - Full pill radius (used exclusively for status badges & chips)
  static const double pill = 999.0;

  // BorderRadius helpers
  static final BorderRadius xsBorder = BorderRadius.circular(xs);
  static final BorderRadius smBorder = BorderRadius.circular(sm);
  static final BorderRadius mdBorder = BorderRadius.circular(md);
  static final BorderRadius lgBorder = BorderRadius.circular(lg);
  static final BorderRadius xlBorder = BorderRadius.circular(xl);
  static final BorderRadius xxlBorder = BorderRadius.circular(xxl);
  static final BorderRadius pillBorder = BorderRadius.circular(pill);
}

/// Centralized Border and Stroke constants.
abstract final class AppBorders {
  /// 1.0 dp - Standard subtle card & container border
  static const double thin = 1.0;

  /// 1.5 dp - Outlined buttons & active focus states
  static const double medium = 1.5;

  /// 2.0 dp - Selected interactive states
  static const double thick = 2.0;

  /// Standard subtle warm card border side (#D8C6AC)
  static const BorderSide cardBorder = BorderSide(
    color: AppColors.borderWarm,
    width: thin,
  );

  /// Subtle light divider border side (#E5D5BF)
  static const BorderSide lightBorder = BorderSide(
    color: AppColors.borderLight,
    width: thin,
  );

  /// Active burgundy border side (#671D21)
  static const BorderSide activeBurgundyBorder = BorderSide(
    color: AppColors.primaryBurgundy,
    width: medium,
  );
}

/// Centralized Shadows & Elevations.
abstract final class AppShadows {
  /// Very soft warm card shadow (rest state)
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.cardShadow,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ];

  /// Elevated shadow for modals and bottom sheets
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: AppColors.elevatedShadow,
      blurRadius: 14.0,
      offset: Offset(0, 4),
    ),
  ];
}
