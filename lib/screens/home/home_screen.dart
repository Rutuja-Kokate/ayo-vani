import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_class_selection_grid.dart';
import '../live_translate/live_translate_screen.dart';
import '../validation/hitl_validation_screen.dart';

/// Screen 03 — Home / Dashboard for AYOVAANI Teacher App.
///
/// Strictly reproduces the visual design, structure, and spacing of:
/// - Screen 03: Home (Dashboard)
/// - Master Visual Design Reference
///
/// Component Structure:
/// 1. Top Header Area (Compact AyoVaani logo, greeting, and subtitle)
/// 2. Offline Status Card ("Offline Ready" with soft green/olive styling)
/// 3. Today's Lesson Section ("Mathematics", "Numbers 1–20", thumbnail, "Start Classroom →")
/// 4. Quick Tools Section (2 × 2 grid: Translate, Worksheet, Flashcards, Games)
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onNavigateToLearn,
    this.onNavigateToTools,
    this.onNavigateToProgress,
    this.onNavigateToProfile,
    this.onNavigateToTranslate,
    this.onNavigateToBalvatika,
    this.onNavigateToFirst,
    this.onNavigateToSecond,
    this.onNavigateToThird,
  });

  final VoidCallback? onNavigateToLearn;
  final VoidCallback? onNavigateToTools;
  final VoidCallback? onNavigateToProgress;
  final VoidCallback? onNavigateToProfile;
  final VoidCallback? onNavigateToTranslate;
  final VoidCallback? onNavigateToBalvatika;
  final VoidCallback? onNavigateToFirst;
  final VoidCallback? onNavigateToSecond;
  final VoidCallback? onNavigateToThird;

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);
    final cornerSize = isTablet ? 135.0 : 100.0;

    return Stack(
      children: [
        // Decorative Corner Ornaments (Behind content, pointer-events: none equivalent)
        Positioned(
          top: 0,
          left: 0,
          child: IgnorePointer(
            child: _buildCornerDecoration(isRight: false, size: cornerSize),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IgnorePointer(
            child: _buildCornerDecoration(isRight: true, size: cornerSize),
          ),
        ),

        // Main Home Screen Content
        LayoutBuilder(
          builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;

        // Responsive vertical spacing and sizing adapting naturally to available height
        final isCompactHeight = availableHeight < 700.0;

        // Shift components lower on mobile (Pixel 4)
        final topSpacing = isTablet
            ? (isCompactHeight ? 14.0 : 20.0)
            : (isCompactHeight ? 14.0 : (availableHeight * 0.032).clamp(20.0, 30.0));

        // Increased AyoVaani logo sizes for both Tablet and Mobile
        final logoHeight = isTablet
            ? (isCompactHeight ? 115.0 : 130.0)
            : (isCompactHeight ? 88.0 : (availableHeight * 0.14).clamp(98.0, 108.0));

        // Moves the main content block downward naturally towards the bottom on mobile
        final logoToGreetingSpacing = isTablet
            ? (isCompactHeight ? 18.0 : 24.0)
            : (isCompactHeight ? 20.0 : (availableHeight * 0.046).clamp(30.0, 42.0));

        final greetingToOfflineSpacing = isTablet
            ? (isCompactHeight ? 14.0 : 18.0)
            : (isCompactHeight ? 14.0 : (availableHeight * 0.026).clamp(18.0, 24.0));

        final offlineToContentSpacing = isTablet
            ? (isCompactHeight ? 20.0 : 26.0)
            : (isCompactHeight ? 16.0 : (availableHeight * 0.030).clamp(20.0, 26.0));

        final lessonToToolsSpacing = isCompactHeight
            ? 16.0
            : (availableHeight * 0.030).clamp(20.0, 26.0);

        final bottomSpacing = isTablet
            ? (isCompactHeight ? 16.0 : 24.0)
            : (isCompactHeight ? 12.0 : (availableHeight * 0.020).clamp(14.0, 22.0));

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(
            left: isTablet ? 48.0 : AppSpacing.lg,
            right: isTablet ? 48.0 : AppSpacing.lg,
            top: topSpacing,
            bottom: bottomSpacing,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 1060.0 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Center: Prominently Sized Official AyoVaani Logo
                  _buildTopLogo(logoHeight),

                  SizedBox(height: logoToGreetingSpacing),

                  // 2. Teacher Greeting + Subtitle (Main Content Start)
                  _buildGreeting(isTablet),

                  SizedBox(height: greetingToOfflineSpacing),

                  // 3. Offline Status Card (spans full width of tablet content)
                  _buildOfflineStatusCard(),

                  const SizedBox(height: 12.0),

                  // 3b. Teacher Validation HITL Card
                  _buildHitlValidationCard(context),

                  SizedBox(height: offlineToContentSpacing),

                  // 4. Main Content: 2-Column on Tablet, Single-Column on Mobile
                  if (isTablet)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Let's Start / Today's Lesson
                        Expanded(
                          child: _buildTodaysLessonSection(context, isTablet: true),
                        ),
                        const SizedBox(width: 24.0),
                        // Right Column: Classes (2 × 2 Grid)
                        Expanded(
                          child: _buildQuickToolsSection(context, isTablet: true),
                        ),
                      ],
                    )
                  else ...[
                    // Mobile: Preserves exact original single-column flow
                    _buildTodaysLessonSection(context, isTablet: false),
                    SizedBox(height: lessonToToolsSpacing),
                    _buildQuickToolsSection(context, isTablet: false),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    ),
  ],
);
  }

  /// Decorative Warli corner ornament using corner-desing.png.
  /// Top-left: normal orientation.
  /// Top-right: horizontally mirrored/flipped so the decoration faces inward correctly.
  Widget _buildCornerDecoration({
    required bool isRight,
    required double size,
  }) {
    final imageWidget = Image.asset(
      'assets/images/corner-desing.png',
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/corner-design.png',
          width: size,
          fit: BoxFit.contain,
        );
      },
    );

    return isRight
        ? Transform.flip(
            flipX: true,
            child: imageWidget,
          )
        : imageWidget;
  }

  /// 1. Top Area: Prominently Sized Centered AyoVaani Logo
  Widget _buildTopLogo(double logoHeight) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: AyoLogo(
          height: logoHeight,
        ),
      ),
    );
  }

  /// 2. Teacher Greeting + Subtitle
  Widget _buildGreeting(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warm dark brown/maroon heading
        Text(
          'Hello, Teacher',
          style: TextStyle(
            fontFamily: AppTypography.headingFontFamily,
            fontSize: isTablet ? 25.0 : 22.0,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryBurgundy,
            letterSpacing: -0.2,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 4.0),

        // Elegant subtitle
        Text(
          'Ready to inspire today?',
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  /// 2. Offline Status Card ("Offline Ready" with soft green/olive styling)
  Widget _buildOfflineStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9F5), // Light cream with very soft green tint
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0xFFD6E3D4), // Subtle soft green/olive border
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x062C4A26),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: [
          // Soft green/olive status icon circle
          Container(
            width: 32.0,
            height: 32.0,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0E4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_done_rounded,
              color: Color(0xFF4C7544),
              size: 18.0,
            ),
          ),
          const SizedBox(width: 12.0),

          // Status Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Offline Ready',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C4A26), // Deep soft olive
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // 24 lessons badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2EDDF),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        '24 lessons',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF385E32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Content synced today.',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF5E725B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHitlValidationCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFC88A22).withOpacity(0.4),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 36.0,
            height: 36.0,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              color: Color(0xFFC88A22),
              size: 20.0,
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'शिक्षक सुधार केंद्र (Teacher Validation)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2.0),
                const Text(
                  'समीक्षा करें और मॉडल सटीकता बढ़ाएं',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.0,
                    color: Color(0xFF756760),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HitlValidationScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBurgundy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
            child: const Text(
              'खोलें →',
              style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Let's Start Section with Lesson Card and "Translate →" Button
  Widget _buildTodaysLessonSection(BuildContext context, {bool isTablet = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          "Let's Start",
          style: TextStyle(
            fontFamily: AppTypography.headingFontFamily,
            fontSize: isTablet ? 20.0 : 18.0,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
        SizedBox(height: isTablet ? 12.0 : 10.0),

        // Lesson Card
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7), // Warm cream card surface
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: const Color(0xFFE8DECF), // Subtle warm border
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x084A3B32),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.all(isTablet ? 20.0 : 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lesson Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mathematics',
                          style: TextStyle(
                            fontFamily: AppTypography.headingFontFamily,
                            fontSize: isTablet ? 20.0 : 18.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Numbers 1–20',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: isTablet ? 15.0 : 14.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Class 2 • Santhali',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: isTablet ? 13.5 : 13.0,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14.0),

                  // Culturally inspired lesson thumbnail on the right side
                  Container(
                    width: isTablet ? 78.0 : 72.0,
                    height: isTablet ? 78.0 : 72.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2E6D5),
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(
                        color: const Color(0xFFE2D4C0),
                        width: 1.0,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/warli_background.png',
                          fit: BoxFit.cover,
                          alignment: const Alignment(-0.25, 0.65),
                        ),
                        Container(
                          color: const Color(0x10671D21),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 20.0 : 18.0),

              // Primary "Translate →" Button in AyoVaani Maroon Accent
              SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  onPressed: () {
                    if (onNavigateToTranslate != null) {
                      onNavigateToTranslate!();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const LiveTranslateScreen(),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBurgundy, // #671D21
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Translate',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 4. Classes Section (2 × 2 Grid: Balvatika, First, Second, Third)
  Widget _buildQuickToolsSection(BuildContext context, {bool isTablet = false}) {
    return AyoClassSelectionGrid(
      onNavigateToBalvatika: onNavigateToBalvatika,
      onNavigateToFirst: onNavigateToFirst,
      onNavigateToSecond: onNavigateToSecond,
      onNavigateToThird: onNavigateToThird,
      isTablet: isTablet,
    );
  }
}
