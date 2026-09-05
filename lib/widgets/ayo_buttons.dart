import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_dimens.dart';
import '../app/theme/app_typography.dart';

/// Primary action button in deep burgundy (#671D21) with cream/white text.
class AyoPrimaryButton extends StatelessWidget {
  const AyoPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.primaryBurgundy;
    final effectiveFg = foregroundColor ?? AppColors.cardSurface;

    final buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveFg),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...[
          Icon(icon, size: 18, color: effectiveFg),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: effectiveFg,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBg,
        foregroundColor: effectiveFg,
        disabledBackgroundColor: AppColors.borderWarm,
        disabledForegroundColor: AppColors.textMuted,
        elevation: 0,
        minimumSize: Size(isFullWidth ? double.infinity : 120, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: buttonChild,
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Secondary outlined button with burgundy border (#671D21) on parchment.
class AyoOutlinedButton extends StatelessWidget {
  const AyoOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.borderColor,
    this.textColor,
    this.isFullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.primaryBurgundy;
    final effectiveTextColor = textColor ?? AppColors.primaryBurgundy;

    final buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: effectiveTextColor),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: effectiveTextColor,
          ),
        ),
      ],
    );

    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.transparent,
        foregroundColor: effectiveTextColor,
        side: BorderSide(
          color: effectiveBorderColor,
          width: AppBorders.medium,
        ),
        minimumSize: Size(isFullWidth ? double.infinity : 120, 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: buttonChild,
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Classroom Audio Button for playing regional pronunciation in mother tongue.
class AyoAudioButton extends StatefulWidget {
  const AyoAudioButton({
    super.key,
    this.onPressed,
    this.size = 40.0,
    this.isPlaying = false,
    this.tooltip = 'Play Audio Pronunciation',
  });

  final VoidCallback? onPressed;
  final double size;
  final bool isPlaying;
  final String tooltip;

  @override
  State<AyoAudioButton> createState() => _AyoAudioButtonState();
}

class _AyoAudioButtonState extends State<AyoAudioButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AyoAudioButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _animController.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _animController.stop();
      _animController.reset();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.isPlaying
                    ? AppColors.primaryBurgundy
                    : AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isPlaying
                      ? AppColors.primaryBurgundy
                      : AppColors.borderWarm,
                  width: 1.0,
                ),
                boxShadow: widget.isPlaying ? AppShadows.cardShadow : null,
              ),
              child: Center(
                child: Icon(
                  widget.isPlaying
                      ? Icons.volume_up_rounded
                      : Icons.volume_down_rounded,
                  color: widget.isPlaying ? Colors.white : AppColors.primaryBurgundy,
                  size: widget.size * 0.52,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Back button with parchment backdrop and subtle border.
class AyoBackButton extends StatelessWidget {
  const AyoBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.borderWarm,
              width: 1.0,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
