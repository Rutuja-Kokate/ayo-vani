import 'package:flutter/material.dart';

/// Centralized Color Palette for AYOVAANI.
///
/// Strictly aligned with the Master Visual Design Reference:
/// - Rich warm parchment background (#EEDABC)
/// - Deep burgundy / maroon primary brand color (#671D21)
/// - Terracotta accent (#A85B4F)
/// - Warm brown (#765E49)
/// - Muted olive green (#526B4F)
/// - Dark brown typography (#251E11)
/// - Warm gold accent (#C0A993)
/// - Soft sand / subtle borders (#D8C6AC)
/// - Parchment surfaces (#F2E0C2, #F5E7CC, #F8EBD5)
abstract final class AppColors {
  // ==========================================
  // 1. Background Hierarchy (Rich Warm Parchment)
  // ==========================================

  /// Primary App Background (#EEDABC) - visibly rich and parchment-toned
  static const Color background = Color(0xFFEEDABC);

  /// Parchment Vignette Gradient Colors
  /// Center of screen: clean, luminous, soft warm cream
  static const Color parchmentCenter = Color(0xFFFAF3E7);

  /// Inner radial bridge: soft warm parchment transition
  static const Color parchmentInner = Color(0xFFF6EAD5);

  /// Mid-field parchment tone: matches canonical AyoVaani background
  static const Color parchmentMid = Color(0xFFEEDABC);

  /// Screen edges & sides: gently deepened warm golden sand
  static const Color parchmentSide = Color(0xFFE4CEA9);

  /// Screen corners: subtle warm aged parchment vignette tone
  static const Color parchmentCorner = Color(0xFFD9BC93);

  /// Main Surface (#F2E0C2) - app bars, navigation containers, sheets
  static const Color surface = Color(0xFFF2E0C2);

  /// Card Surface (#F5E7CC) - standard educational paper panels
  static const Color cardSurface = Color(0xFFF5E7CC);

  /// Elevated / Light Surface (#F8EBD5) - highlight cards, popups
  static const Color surfaceElevated = Color(0xFFF8EBD5);

  /// Sub-container / Inactive Well (#E5CFB0)
  static const Color surfaceContainer = Color(0xFFE5CFB0);

  // ==========================================
  // 2. Primary Brand & Secondary Palette
  // ==========================================

  /// Primary Burgundy / Maroon (#671D21) - main action, headings, active states
  static const Color primaryBurgundy = Color(0xFF671D21);

  /// Terracotta / Muted Earthy Red (#A85B4F) - secondary accents, language tags
  static const Color secondaryTerracotta = Color(0xFFA85B4F);

  /// Warm Brown (#765E49) - subtitles, secondary text, metadata
  static const Color warmBrown = Color(0xFF765E49);

  /// Muted Olive Green (#526B4F) - offline-ready status, verified badges, mastery
  static const Color oliveGreen = Color(0xFF526B4F);

  /// Soft Olive Tint (#E2EADF) - background pill for olive badges
  static const Color oliveGreenLight = Color(0xFFE2EADF);

  /// Dark Brown / Primary Text (#251E11) - high-legibility dark brown typography
  static const Color textPrimary = Color(0xFF251E11);

  /// Secondary Text Tone (#765E49)
  static const Color textSecondary = Color(0xFF765E49);

  /// Muted Text Tone (#95806E)
  static const Color textMuted = Color(0xFF95806E);

  // ==========================================
  // 3. Cultural & Supporting Accents
  // ==========================================

  /// Warm Gold / Cultural Accent (#C0A993) - Warli motif highlights, halo outlines
  static const Color warmGold = Color(0xFFC0A993);

  /// Soft Sand / Border Tone (#D8C6AC) - card outlines, dividers, input borders
  static const Color softSand = Color(0xFFD8C6AC);

  /// Subtle Border (#D8C6AC)
  static const Color borderWarm = Color(0xFFD8C6AC);

  /// Light Border (#E5D5BF)
  static const Color borderLight = Color(0xFFE5D5BF);

  /// Soft Burgundy Tint (#F0DFE1) - badge backgrounds
  static const Color burgundyLight = Color(0xFFF0DFE1);

  /// Soft Terracotta Tint (#F5E5E2) - badge backgrounds
  static const Color terracottaLight = Color(0xFFF5E5E2);

  /// Soft Gold Tint (#F5EFE6)
  static const Color goldLight = Color(0xFFF5EFE6);

  /// Deep Rust / Error Red (#9E2A2B)
  static const Color errorRust = Color(0xFF9E2A2B);

  /// Light Rust Tint (#F6DFDF)
  static const Color errorRustLight = Color(0xFFF6DFDF);

  /// Card Shadow Color (soft warm brown shadow)
  static const Color cardShadow = Color(0x12251E11);

  /// Elevated Shadow Color (dialogs, sheets)
  static const Color elevatedShadow = Color(0x1F251E11);

  // ==========================================
  // 4. Aliases for Compatibility
  // ==========================================
  static const Color primaryCream = background;
  static const Color primaryMaroon = primaryBurgundy;
  static const Color darkMaroon = Color(0xFF4C1417);
  static const Color warmBeige = surfaceContainer;
  static const Color darkBrown = textPrimary;
  static const Color softGreen = oliveGreen;
  static const Color lightGreen = oliveGreenLight;
  static const Color ivoryWhite = cardSurface;
  static const Color borderBeige = borderWarm;
  static const Color mutedBrown = textSecondary;
  static const Color subtleMaroon = burgundyLight;
  static const Color goldenAccent = warmGold;
  static const Color warmAmber = Color(0xFFB8782E);
  static const Color warmAmberLight = Color(0xFFFAECD5);
}
