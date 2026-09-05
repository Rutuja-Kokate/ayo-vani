import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';

/// Reusable hardware-accelerated warm parchment radial vignette painter.
///
/// Mathematically scales an elliptical radial gradient to conform to the exact
/// screen aspect ratio (whether tall phone like Pixel 4 or wide tablet like Pixel Tablet).
///
/// Features:
/// - Luminous, soft warm cream center (#FAF3E7) for clarity and readability
/// - Seamless transition through canonical AyoVaani parchment (#EEDABC)
/// - Subtly deepened warm parchment edges (#E4CEA9)
/// - Very soft, warm aged parchment corners (#D9BC93)
/// - Hardware-accelerated native shader pipeline with anti-aliasing for zero banding
class AyoParchmentBackgroundPainter extends CustomPainter {
  const AyoParchmentBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final scaleY = size.height / size.width;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(1.0, scaleY);

    // In this normalized space, the bounding box is a square of dimension size.width.
    // Distance from center to side edges is size.width * 0.5.
    // Distance from center to corners is size.width * 0.7071.
    // A radius of size.width * 0.72 places side edges at r ≈ 0.69 and corners at r ≈ 0.98.
    final radius = size.width * 0.72;

    final paint = Paint()
      ..isAntiAlias = true
      ..shader = ui.Gradient.radial(
        Offset.zero,
        radius,
        const [
          AppColors.parchmentCenter, // #FAF3E7 - Clean, luminous warm cream
          AppColors.parchmentInner,  // #F6EAD5 - Soft cream transition
          AppColors.parchmentMid,    // #EEDABC - Core AyoVaani parchment
          AppColors.parchmentSide,   // #E4CEA9 - Warm golden edge sand
          AppColors.parchmentCorner, // #D9BC93 - Soft aged parchment vignette corner
        ],
        const [
          0.0,
          0.32,
          0.65,
          0.86,
          1.0,
        ],
      );

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.width,
        height: size.width,
      ),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AyoParchmentBackgroundPainter oldDelegate) => false;
}

/// Reusable full-screen background container for AYOVAANI.
///
/// Wraps any screen in the warm parchment radial vignette while preserving
/// the exact layering order:
/// 1. Warm parchment gradient (this background)
/// 2. Existing Warli PNG artwork
/// 3. Existing UI components
/// 4. Existing text/buttons/icons/navigation
class AyoScreenBackground extends StatelessWidget {
  const AyoScreenBackground({
    super.key,
    required this.child,
    this.borderRadius,
  });

  final Widget child;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget background = CustomPaint(
      painter: const AyoParchmentBackgroundPainter(),
      child: child,
    );

    if (borderRadius != null) {
      background = ClipRRect(
        borderRadius: borderRadius!,
        child: background,
      );
    }

    return background;
  }
}
