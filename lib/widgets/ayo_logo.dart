import 'package:flutter/material.dart';

/// Display variant for the AYOVAANI brand logo.
enum AyoLogoVariant {
  /// Prominent top-center logo for Home screen & Welcome/Splash
  hero,

  /// Compact header mark for secondary screen top bars
  compact,

  /// Small standalone brand mark
  mark,
}

/// Centralized AYOVAANI brand logo component.
///
/// Strictly uses the official asset `assets/images/ayovaani_logo.png` containing:
/// - Mother and child illustration
/// - Maroon/burgundy artwork & olive botanical accent
/// - "AyoVaani" wordmark & "MOTHER'S VOICE, CHILD'S FUTURE." tagline
///
/// Rules:
/// - Preserves exact proportions with [BoxFit.contain]
/// - Never stretched or modified
/// - No synthetic shapes or artificial background containers
class AyoLogo extends StatelessWidget {
  const AyoLogo({
    super.key,
    this.variant = AyoLogoVariant.compact,
    this.height,
    this.width,
    this.assetPath = 'assets/images/ayovaani_logo.png',
  });

  final AyoLogoVariant variant;
  final double? height;
  final double? width;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    double defaultHeight;

    switch (variant) {
      case AyoLogoVariant.hero:
        defaultHeight = 125.0;
        break;
      case AyoLogoVariant.compact:
        defaultHeight = 42.0;
        break;
      case AyoLogoVariant.mark:
        defaultHeight = 36.0;
        break;
    }

    final effectiveHeight = height ?? defaultHeight;

    return Image.asset(
      assetPath,
      height: effectiveHeight,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        // Fallback: try .jpeg if .png wasn't found, or show clear brand text
        return Image.asset(
          'assets/images/ayovaani_logo.jpeg',
          height: effectiveHeight,
          width: width,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: const Text(
              'AYOVAANI',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}
