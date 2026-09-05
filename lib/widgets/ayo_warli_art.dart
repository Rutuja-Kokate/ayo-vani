import 'package:flutter/material.dart';

/// Authentic Warli / Varli Chitrakala decorative bottom illustration.
///
/// Features:
/// - Uses the authentic transparent PNG asset ssets/images/warli_background.png
/// - Detailed Warli village scene with hut, trees, mountains, plants, birds, and people dancing
/// - Natural aspect ratio strictly preserved (no stretching, distortion, or cropping)
/// - Proportional width and height calculation to ensure the COMPLETE artwork is visible on both phone and tablet
/// - Unaltered colors and appearance (no opacity reduction, blur, filters, or overlays)
/// - Uses [BoxFit.contain] to guarantee zero clipping
/// - Wrapped in [IgnorePointer] so it never interferes with user interaction
class AyoWarliBottomArt extends StatelessWidget {
  const AyoWarliBottomArt({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.bottomCenter,
    this.assetPath = 'assets/images/warli_background.png',
    this.opacity = 1.0,
  });

  /// Original Warli PNG dimensions: 633 x 394.
  static const double originalWidth = 633.0;
  static const double originalHeight = 394.0;
  static const double originalAspectRatio = originalWidth / originalHeight; // ~1.6066

  final double? height;
  final double? width;
  final BoxFit fit;
  final Alignment alignment;
  final String assetPath;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final targetWidth = width ?? constraints.maxWidth;
          final proportionalHeight = targetWidth.isFinite && targetWidth > 0
              ? targetWidth / originalAspectRatio
              : originalHeight;
          final effectiveHeight = height ?? proportionalHeight;

          return SizedBox(
            width: targetWidth,
            height: effectiveHeight,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              alignment: alignment,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}
