import 'package:flutter/material.dart';

/// Authentic Warli village painting artwork component for Screen 02 (Welcome / Login).
///
/// Strictly uses the official transparent PNG asset ssets/images/warli_background.png
/// containing the authentic Warli village scene with hut, trees, mountains, plants, birds,
/// and people dancing.
///
/// Rules:
/// - Original colors and appearance are strictly preserved (no opacity, filters, or overlays)
/// - Scales proportionally and never distorts or crops
/// - Uses [BoxFit.contain] to ensure the complete artwork is fully visible
/// - Derives height proportionally from the original PNG aspect ratio (633x394)
/// - Wrapped in [IgnorePointer] so it behaves purely as a decorative background layer
class AyoWarliVillageArt extends StatelessWidget {
  const AyoWarliVillageArt({
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
