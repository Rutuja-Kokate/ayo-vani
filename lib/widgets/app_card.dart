import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_dimens.dart';

/// Reusable modern rounded card with warm tones, soft borders, and subtle shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppRadius.lg,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.hasShadow = true,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool hasShadow;

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.borderWarm,
          width: AppBorders.thin,
        ),
        boxShadow: hasShadow ? AppShadows.cardShadow : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.08),
          highlightColor: AppColors.surfaceContainer.withValues(alpha: 0.3),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
