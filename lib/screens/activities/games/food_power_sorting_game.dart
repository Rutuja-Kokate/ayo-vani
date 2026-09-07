import 'package:flutter/material.dart';
import '../../../app/responsive/responsive.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/english_activities_data.dart';
import '../../../widgets/ayo_bottom_nav_bar.dart';
import '../../../widgets/ayo_logo.dart';
import '../../../widgets/ayo_screen_background.dart';

class FoodCategory {
  final String id;
  final String title;
  final String mundariRoman;
  final String mundariOdia;
  final IconData icon;
  final Color color;

  const FoodCategory({
    required this.id,
    required this.title,
    required this.mundariRoman,
    required this.mundariOdia,
    required this.icon,
    required this.color,
  });
}

class SortedItem {
  final EnglishMundariWord word;
  final String categoryId;

  const SortedItem({required this.word, required this.categoryId});
}

/// Game 2: "Food Power Sorting Game" for Chapter "The Food We Eat"
class FoodPowerSortingGame extends StatefulWidget {
  const FoodPowerSortingGame({
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
  State<FoodPowerSortingGame> createState() => _FoodPowerSortingGameState();
}

class _FoodPowerSortingGameState extends State<FoodPowerSortingGame> {
  int _navIndex = 1;
  int _score = 0;
  bool _isFinished = false;

  final List<FoodCategory> _categories = const [
    FoodCategory(
      id: 'grains',
      title: 'Grains & Bread',
      mundariRoman: 'Lad',
      mundariOdia: 'ଲାଦ',
      icon: Icons.bakery_dining_rounded,
      color: Color(0xFFC88A22),
    ),
    FoodCategory(
      id: 'fruits',
      title: 'Fruits & Sweets',
      mundariRoman: 'Jo',
      mundariOdia: 'ଜୋ',
      icon: Icons.apple_rounded,
      color: Color(0xFFD34836),
    ),
    FoodCategory(
      id: 'dairy',
      title: 'Milk & Dairy',
      mundariRoman: 'Toa',
      mundariOdia: 'ତୋଆ',
      icon: Icons.local_drink_rounded,
      color: Color(0xFF2980B9),
    ),
    FoodCategory(
      id: 'veggies',
      title: 'Vegetables',
      mundariRoman: 'Gajra',
      mundariOdia: 'ଗାଜରା',
      icon: Icons.eco_rounded,
      color: Color(0xFF27AE60),
    ),
  ];

  late final Map<String, String> _wordCategoryMap;
  late List<EnglishMundariWord> _gameWords;
  final Map<String, List<EnglishMundariWord>> _sortedMap = {};

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _score = 0;
    _isFinished = false;
    _sortedMap.clear();
    for (final cat in _categories) {
      _sortedMap[cat.id] = [];
    }

    final allWords = EnglishActivitiesData.getWords(widget.chapterName) ?? [];

    // Map 6 specific words from the 19 chapter words
    _wordCategoryMap = {
      'Roti': 'grains',
      'Paratha': 'grains',
      'Fruits': 'fruits',
      'Mango': 'fruits',
      'Milk': 'dairy',
      'Curd': 'dairy',
      'Carrot': 'veggies',
      'Brinjal': 'veggies',
    };

    // Filter to exactly 6 cards for the sorting tray
    final selectedNames = ['Roti', 'Mango', 'Milk', 'Carrot', 'Paratha', 'Brinjal'];
    _gameWords = allWords.where((w) => selectedNames.contains(w.english)).toList();
    _gameWords.shuffle();
  }

  void _onItemDropped(EnglishMundariWord item, String categoryId) {
    final correctCatId = _wordCategoryMap[item.english];
    if (correctCatId == categoryId) {
      setState(() {
        _gameWords.removeWhere((w) => w.english == item.english);
        _sortedMap[categoryId]!.add(item);
        _score += 10;

        if (_gameWords.isEmpty) {
          _isFinished = true;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Great job! ${item.english} sorted correctly! (+10 pts)'),
          duration: const Duration(milliseconds: 900),
          backgroundColor: const Color(0xFF385E32),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Oops! ${item.english} belongs in a different group.'),
          duration: const Duration(milliseconds: 1000),
          backgroundColor: const Color(0xFFB33222),
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);

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
                      maxWidth: isTablet ? 920.0 : double.infinity,
                    ),
                    child: Column(
                      children: [
                        _buildTopBar(isTablet),
                        const SizedBox(height: 16.0),
                        _buildHeader(isTablet),
                        const SizedBox(height: 20.0),

                        if (_isFinished)
                          _buildCompletionCard(isTablet)
                        else
                          _buildGameBoard(isTablet),
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
                    color: const Color(0xFFC88A22),
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
                    'Food Power Sorting',
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
                  '⭐ $_score',
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

  Widget _buildGameBoard(bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: const Color(0xFFC88A22), width: 1.8),
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
            'Drag each food item into the correct category basket:',
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: isTablet ? 16.0 : 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16.0),

          // Unsorted Food Cards Tray
          _buildDraggableTray(isTablet),
          const SizedBox(height: 24.0),

          // 4 Category Drop Zones Grid
          _buildCategoryDropZones(isTablet),
        ],
      ),
    );
  }

  Widget _buildDraggableTray(bool isTablet) {
    if (_gameWords.isEmpty) {
      return const SizedBox(height: 60.0);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE8DECF)),
      ),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        alignment: WrapAlignment.center,
        children: _gameWords.map((item) {
          final cardChild = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFC88A22), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0E4A3B32),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.emoji, style: const TextStyle(fontSize: 22.0)),
                const SizedBox(width: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.english,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '( ${item.mundariRoman} / ',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.5,
                              color: AppColors.primaryBurgundy,
                            ),
                          ),
                          TextSpan(
                            text: '${item.mundariOdia} )',
                            style: const TextStyle(
                              fontFamily: 'NotoSansOriya',
                              fontSize: 10.5,
                              color: AppColors.primaryBurgundy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

          return Draggable<EnglishMundariWord>(
            data: item,
            feedback: Material(
              color: Colors.transparent,
              child: Transform.scale(scale: 1.05, child: cardChild),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: cardChild),
            child: cardChild,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryDropZones(bool isTablet) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 4 : 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: isTablet ? 1.0 : 1.1,
      ),
      itemBuilder: (context, index) {
        final cat = _categories[index];
        final sortedItems = _sortedMap[cat.id] ?? [];

        return DragTarget<EnglishMundariWord>(
          onWillAcceptWithDetails: (details) => true,
          onAcceptWithDetails: (details) => _onItemDropped(details.data, cat.id),
          builder: (context, candidateData, rejectedData) {
            final isHovered = candidateData.isNotEmpty;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isHovered
                    ? cat.color.withValues(alpha: 0.2)
                    : const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: isHovered ? cat.color : cat.color.withValues(alpha: 0.6),
                  width: isHovered ? 2.5 : 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(cat.icon, color: cat.color, size: 28.0),
                  const SizedBox(height: 4.0),
                  Text(
                    cat.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTypography.headingFontFamily,
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: cat.color,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '( ${cat.mundariRoman} / ',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: cat.color.withValues(alpha: 0.8),
                          ),
                        ),
                        TextSpan(
                          text: '${cat.mundariOdia} )',
                          style: TextStyle(
                            fontFamily: 'NotoSansOriya',
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: cat.color.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6.0),

                  // Display Sorted Cards inside box
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 4.0,
                        runSpacing: 4.0,
                        alignment: WrapAlignment.center,
                        children: sortedItems.map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: cat.color, width: 1.0),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(item.emoji, style: const TextStyle(fontSize: 12.0)),
                                const SizedBox(width: 3.0),
                                Text(
                                  item.english,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.w700,
                                    color: cat.color,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCompletionCard(bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: const Color(0xFFC88A22), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x104A3B32),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 36.0 : 24.0),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, color: Color(0xFFD49B2A), size: 68.0),
          const SizedBox(height: 12.0),
          Text(
            'Well done!',
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: isTablet ? 28.0 : 24.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'All food items sorted successfully with $_score points!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF385E32),
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: () => setState(_initGame),
            icon: const Icon(Icons.replay_rounded, color: Colors.white),
            label: const Text(
              'Play Again',
              style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC88A22),
              padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 13.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
            ),
          ),
        ],
      ),
    );
  }
}
