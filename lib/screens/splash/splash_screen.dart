import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/ayo_warli_art.dart';
import '../welcome/welcome_screen.dart';

/// Screen 01: AYOVAANI Splash Screen.
///
/// Strictly matches Screen 01 in the Master Reference:
/// - Warm parchment radial vignette background
/// - Centered official AyoVaani PNG logo in the upper-middle region
/// - Subtle minimal deep burgundy loading indicator below the logo
/// - Traditional Warli geometric decorative bottom illustration
/// - Automatic smooth transition to Screen 02 (WelcomeScreen)
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2500),
    this.onTransitionComplete,
  });

  /// Duration before transitioning to the next screen.
  final Duration duration;

  /// Optional transition callback for testing or custom navigation.
  final VoidCallback? onTransitionComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _transitionTimer;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();

    // Set transition timer
    _transitionTimer = Timer(widget.duration, _navigateToNext);
  }

  void _navigateToNext() {
    if (!mounted) return;

    if (widget.onTransitionComplete != null) {
      widget.onTransitionComplete!();
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);
    final logoHeight = isTablet ? 190.0 : 150.0;
    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // 1. Warli Village Decorative Illustration (Complete artwork with natural aspect ratio at bottom)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AyoWarliBottomArt(),
            ),

            // 2. Center Content: Official Logo + Clean Breathing Space + Subtle Loading Indicator
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),

                      // Official AyoVaani PNG Logo
                      AyoLogo(
                        variant: AyoLogoVariant.hero,
                        height: logoHeight,
                        assetPath: 'assets/images/ayovaani_logo.png',
                      ),

                      const SizedBox(height: AppSpacing.xxl + 8),

                      // Minimalist Loading Indicator in Deep Burgundy (#671D21)
                      const SizedBox(
                        width: 26.0,
                        height: 26.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryBurgundy,
                          ),
                        ),
                      ),

                      const Spacer(flex: 4),

                      // Breathing space above the Warli village scene
                      SizedBox(height: isTablet ? 140.0 : 100.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
