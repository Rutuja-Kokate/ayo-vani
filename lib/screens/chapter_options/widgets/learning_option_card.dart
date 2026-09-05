import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

/// Reusable Learning Option Card for Chapter Options.
///
/// Features:
/// - Distinctive themed outline border
/// - Warm cream surface background
/// - Left block with activity icon, bold title, and subtitle
/// - Right block with rich visual preview illustration
/// - Tap animation and ink splash
class LearningOptionCard extends StatelessWidget {
  const LearningOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.borderColor,
    required this.iconWidget,
    required this.illustration,
    required this.onTap,
    this.isTablet = true,
  });

  final String title;
  final String subtitle;
  final Color borderColor;
  final Widget iconWidget;
  final Widget illustration;
  final VoidCallback onTap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDFBF7),
      borderRadius: BorderRadius.circular(20.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        splashColor: borderColor.withValues(alpha: 0.12),
        highlightColor: borderColor.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: borderColor,
              width: 1.6,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A4A3B32),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20.0 : 16.0,
            vertical: isTablet ? 18.0 : 16.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Content: Action Icon + Title + Subtitle
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon
                    iconWidget,
                    SizedBox(width: isTablet ? 16.0 : 12.0),

                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontSize: isTablet ? 22.0 : 18.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: isTablet ? 13.5 : 12.0,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: isTablet ? 14.0 : 10.0),

              // Right Content: Visual Activity Illustration Preview
              illustration,
            ],
          ),
        ),
      ),
    );
  }
}
