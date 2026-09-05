import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_dimens.dart';
import '../app/theme/app_typography.dart';

/// Warli / Varli Chitrakala-inspired geometric ornamental divider.
///
/// Embodies subtle cultural visual identity:
/// - Fine central axis in soft sand (#D8C6AC)
/// - Subtle repeating diamond and dot rhythm in burgundy (#671D21) and gold (#C0A993)
/// - Non-intrusive, respectful, elegant
class AyoWarliDivider extends StatelessWidget {
  const AyoWarliDivider({
    super.key,
    this.height = 6.0,
    this.color = AppColors.primaryBurgundy,
    this.accentColor = AppColors.warmGold,
    this.margin = const EdgeInsets.symmetric(vertical: AppSpacing.md),
  });

  final double height;
  final Color color;
  final Color accentColor;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _WarliPatternPainter(
            primaryColor: color,
            accentColor: accentColor,
          ),
        ),
      ),
    );
  }
}

class _WarliPatternPainter extends CustomPainter {
  _WarliPatternPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  final Color primaryColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || size.width <= 0 || !size.height.isFinite || size.height <= 0) {
      return;
    }

    final linePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.18)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    final centerDotPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.60)
      ..style = PaintingStyle.fill;

    final centerY = size.height / 2;

    // Draw subtle central baseline
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      linePaint,
    );

    // Draw repeating subtle Warli geometric diamond and dot motifs
    const step = 28.0;
    for (double x = step / 2; x < size.width; x += step) {
      // Small geometric diamond
      final path = Path()
        ..moveTo(x, centerY - 2.5)
        ..lineTo(x + 2.5, centerY)
        ..lineTo(x, centerY + 2.5)
        ..lineTo(x - 2.5, centerY)
        ..close();
      canvas.drawPath(path, dotPaint);

      // Micro dot in between
      if (x + (step / 2) < size.width) {
        canvas.drawCircle(
          Offset(x + (step / 2), centerY),
          1.2,
          centerDotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WarliPatternPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor;
  }
}

/// Standardized Section Header with heritage serif title, optional action, and optional Warli motif.
class AyoSectionHeader extends StatelessWidget {
  const AyoSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionTap,
    this.showDivider = false,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: AppTypography.headingFontFamily,
                      fontSize: 19.0,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 13.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (actionLabel != null && onActionTap != null) ...[
              const SizedBox(width: AppSpacing.md),
              InkWell(
                onTap: onActionTap,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel!,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBurgundy,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primaryBurgundy,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        if (showDivider) const AyoWarliDivider(height: 5),
      ],
    );
  }
}
