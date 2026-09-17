import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import 'widgets/phase_selection_dialog.dart';
import 'widgets/winding_levels_path.dart';

export 'widgets/winding_levels_path.dart' show LevelState, LevelData;

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

typedef _LevelData = LevelData;

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class StudentLevelsScreen extends StatefulWidget {
  const StudentLevelsScreen({
    super.key,
    this.onBack,
    this.onNavigateTab,
    this.isShellTab = false,
  });

  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;
  final bool isShellTab;

  @override
  State<StudentLevelsScreen> createState() => _StudentLevelsScreenState();
}

class _StudentLevelsScreenState extends State<StudentLevelsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final ScrollController _scrollController;
  bool _hasScrolledToBottom = false;

  static const List<_LevelData> _levels = [
    _LevelData(number: 1, label: 'Level 1', subtitle: 'Basics', state: LevelState.active),
    _LevelData(number: 2, label: 'Level 2', subtitle: 'Coming Soon', state: LevelState.locked),
    _LevelData(number: 3, label: 'Level 3', subtitle: 'Coming Soon', state: LevelState.locked),
    _LevelData(number: 4, label: 'Level 4', subtitle: 'Coming Soon', state: LevelState.locked),
    _LevelData(number: 5, label: 'Level 5', subtitle: 'Coming Soon', state: LevelState.locked),
    _LevelData(number: 6, label: 'Level 6', subtitle: 'Coming Soon', state: LevelState.locked),
    _LevelData(number: 7, label: 'Level 7', subtitle: 'Coming Soon', state: LevelState.locked),
    _LevelData(number: 8, label: 'Level 8', subtitle: 'Coming Soon', state: LevelState.locked),
    _LevelData(number: 9, label: 'Level 9', subtitle: 'Coming Soon', state: LevelState.locked),
    _LevelData(number: 10, label: 'Level 10', subtitle: 'Coming Soon', state: LevelState.locked),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scheduleScrollToBottom();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _pulseController.repeat(reverse: true);
    }
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _scheduleScrollToBottom() {
    if (_hasScrolledToBottom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasScrolledToBottom) return;
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          _hasScrolledToBottom = true;
          _scrollController.jumpTo(maxScroll);
        } else {
          // If layout extent is not yet positive, retry on the next frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _hasScrolledToBottom) return;
            if (_scrollController.hasClients) {
              _hasScrolledToBottom = true;
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _onBottomNavSelected(BuildContext context, int index) {
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(index);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _onLevelTap(BuildContext context, _LevelData level) {
    PhaseSelectionDialog.show(
      context: context,
      levelNumber: level.number,
      levelTitle: level.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final cornerSize = isTablet ? 120.0 : 88.0;

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Fixed Top-left decorative corner
              Positioned(
                top: 0,
                left: 0,
                child: IgnorePointer(
                  child: LevelCornerDecoration(isRight: false, size: cornerSize),
                ),
              ),

              // Fixed Top-right decorative corner
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: LevelCornerDecoration(isRight: true, size: cornerSize),
                ),
              ),

              // Layout: Fixed top header + Only Scrollable Level Path
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. FIXED TOP HEADER (Back button, Logo, Badge, Title, Subtitle, Leaf divider)
                  _buildFixedHeader(context, isTablet),

                  // 2. SCROLLABLE LEARNING PATH (Levels 1 to 10 only)
                  Expanded(
                    child: _buildScrollableLevelPath(context, isTablet),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.isShellTab
            ? null
            : AyoBottomNavBar(
                selectedIndex: 1,
                onItemSelected: (index) => _onBottomNavSelected(context, index),
              ),
      ),
    );
  }

  Widget _buildFixedHeader(BuildContext context, bool isTablet) {
    final logoHeight = isTablet ? 104.0 : 82.0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        isTablet ? 12.0 : 6.0,
        AppSpacing.md,
        6.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top bar with Back button & AyoVaani Logo
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 1.5,
                  shadowColor: Colors.black.withValues(alpha: 0.10),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _handleBack(context),
                    splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.12),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE8DECF),
                          width: 1.0,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              AyoLogo(height: logoHeight),
            ],
          ),
          const SizedBox(height: 8.0),

          // "For Students" badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.5),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3E8),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: const Color(0xFFB8D6B2), width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.face_rounded,
                  size: 15.0,
                  color: Color(0xFF416B3C),
                ),
                const SizedBox(width: 6.0),
                Text(
                  'For Students',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 13.0 : 12.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF416B3C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6.0),

          // "English – First Standard" Heading
          Text(
            'English \u2013 First Standard',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: isTablet ? 30.0 : 25.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3.0),

          // "Learn, practice & grow" Subtitle
          Text(
            'Learn, practice & grow',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: isTablet ? 13.5 : 12.5,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8.0),

          // Decorative burgundy leaf divider motif
          SizedBox(
            width: 110.0,
            height: 14.0,
            child: CustomPaint(
              painter: LevelLeafDividerPainter(color: AppColors.primaryBurgundy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableLevelPath(BuildContext context, bool isTablet) {
    _scheduleScrollToBottom();
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        // On tablet keep path comfortably centered
        final pathWidth = isTablet ? math.min(screenWidth, 540.0) : screenWidth;

        return SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 6.0, bottom: 8.0),
          child: Center(
            child: SizedBox(
              width: pathWidth,
              child: WindingPathView(
                levels: _levels,
                pulseAnimation: _pulseAnimation,
                onLevelTap: (level) => _onLevelTap(context, level),
              ),
            ),
          ),
        );
      },
    );
  }
}

