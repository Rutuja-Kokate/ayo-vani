import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../models/subject_data.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_coming_soon.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/ayo_subject_card.dart';

/// Chapter data model for early learning foundation stage & curriculum listings.
class BalvatikaChapter {
  const BalvatikaChapter({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
    this.topic,
    this.lesson,
    this.emoji,
    this.chapterImage,
  });

  final int number;
  final String title;
  final String description;
  final IconData icon;
  final String? topic;
  final String? lesson;
  final String? emoji;
  final String? chapterImage;
}

/// Screen: Balvatika / Foundation Stage for AYOVAANI Teacher App.
///
/// In the current MVP scope, all Balvatika learning content is Coming Soon.
/// Communicates the coming soon state cleanly while preserving the exact
/// AYOVAANI visual language, layout, branding, and responsive behavior.
class BalvatikaScreen extends StatefulWidget {
  const BalvatikaScreen({
    super.key,
    this.title = 'Balvatika',
    this.subtitle = 'Foundation Stage | Learn, Listen, Speak',
    this.description = 'Explore foundation stage learning modules and activities.',
    this.totalChapters = 12,
    this.learningLevel = 'Beginner',
    this.chapters,
    this.onBack,
    this.onNavigateTab,
  });

  final String title;
  final String subtitle;
  final String description;
  final int totalChapters;
  final String learningLevel;
  final List<BalvatikaChapter>? chapters;
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;

  @override
  State<BalvatikaScreen> createState() => _BalvatikaScreenState();
}

class _BalvatikaScreenState extends State<BalvatikaScreen> {
  int _navIndex = 0;

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _onBottomNavSelected(int index) {
    if (index == 0) {
      _handleBack();
    } else {
      if (widget.onNavigateTab != null) {
        widget.onNavigateTab!(index);
      } else {
        setState(() {
          _navIndex = index;
        });
        Navigator.of(context).pop();
      }
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
                            _buildTopBar(isTablet),

                            SizedBox(height: isTablet ? 14.0 : 12.0),

                            // 2. Balvatika Header: Title Info + Info Card
                            _buildBalvatikaHeader(isTablet),

                            SizedBox(height: isTablet ? 18.0 : 16.0),

                            // 3. Primary Coming Soon Card
                            const AyoComingSoonCard(
                              title: 'Balvatika',
                              message:
                                  'Learning content is coming soon.\nFoundational language modules, stories, and sensory games are currently in development.',
                              badgeText: 'Coming Soon',
                              icon: Icons.hourglass_top_rounded,
                            ),

                            SizedBox(height: isTablet ? 18.0 : 16.0),

                            // 4. Planned Foundation Modules (All Coming Soon, Disabled)
                            _buildModulesContainer(isTablet),

                            SizedBox(height: isTablet ? 16.0 : 14.0),

                            // 5. Encouragement Info Card
                            _buildCurriculumNoticeCard(isTablet),
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
        bottomNavigationBar: AyoBottomNavBar(
          selectedIndex: _navIndex,
          onItemSelected: _onBottomNavSelected,
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

  /// 1. Top Bar: Back Button at top-left, Centered AyoVaani Logo
  Widget _buildTopBar(bool isTablet) {
    final logoHeight = isTablet ? 100.0 : 80.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(20.0),
            child: InkWell(
              onTap: _handleBack,
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
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x084A3B32),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  size: 26.0,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: AyoLogo(
            height: logoHeight,
            assetPath: 'assets/images/ayovaani_logo.png',
          ),
        ),
      ],
    );
  }

  /// 2. Header: Balvatika Foundation Stage
  Widget _buildBalvatikaHeader(bool isTablet) {
    final titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: isTablet ? 62.0 : 54.0,
          height: isTablet ? 62.0 : 54.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF7EBE7),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: const Color(0xFFE8DECF),
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
                alignment: const Alignment(-0.3, 0.4),
              ),
              Container(
                color: const Color(0x10671D21),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: isTablet ? 26.0 : 22.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBurgundy,
                  letterSpacing: -0.2,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 3.0),
              Text(
                widget.subtitle,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: isTablet ? 13.5 : 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8B4B3E),
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                widget.description,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: isTablet ? 13.0 : 12.0,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final infoCard = Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFE8DECF),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x064A3B32),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isTablet ? 115.0 : 95.0,
            height: isTablet ? 62.0 : 54.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF2E6D5),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: const Color(0xFFE2D4C0),
                width: 1.0,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/warli_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(width: 14.0),
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Foundation Modules',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF765E49),
                  ),
                ),
                Text(
                  '3 Modules',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: isTablet ? 21.0 : 19.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Current Status',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF765E49),
                  ),
                ),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8C7C6D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: titleBlock),
          const SizedBox(width: 18.0),
          infoCard,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 12.0),
          infoCard,
        ],
      );
    }
  }

  /// 4. Planned Foundation Modules (All Coming Soon)
  Widget _buildModulesContainer(bool isTablet) {
    final modules = Subject.balvatikaSubjects;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0xFFE8DECF),
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
      padding: EdgeInsets.all(isTablet ? 18.0 : 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFF8B4B3E),
              borderRadius: BorderRadius.circular(18.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.child_care_rounded,
                  color: Colors.white,
                  size: 16.0,
                ),
                const SizedBox(width: 6.0),
                Text(
                  'Curriculum Modules',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 16.0 : 12.0),

          // Modules list: All disabled with Coming Soon
          Column(
            children: [
              for (int i = 0; i < modules.length; i++) ...[
                AyoSubjectCard(
                  subject: modules[i],
                  onTap: null, // Non-clickable
                  isTablet: isTablet,
                ),
                if (i < modules.length - 1) const SizedBox(height: 10.0),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 5. Encouragement Info Card
  Widget _buildCurriculumNoticeCard(bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFBF7F0),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFEADFCF),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20.0 : 16.0,
        vertical: 14.0,
      ),
      child: Row(
        children: [
          Container(
            width: 38.0,
            height: 38.0,
            decoration: const BoxDecoration(
              color: Color(0xFFF7EBE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppColors.primaryBurgundy,
              size: 20.0,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Early Learning Focus',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Balvatika content is currently being curated in regional tribal languages.',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.0,
                    color: AppColors.textSecondary,
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
