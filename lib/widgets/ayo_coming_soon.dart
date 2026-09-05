import 'package:flutter/material.dart';
import '../app/theme/app_colors.dart';
import '../app/theme/app_typography.dart';

/// Reusable "Coming Soon" UI component for AYOVAANI.
///
/// Strictly matches the AYOVAANI aesthetic:
/// - Warm cream background
/// - Soft beige card surface with gentle warm borders
/// - Deep maroon primary typography
/// - Elegant clock/sparkle/lock icon
/// - Minimal, premium, and welcoming (never looks like an error state)
class AyoComingSoonCard extends StatelessWidget {
  const AyoComingSoonCard({
    super.key,
    this.title = 'Coming Soon',
    this.message = 'This learning content will be available soon.',
    this.badgeText = 'Coming Soon',
    this.icon = Icons.schedule_rounded,
    this.isCompact = false,
  });

  final String title;
  final String message;
  final String badgeText;
  final IconData icon;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7), // Warm cream card surface
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0xFFE8DECF), // Subtle warm border
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x064A3B32),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 16.0 : 24.0,
        vertical: isCompact ? 18.0 : 28.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant Icon Container
          Container(
            width: isCompact ? 46.0 : 54.0,
            height: isCompact ? 46.0 : 54.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF7EBE7), // Soft warm terracotta tint
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFEAD8D0),
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              size: isCompact ? 22.0 : 26.0,
              color: AppColors.primaryBurgundy, // Deep maroon
            ),
          ),
          SizedBox(height: isCompact ? 12.0 : 16.0),

          // Heading: Deep maroon
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: isCompact ? 17.0 : 20.0,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBurgundy,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 6.0),

          // Supporting message
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: isCompact ? 12.5 : 13.5,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: isCompact ? 12.0 : 16.0),

          // Elegant Status Pill: [ Coming Soon ]
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EDE2), // Soft beige pill
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: const Color(0xFFE2D6C5),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 13.0,
                  color: const Color(0xFF7E6452),
                ),
                const SizedBox(width: 5.0),
                Text(
                  badgeText,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7E6452),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
