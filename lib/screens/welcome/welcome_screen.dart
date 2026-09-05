import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/ayo_buttons.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/ayo_warli_village_art.dart';
import '../main_shell_screen.dart';

/// Screen 02: AYOVAANI Welcome / Teacher Entry Screen.
///
/// Refined to match Screen 02 in the Master Reference:
/// - Prominently sized official AyoVaani PNG logo as the main visual element
/// - Balanced, cohesive vertical layout (Logo → "Welcome, Teacher" → Subtitle → Continue)
/// - Rich, handcrafted Warli village, sacred tree, and schoolhouse illustration at the bottom
/// - Warm parchment radial vignette background
/// - Teacher-only classroom entry
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    this.onContinue,
  });

  /// Optional callback for custom navigation or testing.
  final VoidCallback? onContinue;

  void _handleContinue(BuildContext context) {
    if (onContinue != null) {
      onContinue!();
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainShellScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = Responsive.isTabletOrLarger(context);

    // Responsive element sizing
    final logoHeight = isTablet
        ? (size.height * 0.26).clamp(190.0, 240.0)
        : (size.height * 0.22).clamp(150.0, 185.0);

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Authentic Warli Village Decorative Artwork Layer at the bottom (Complete, uncropped)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AyoWarliVillageArt(),
          ),

          // 2. Main Content: Prominent Logo, Welcome Text, and Continue Button
          SafeArea(
            child: Align(
              alignment: isTablet ? Alignment.topCenter : Alignment.center,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: isTablet ? 36.0 : 0.0,
                ),
                child: ResponsiveContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: isTablet ? AppSpacing.xl : AppSpacing.md),

                      // Prominently Sized Official AyoVaani Logo (Preserving exact proportions)
                      AyoLogo(
                        variant: AyoLogoVariant.hero,
                        height: logoHeight,
                        assetPath: 'assets/images/ayovaani_logo.png',
                      ),

                      const SizedBox(height: AppSpacing.lg + 2),

                      // "Welcome, Teacher" Heading
                      Text(
                        'Welcome, Teacher',
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontSize: 27.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.xs + 2),

                      // "This app works best offline." Subtitle
                      Text(
                        'This app works best offline.',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppSpacing.xl + 4),

                      // Deep Burgundy "Continue" Action Button
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: AyoPrimaryButton(
                          label: 'Continue',
                          isFullWidth: true,
                          onPressed: () => _handleContinue(context),
                        ),
                      ),

                      // Proportional breathing space above the Warli characters
                      SizedBox(
                        height: isTablet ? 32.0 : 95.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}
