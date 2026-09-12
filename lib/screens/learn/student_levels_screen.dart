import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import 'widgets/phase_selection_dialog.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

enum LevelState { active, locked }

class _LevelData {
  const _LevelData({
    required this.number,
    required this.label,
    required this.subtitle,
    required this.state,
  });

  final int number;
  final String label;
  final String subtitle;
  final LevelState state;
}

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

  @override
  void dispose() {
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
                  child: _CornerDecoration(isRight: false, size: cornerSize),
                ),
              ),

              // Fixed Top-right decorative corner
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: _CornerDecoration(isRight: true, size: cornerSize),
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
              painter: _LeafDividerPainter(color: AppColors.primaryBurgundy),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableLevelPath(BuildContext context, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        // On tablet keep path comfortably centered
        final pathWidth = isTablet ? math.min(screenWidth, 540.0) : screenWidth;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 6.0, bottom: 8.0),
          child: Center(
            child: SizedBox(
              width: pathWidth,
              child: _WindingPathView(
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

// ---------------------------------------------------------------------------
// Winding Path View
// ---------------------------------------------------------------------------

class _WindingPathView extends StatelessWidget {
  const _WindingPathView({
    required this.levels,
    required this.pulseAnimation,
    required this.onLevelTap,
  });

  final List<_LevelData> levels;
  final Animation<double> pulseAnimation;
  final ValueChanged<_LevelData> onLevelTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        const nodeSize = 82.0;
        const stepY = 142.0;
        const topPadding = 66.0;

        // Exactly 10 levels
        final totalLevels = levels.length;

        // X Positions (proportions of width):
        // Level 1: 0.40 (center-left)
        // Level 2: 0.65 (center-right)
        // Level 3: 0.34 (left)
        // Level 4: 0.63 (right)
        // Level 5: 0.37 (left)
        // Level 6: 0.65 (right)
        // Level 7: 0.34 (left)
        // Level 8: 0.63 (right)
        // Level 9: 0.36 (left)
        // Level 10: 0.50 (center)
        final xProportions = [
          0.40, // Level 1
          0.65, // Level 2
          0.34, // Level 3
          0.63, // Level 4
          0.37, // Level 5
          0.65, // Level 6
          0.34, // Level 7
          0.63, // Level 8
          0.36, // Level 9
          0.50, // Level 10
        ];

        final nodePoints = <Offset>[];
        for (var i = 0; i < totalLevels; i++) {
          final x = w * xProportions[i];
          final y = topPadding + (totalLevels - 1 - i) * stepY + (nodeSize / 2);
          nodePoints.add(Offset(x, y));
        }

        // Total height: Level 1 is nodePoints.first (lowest node).
        // The lowest visual decoration near Level 1 is the student girl at p1.dy - 10 (height 84 -> bottom at p1.dy + 74).
        // Setting totalHeight to p1.dy + 80 eliminates the excessive empty space below Level 1.
        final totalHeight = nodePoints.first.dy + 80.0;

        return SizedBox(
          width: w,
          height: totalHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Winding Road/Trail Custom Painter
              CustomPaint(
                size: Size(w, totalHeight),
                painter: _CurvedRoadPainter(nodePoints: nodePoints),
              ),

              // 2. Decorative Illustrations in Path across Levels 1-10
              _buildDecorations(w, totalHeight, nodePoints),

              // 3. Level Nodes & Wood Plaques
              for (var i = 0; i < totalLevels; i++)
                _buildNodePositioned(
                  levels[i],
                  nodePoints[i],
                  nodeSize,
                  w,
                  i,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDecorations(double w, double totalHeight, List<Offset> points) {
    // Points index:
    // points[0] = Level 1 (bottom)
    // points[1] = Level 2
    // points[2] = Level 3
    // points[3] = Level 4
    // points[4] = Level 5
    // points[5] = Level 6
    // points[6] = Level 7
    // points[7] = Level 8
    // points[8] = Level 9
    // points[9] = Level 10 (top)
    final p1 = points[0];
    final p2 = points[1];
    final p3 = points[2];
    final p4 = points[3];
    final p5 = points[4];
    final p6 = points[5];
    final p7 = points[6];
    final p8 = points[7];
    final p9 = points[8];
    final p10 = points[9];

    return Stack(
      children: [
        // ==========================================
        // LEVEL 1: Natural girl.png on right, grass1.png and grass2.png on left/bottom
        // ==========================================
        Positioned(
          right: math.max(12.0, w * 0.06),
          top: p1.dy - 18,
          child: _PngGirl(width: math.min(84.0, w * 0.22)),
        ),
        Positioned(
          left: 14.0,
          top: p1.dy + 18,
          child: const _PngGrass1(width: 38.0),
        ),
        Positioned(
          left: 48.0,
          top: p1.dy + 36,
          child: const _PngGrass2(width: 42.0),
        ),

        // ==========================================
        // LEVEL 2: house.png on left, grass2.png and grass1.png
        // ==========================================
        Positioned(
          left: math.max(12.0, w * 0.05),
          top: p2.dy - 42,
          child: _PngHouse(width: math.min(86.0, w * 0.23)),
        ),
        Positioned(
          left: math.max(14.0, w * 0.05) + 64,
          top: p2.dy + 12,
          child: const _PngGrass2(width: 40.0),
        ),
        Positioned(
          right: 18.0,
          top: p2.dy + 38,
          child: const _PngGrass1(width: 34.0),
        ),

        // ==========================================
        // LEVEL 3: grass3.png on right, grass1.png on left
        // ==========================================
        Positioned(
          right: math.max(18.0, w * 0.08),
          top: p3.dy - 22,
          child: const _PngGrass3(width: 48.0),
        ),
        Positioned(
          left: 16.0,
          top: p3.dy + 32,
          child: const _PngGrass1(width: 34.0, isFlipped: true),
        ),

        // ==========================================
        // LEVEL 4: house.png on left open area, grass3.png on right
        // ==========================================
        Positioned(
          left: math.max(14.0, w * 0.06),
          top: p4.dy - 46,
          child: _PngHouse(width: math.min(88.0, w * 0.24)),
        ),
        Positioned(
          left: math.max(14.0, w * 0.06) + 68,
          top: p4.dy + 16,
          child: const _PngGrass2(width: 38.0),
        ),
        Positioned(
          right: 14.0,
          top: p4.dy + 36,
          child: const _PngGrass3(width: 44.0),
        ),

        // ==========================================
        // LEVEL 5: girl.png on right (flipped), grass2.png & grass3.png on left
        // ==========================================
        Positioned(
          right: math.max(14.0, w * 0.07),
          top: p5.dy - 24,
          child: _PngGirl(
            width: math.min(80.0, w * 0.20),
            isFlipped: true,
          ),
        ),
        Positioned(
          right: math.max(14.0, w * 0.07) + 62,
          top: p5.dy + 20,
          child: const _PngGrass2(width: 38.0),
        ),
        Positioned(
          left: 14.0,
          top: p5.dy + 30,
          child: const _PngGrass3(width: 42.0),
        ),

        // ==========================================
        // LEVEL 6: house.png on left (flipped), grass1.png & grass2.png
        // ==========================================
        Positioned(
          left: math.max(12.0, w * 0.05),
          top: p6.dy - 44,
          child: _PngHouse(
            width: math.min(86.0, w * 0.23),
            isFlipped: true,
          ),
        ),
        Positioned(
          left: math.max(12.0, w * 0.05) + 68,
          top: p6.dy + 14,
          child: const _PngGrass1(width: 36.0),
        ),
        Positioned(
          right: 18.0,
          top: p6.dy + 36,
          child: const _PngGrass2(width: 40.0),
        ),

        // ==========================================
        // LEVEL 7: grass3.png & grass1.png on right, grass2.png on left
        // ==========================================
        Positioned(
          right: math.max(18.0, w * 0.08),
          top: p7.dy - 16,
          child: const _PngGrass3(width: 48.0),
        ),
        Positioned(
          right: math.max(16.0, w * 0.07) + 40,
          top: p7.dy + 22,
          child: const _PngGrass1(width: 34.0),
        ),
        Positioned(
          left: 16.0,
          top: p7.dy + 32,
          child: const _PngGrass2(width: 36.0, isFlipped: true),
        ),

        // ==========================================
        // LEVEL 8: girl.png on left open space, grass3.png & grass1.png
        // ==========================================
        Positioned(
          left: math.max(14.0, w * 0.06),
          top: p8.dy - 22,
          child: _PngGirl(width: math.min(80.0, w * 0.20)),
        ),
        Positioned(
          left: math.max(14.0, w * 0.06) + 66,
          top: p8.dy + 18,
          child: const _PngGrass3(width: 44.0),
        ),
        Positioned(
          right: 16.0,
          top: p8.dy + 38,
          child: const _PngGrass1(width: 34.0),
        ),

        // ==========================================
        // LEVEL 9: house.png on right, grass2.png & grass3.png on left
        // ==========================================
        Positioned(
          right: math.max(12.0, w * 0.05),
          top: p9.dy - 44,
          child: _PngHouse(width: math.min(88.0, w * 0.23)),
        ),
        Positioned(
          right: math.max(12.0, w * 0.05) + 66,
          top: p9.dy + 14,
          child: const _PngGrass2(width: 38.0),
        ),
        Positioned(
          left: 14.0,
          top: p9.dy + 30,
          child: const _PngGrass3(width: 42.0, isFlipped: true),
        ),

        // ==========================================
        // LEVEL 10: girl.png on top-left (flipped) with grass1.png, grass3.png on top-right
        // ==========================================
        Positioned(
          left: math.max(14.0, w * 0.06),
          top: p10.dy - 34,
          child: _PngGirl(
            width: math.min(78.0, w * 0.20),
            isFlipped: true,
          ),
        ),
        Positioned(
          left: math.max(14.0, w * 0.06) + 62,
          top: p10.dy + 10,
          child: const _PngGrass1(width: 36.0),
        ),
        Positioned(
          right: math.max(14.0, w * 0.06),
          top: p10.dy - 22,
          child: const _PngGrass3(width: 48.0),
        ),
        Positioned(
          right: math.max(16.0, w * 0.07),
          top: p10.dy + 24,
          child: const _PngGrass2(width: 38.0),
        ),
      ],
    );
  }

  Widget _buildNodePositioned(
    _LevelData level,
    Offset point,
    double nodeSize,
    double screenW,
    int index,
  ) {
    final isActive = level.state == LevelState.active;
    // Wood plaque position: for left-side nodes, place on right or left
    // In reference:
    // Level 1: plaque on left of node
    // Level 2: plaque on right of node
    // Level 3: plaque on left of node
    // Level 4: plaque on right of node
    // Level 5: plaque on left of node
    final isPlaqueOnRight = (index % 2 == 1);

    return Positioned(
      left: point.dx - (nodeSize / 2) - (isPlaqueOnRight ? 0 : 80),
      top: point.dy - (nodeSize / 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isPlaqueOnRight) ...[
            _WoodPlaque(label: level.label, subtitle: level.subtitle),
            const SizedBox(width: 8),
          ],
          _LevelNode(
            level: level,
            nodeSize: nodeSize,
            pulseAnimation: isActive ? pulseAnimation : null,
            onTap: () => onLevelTap(level),
          ),
          if (isPlaqueOnRight) ...[
            const SizedBox(width: 8),
            _WoodPlaque(label: level.label, subtitle: level.subtitle),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Circular Layered Level Node
// ---------------------------------------------------------------------------

class _LevelNode extends StatelessWidget {
  const _LevelNode({
    required this.level,
    required this.nodeSize,
    required this.onTap,
    this.pulseAnimation,
  });

  final _LevelData level;
  final double nodeSize;
  final VoidCallback onTap;
  final Animation<double>? pulseAnimation;

  @override
  Widget build(BuildContext context) {
    final isActive = level.state == LevelState.active;

    Widget nodeContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Platform 3D Disc
        Container(
          width: nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Layered 3D stone/wood pedestal effect
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE5D5BF), // top highlight
                Color(0xFFC7B39B), // mid surface
                Color(0xFFA69076), // bottom shaded pedestal
              ],
            ),
            boxShadow: [
              // Bottom 3D shadow
              BoxShadow(
                color: const Color(0xFF6B5845).withValues(alpha: 0.35),
                blurRadius: 8.0,
                offset: const Offset(0, 5),
              ),
              // Glow for active
              if (isActive)
                BoxShadow(
                  color: const Color(0xFFE5B560).withValues(alpha: 0.40),
                  blurRadius: 14.0,
                  spreadRadius: 2.0,
                ),
            ],
            border: Border.all(
              color: const Color(0xFFFAF2E6),
              width: 3.0,
            ),
          ),
          child: Center(
            child: Container(
              width: nodeSize * 0.68,
              height: nodeSize * 0.68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isActive
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF8B252C),
                          Color(0xFF671D21),
                          Color(0xFF4C1215),
                        ],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF9E8D7F),
                          Color(0xFF7E6E61),
                          Color(0xFF65564A),
                        ],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isActive ? const Color(0xFFE58F94) : const Color(0xFFB5A698),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '${level.number}',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: nodeSize * 0.34,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Lock icon below node (for locked levels) OR 3 Stars for Level 1
        Transform.translate(
          offset: const Offset(0, -10),
          child: isActive
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (i) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.0),
                      child: Icon(
                        Icons.star_rounded,
                        size: 16.0,
                        color: Color(0xFFEAA628),
                      ),
                    ),
                  ),
                )
              : Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7EFE4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC7B39B),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 3.0,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 14.0,
                      color: Color(0xFF6B5845),
                    ),
                  ),
                ),
        ),
      ],
    );

    if (pulseAnimation != null) {
      nodeContent = ScaleTransition(
        scale: pulseAnimation!,
        child: nodeContent,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: nodeContent,
    );
  }
}

// ---------------------------------------------------------------------------
// Wooden Plaque Label
// ---------------------------------------------------------------------------

class _WoodPlaque extends StatelessWidget {
  const _WoodPlaque({
    required this.label,
    required this.subtitle,
  });

  final String label;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Wooden board container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF8B5A3C),
                Color(0xFF6F432A),
              ],
            ),
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: const Color(0xFFA57350),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3F2516).withValues(alpha: 0.35),
                blurRadius: 3.0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFFF3E3),
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 3.0),
        Text(
          subtitle,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6F5946),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Curved Road Painter
// ---------------------------------------------------------------------------

class _CurvedRoadPainter extends CustomPainter {
  const _CurvedRoadPainter({required this.nodePoints});

  final List<Offset> nodePoints;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePoints.length < 2) return;

    // 1. Soft wide tan / cream path band
    final roadPaint = Paint()
      ..color = const Color(0xFFE6D6BC).withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 36.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 2. Dashed trail line (subtle burgundy / pinkish dash)
    final dashPaint = Paint()
      ..color = const Color(0xFFA85B4F).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(nodePoints.first.dx, nodePoints.first.dy);

    for (var i = 0; i < nodePoints.length - 1; i++) {
      final current = nodePoints[i];
      final next = nodePoints[i + 1];

      // Smooth S-curve bezier control points
      final midY = (current.dy + next.dy) / 2;
      path.cubicTo(
        current.dx,
        midY,
        next.dx,
        midY,
        next.dx,
        next.dy,
      );
    }

    // Draw wide road base
    canvas.drawPath(path, roadPaint);

    // Draw dashed trail
    _drawDashedPath(canvas, path, dashPaint, 8.0, 7.0);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path source,
    Paint paint,
    double dashWidth,
    double dashSpace,
  ) {
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final len = math.min(dashWidth, metric.length - distance);
        final extract = metric.extractPath(distance, distance + len);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CurvedRoadPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Natural PNG Illustrations from assets/images/
// ---------------------------------------------------------------------------

class _PngGirl extends StatelessWidget {
  const _PngGirl({
    this.width = 76.0,
    this.isFlipped = false,
  });

  final double width;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/girl.png',
      width: width,
      fit: BoxFit.contain,
    );
    return isFlipped ? Transform.flip(flipX: true, child: image) : image;
  }
}

class _PngHouse extends StatelessWidget {
  const _PngHouse({
    this.width = 88.0,
    this.isFlipped = false,
  });

  final double width;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/house.png',
      width: width,
      fit: BoxFit.contain,
    );
    return isFlipped ? Transform.flip(flipX: true, child: image) : image;
  }
}

class _PngGrass1 extends StatelessWidget {
  const _PngGrass1({
    this.width = 38.0,
    this.isFlipped = false,
  });

  final double width;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/grass1.png',
      width: width,
      fit: BoxFit.contain,
    );
    return isFlipped ? Transform.flip(flipX: true, child: image) : image;
  }
}

class _PngGrass2 extends StatelessWidget {
  const _PngGrass2({
    this.width = 42.0,
    this.isFlipped = false,
  });

  final double width;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/grass2.png',
      width: width,
      fit: BoxFit.contain,
    );
    return isFlipped ? Transform.flip(flipX: true, child: image) : image;
  }
}

class _PngGrass3 extends StatelessWidget {
  const _PngGrass3({
    this.width = 46.0,
    this.isFlipped = false,
  });

  final double width;
  final bool isFlipped;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/grass3.png',
      width: width,
      fit: BoxFit.contain,
    );
    return isFlipped ? Transform.flip(flipX: true, child: image) : image;
  }
}

// ---------------------------------------------------------------------------
// Corner decoration
// ---------------------------------------------------------------------------

class _CornerDecoration extends StatelessWidget {
  const _CornerDecoration({required this.isRight, required this.size});
  final bool isRight;
  final double size;

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      'assets/images/corner-design.png',
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/corner-desing.png',
        width: size,
        fit: BoxFit.contain,
      ),
    );
    return isRight ? Transform.flip(flipX: true, child: img) : img;
  }
}

// ---------------------------------------------------------------------------
// Leaf divider painter
// ---------------------------------------------------------------------------

class _LeafDividerPainter extends CustomPainter {
  const _LeafDividerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(0, cy), Offset(cx - 13, cy), linePaint);
    canvas.drawLine(Offset(cx + 13, cy), Offset(size.width, cy), linePaint);
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy + 3)
        ..quadraticBezierTo(cx - 3.2, cy - 2, cx, cy - 6.5)
        ..quadraticBezierTo(cx + 3.2, cy - 2, cx, cy + 3)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx - 1.2, cy + 3)
        ..quadraticBezierTo(cx - 7.5, cy + 2.5, cx - 8.5, cy - 1.5)
        ..quadraticBezierTo(cx - 3.5, cy - 2.5, cx - 1.2, cy + 3)
        ..close(),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx + 1.2, cy + 3)
        ..quadraticBezierTo(cx + 7.5, cy + 2.5, cx + 8.5, cy - 1.5)
        ..quadraticBezierTo(cx + 3.5, cy - 2.5, cx + 1.2, cy + 3)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _LeafDividerPainter old) => old.color != color;
}
