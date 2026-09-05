import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_dimens.dart';
import '../app/theme/app_typography.dart';

/// Linear progress bar in burgundy / olive with warm background track.
class AyoLinearProgress extends StatelessWidget {
  const AyoLinearProgress({
    super.key,
    required this.progress,
    this.height = 6.0,
    this.activeColor,
    this.trackColor,
    this.showLabel = false,
    this.label,
  });

  /// Value from 0.0 to 1.0
  final double progress;
  final double height;
  final Color? activeColor;
  final Color? trackColor;
  final bool showLabel;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final effectiveActiveColor = activeColor ??
        (clamped >= 1.0 ? AppColors.oliveGreen : AppColors.primaryBurgundy);
    final effectiveTrackColor = trackColor ?? AppColors.surfaceContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label ?? 'Progress',
                style: TextStyle(
                  fontFamily: AppTypography.sansFontFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(clamped * 100).toInt()}%',
                style: TextStyle(
                  fontFamily: AppTypography.sansFontFamily,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700,
                  color: effectiveActiveColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: effectiveTrackColor,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clamped,
            child: Container(
              decoration: BoxDecoration(
                color: effectiveActiveColor,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Circular progress indicator with warm cultural styling.
class AyoCircularProgress extends StatelessWidget {
  const AyoCircularProgress({
    super.key,
    required this.progress,
    this.size = 54.0,
    this.strokeWidth = 5.0,
    this.activeColor,
    this.trackColor,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Color? activeColor;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final effectiveActiveColor = activeColor ??
        (clamped >= 1.0 ? AppColors.oliveGreen : AppColors.primaryBurgundy);
    final effectiveTrackColor = trackColor ?? AppColors.surfaceContainer;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: clamped,
            strokeWidth: strokeWidth,
            backgroundColor: effectiveTrackColor,
            valueColor: AlwaysStoppedAnimation<Color>(effectiveActiveColor),
            strokeCap: StrokeCap.round,
          ),
          Text(
            '${(clamped * 100).toInt()}%',
            style: TextStyle(
              fontFamily: AppTypography.sansFontFamily,
              fontSize: size * 0.24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Multi-step indicator for multi-part lessons, quizzes, and worksheets.
class AyoStepProgress extends StatelessWidget {
  const AyoStepProgress({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor,
  });

  final int totalSteps;
  final int currentStep;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = activeColor ?? AppColors.primaryBurgundy;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < totalSteps; i++) ...[
          Container(
            width: i == currentStep ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= currentStep
                  ? effectiveColor
                  : AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
          if (i < totalSteps - 1) const SizedBox(width: AppSpacing.xs),
        ],
      ],
    );
  }
}
