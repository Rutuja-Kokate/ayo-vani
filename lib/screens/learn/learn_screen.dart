import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_class_selection_grid.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';

/// Screen: Learn (Class Selection) for AYOVAANI Teacher App.
///
/// Replaces the old Lessons/Games/Flashcards/Offline tabs with the
/// unified Class Selection experience.
///
/// Classes available:
/// 1. Balvatika (Coming Soon)
/// 2. First / Grade 1 (English is available, others Coming Soon)
/// 3. Second / Grade 2 (Coming Soon)
/// 4. Third / Grade 3 (Coming Soon)
class LearnScreen extends StatelessWidget {
  const LearnScreen({
    super.key,
    this.onBack,
    this.onNavigateToBalvatika,
    this.onNavigateToFirst,
    this.onNavigateToSecond,
    this.onNavigateToThird,
    this.onNavigateTab,
    this.isShellTab = false,
  });

  final VoidCallback? onBack;
  final VoidCallback? onNavigateToBalvatika;
  final VoidCallback? onNavigateToFirst;
  final VoidCallback? onNavigateToSecond;
  final VoidCallback? onNavigateToThird;
  final ValueChanged<int>? onNavigateTab;
  final bool isShellTab;

  void _handleBack(BuildContext context) {
    if (onBack != null) {
      onBack!();
    } else if (isShellTab && onNavigateTab != null) {
      onNavigateTab!(0); // Switch to Home tab
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _onBottomNavSelected(BuildContext context, int index) {
    if (index == 1) {
      // Already on Learn tab
      return;
    }
    if (onNavigateTab != null) {
      onNavigateTab!(index);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);
    final cornerSize = isTablet ? 135.0 : 95.0;

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Top-left Warli Corner Ornament
              Positioned(
                top: 0,
                left: 0,
                child: IgnorePointer(
                  child: _buildCornerDecoration(
                    isRight: false,
                    size: cornerSize,
                  ),
                ),
              ),

              // Top-right Warli Corner Ornament (Horizontally Mirrored)
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: _buildCornerDecoration(
                    isRight: true,
                    size: cornerSize,
                  ),
                ),
              ),

              // Bottom-left Warli Corner Ornament
              Positioned(
                bottom: 0,
                left: 0,
                child: IgnorePointer(
                  child: Transform.flip(
                    flipY: true,
                    child: _buildCornerDecoration(
                      isRight: false,
                      size: cornerSize * 0.85,
                    ),
                  ),
                ),
              ),

              // Bottom-right Warli Corner Ornament
              Positioned(
                bottom: 0,
                right: 0,
                child: IgnorePointer(
                  child: Transform.flip(
                    flipX: true,
                    flipY: true,
                    child: _buildCornerDecoration(
                      isRight: true,
                      size: cornerSize * 0.85,
                    ),
                  ),
                ),
              ),

              // Main Scrollable Content
              LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = isTablet ? 44.0 : AppSpacing.lg;
                  final contentMaxWidth = isTablet ? 1060.0 : double.infinity;

                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: isTablet ? 14.0 : 12.0,
                      bottom: 24.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Top Bar: Back Button + Centered AyoVaani Logo
                            _buildTopBar(context, isTablet),

                            SizedBox(height: isTablet ? 14.0 : 12.0),

                            // 2. Section Header: Title & Subtitle
                            _buildHeader(isTablet),

                            SizedBox(height: isTablet ? 18.0 : 16.0),

                            // 3. Class Selection 2 × 2 Grid
                            AyoClassSelectionGrid(
                              onNavigateToBalvatika: onNavigateToBalvatika,
                              onNavigateToFirst: onNavigateToFirst,
                              onNavigateToSecond: onNavigateToSecond,
                              onNavigateToThird: onNavigateToThird,
                              isTablet: isTablet,
                              showSectionTitle: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: isShellTab
            ? null
            : AyoBottomNavBar(
                selectedIndex: 1,
                onItemSelected: (index) => _onBottomNavSelected(context, index),
              ),
      ),
    );
  }

  /// Top decorative Warli corner ornament.
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

  /// Top Bar with Back Button at top-left and Centered AyoVaani Logo.
  Widget _buildTopBar(BuildContext context, bool isTablet) {
    final logoHeight = isTablet ? 100.0 : 80.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Back button on the top-left
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(20.0),
            child: InkWell(
              onTap: () => _handleBack(context),
              borderRadius: BorderRadius.circular(20.0),
              splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.12),
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: const Color(0xFFE8DECF),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.textPrimary,
                  size: 24.0,
                ),
              ),
            ),
          ),
        ),

        // Centered AyoVaani Brand Logo
        AyoLogo(
          height: logoHeight,
        ),
      ],
    );
  }

  /// Header with Title and Subtitle.
  Widget _buildHeader(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class Selection',
          style: TextStyle(
            fontFamily: AppTypography.headingFontFamily,
            fontSize: isTablet ? 24.0 : 20.0,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          'Select your classroom stage to start learning',
          style: TextStyle(
            fontFamily: AppTypography.bodyFontFamily,
            fontSize: isTablet ? 14.5 : 13.5,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
