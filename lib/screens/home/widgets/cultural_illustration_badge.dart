import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// A simple, elegant, culturally inspired visual badge.
class CulturalIllustrationBadge extends StatelessWidget {
  const CulturalIllustrationBadge({
    super.key,
    this.size = 110.0,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.warmBeige.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.borderBeige,
            width: 1.0,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle radial ring
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _SubtleMotifPainter(),
              ),
            ),

            // Inner Core Medallion
            Container(
              width: size * 0.60,
              height: size * 0.60,
              decoration: BoxDecoration(
                color: AppColors.primaryMaroon,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.goldenAccent.withValues(alpha: 0.6),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.cardShadow,
                    blurRadius: 8.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.record_voice_over_rounded,
                color: AppColors.primaryCream,
                size: size * 0.28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubtleMotifPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || size.width <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6.0;

    final ringPaint = Paint()
      ..color = AppColors.borderBeige.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final dotPaint = Paint()
      ..color = AppColors.goldenAccent.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    // Draw circular guideline
    canvas.drawCircle(center, radius, ringPaint);

    // 8 clean radial dots
    const count = 8;
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi) / count;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      canvas.drawCircle(Offset(x, y), 1.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
