import 'package:flutter/material.dart';
import '../../../app/responsive/responsive.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../widgets/ayo_bottom_nav_bar.dart';
import '../../../widgets/ayo_logo.dart';
import '../../../widgets/ayo_screen_background.dart';

class GameItem {
  GameItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.category,
    this.isSorted = false,
  });

  final String id;
  final String name;
  final String emoji;
  final String category; // e.g. 'Red' or 'Yellow'
  bool isSorted;
}

/// Reusable Games Screen for ANY chapter of ANY class.
class GamesScreen extends StatefulWidget {
  const GamesScreen({
    super.key,
    required this.className,
    required this.chapterNumber,
    required this.chapterName,
    this.onBack,
    this.onNavigateTab,
  });

  final String className;
  final int chapterNumber;
  final String chapterName;
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  int _navIndex = 1;
  int _score = 0;
  String? _selectedCategory;

  late List<GameItem> _items;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _score = 0;
    _selectedCategory = null;
    final lower = widget.chapterName.toLowerCase();

    if (lower.contains('fruit') || lower.contains('color')) {
      _items = [
        GameItem(id: '1', name: 'Apple', emoji: '🍎', category: 'Red'),
        GameItem(id: '2', name: 'Strawberry', emoji: '🍓', category: 'Red'),
        GameItem(id: '3', name: 'Banana', emoji: '🍌', category: 'Yellow'),
        GameItem(id: '4', name: 'Lemon', emoji: '🍋', category: 'Yellow'),
        GameItem(id: '5', name: 'Grapes', emoji: '🍇', category: 'Purple'),
        GameItem(id: '6', name: 'Orange', emoji: '🍊', category: 'Orange'),
      ];
    } else {
      _items = [
        GameItem(id: '1', name: 'Item 1', emoji: '🌟', category: 'Group A'),
        GameItem(id: '2', name: 'Item 2', emoji: '⭐', category: 'Group A'),
        GameItem(id: '3', name: 'Item 3', emoji: '🔷', category: 'Group B'),
        GameItem(id: '4', name: 'Item 4', emoji: '🔶', category: 'Group B'),
      ];
    }
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _onBottomNavSelected(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(index);
    } else {
      setState(() => _navIndex = index);
    }
  }

  void _onItemTap(GameItem item) {
    if (item.isSorted) return;

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select a basket first, then tap an item to sort it!'),
          duration: Duration(milliseconds: 1500),
          backgroundColor: Color(0xFFA85B4F),
        ),
      );
      return;
    }

    if (item.category == _selectedCategory) {
      setState(() {
        item.isSorted = true;
        _score += 10;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Correct! ${item.emoji} sorted into $_selectedCategory basket! (+10 pts)'),
          duration: const Duration(milliseconds: 1000),
          backgroundColor: const Color(0xFF385E32),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oops! ${item.name} belongs to the ${item.category} basket. Try again!'),
          duration: const Duration(milliseconds: 1200),
          backgroundColor: const Color(0xFFB33222),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);
    final allSorted = _items.every((it) => it.isSorted);

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Corner Ornaments
              Positioned(
                top: 0,
                left: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/corner-design.png',
                    width: isTablet ? 120.0 : 85.0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: Transform.flip(
                    flipX: true,
                    child: Image.asset(
                      'assets/images/corner-design.png',
                      width: isTablet ? 120.0 : 85.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // Content
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: isTablet ? 48.0 : AppSpacing.lg,
                  right: isTablet ? 48.0 : AppSpacing.lg,
                  top: 14.0,
                  bottom: 28.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 960.0 : double.infinity,
                    ),
                    child: Column(
                      children: [
                        _buildTopBar(isTablet),
                        const SizedBox(height: 16.0),
                        _buildHeader(isTablet),
                        const SizedBox(height: 20.0),

                        // Game Container
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22.0),
                            border: Border.all(
                              color: const Color(0xFFA85B4F),
                              width: 1.8,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x104A3B32),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                allSorted ? '🎉 Outstanding! All items sorted!' : 'Tap a basket, then tap matching items:',
                                style: TextStyle(
                                  fontFamily: AppTypography.headingFontFamily,
                                  fontSize: isTablet ? 18.0 : 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: allSorted ? const Color(0xFF385E32) : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 18.0),

                              // Baskets Selector Row
                              _buildBasketsRow(isTablet),
                              const SizedBox(height: 24.0),

                              // Unsorted Items Tray
                              _buildItemsTray(isTablet),
                              const SizedBox(height: 20.0),

                              // Reset / Play Again
                              if (allSorted)
                                ElevatedButton.icon(
                                  onPressed: () => setState(_initGame),
                                  icon: const Icon(Icons.replay_rounded, color: Colors.white),
                                  label: const Text(
                                    'Play Again',
                                    style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFA85B4F),
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

  Widget _buildTopBar(bool isTablet) {
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
              child: Container(
                width: 42.0,
                height: 42.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: const Color(0xFFE8DECF)),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 24.0,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: AyoLogo(
            height: isTablet ? 95.0 : 75.0,
            assetPath: 'assets/images/ayovaani_logo.png',
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE8DECF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA85B4F), // Terracotta
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    '${widget.className} • Ch ${widget.chapterNumber}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Flexible(
                  child: Text(
                    'Sorting: ${widget.chapterName}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.headingFontFamily,
                      fontSize: isTablet ? 18.0 : 15.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF2E9),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFE2D4C0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFD49B2A), size: 20.0),
                const SizedBox(width: 4.0),
                Text(
                  'Score: $_score',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 13.0,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasketsRow(bool isTablet) {
    final categories = ['Red', 'Yellow', 'Purple', 'Orange'];

    return Wrap(
      spacing: 16.0,
      runSpacing: 12.0,
      alignment: WrapAlignment.center,
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat;
        Color basketColor;
        switch (cat) {
          case 'Red':
            basketColor = const Color(0xFFD34836);
            break;
          case 'Yellow':
            basketColor = const Color(0xFFE67E22);
            break;
          case 'Purple':
            basketColor = const Color(0xFF8E44AD);
            break;
          default:
            basketColor = const Color(0xFFE65100);
        }

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isTablet ? 110.0 : 85.0,
            height: isTablet ? 95.0 : 80.0,
            decoration: BoxDecoration(
              color: isSelected ? basketColor.withValues(alpha: 0.15) : const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: isSelected ? basketColor : const Color(0xFFE2D4C0),
                width: isSelected ? 2.5 : 1.2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_basket_rounded,
                  color: basketColor,
                  size: isTablet ? 34.0 : 28.0,
                ),
                const SizedBox(height: 4.0),
                Text(
                  '$cat Basket',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: isTablet ? 12.5 : 11.0,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? basketColor : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildItemsTray(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE8DECF)),
      ),
      child: Wrap(
        spacing: 14.0,
        runSpacing: 14.0,
        alignment: WrapAlignment.center,
        children: _items.map((item) {
          return GestureDetector(
            onTap: () => _onItemTap(item),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: item.isSorted ? 0.25 : 1.0,
              child: Container(
                width: isTablet ? 80.0 : 70.0,
                height: isTablet ? 80.0 : 70.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: item.isSorted ? const Color(0xFF385E32) : const Color(0xFFE2D4C0),
                    width: item.isSorted ? 2.0 : 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A4A3B32),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.emoji,
                          style: TextStyle(fontSize: isTablet ? 28.0 : 24.0, height: 1.1),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          item.isSorted ? '✓ Sorted' : item.name,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: isTablet ? 10.5 : 9.0,
                            fontWeight: FontWeight.w600,
                            color: item.isSorted ? const Color(0xFF385E32) : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
