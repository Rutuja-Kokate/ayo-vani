import 'package:flutter/material.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../models/chapter_data.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../balvatika/balvatika_screen.dart';
import '../chapter_options/chapter_options_screen.dart';

/// Screen: Class 1 English Chapters Listing for AYOVAANI Teacher App.
///
/// This is the primary functional learning path in the MVP scope:
/// Home → First → English → Chapters → Select Chapter → Chapter Options → Flashcards / Worksheets / Games / Quizzes
class FirstEnglishChaptersScreen extends StatefulWidget {
  const FirstEnglishChaptersScreen({
    super.key,
    this.onBack,
    this.onNavigateTab,
  });

  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;

  /// Class 1 English Curriculum prototype chapters (3 chapters for hackathon)
  static const List<BalvatikaChapter> englishChapters = [
    BalvatikaChapter(
      number: 1,
      title: 'Two Little Hands',
      description: "Let's learn the parts of our body",
      icon: Icons.accessibility_new_rounded,
    ),
    BalvatikaChapter(
      number: 2,
      title: 'Life Around Us',
      description: "Let's learn about animals around us",
      icon: Icons.pets_rounded,
    ),
    BalvatikaChapter(
      number: 3,
      title: 'The Food We Eat',
      description: "Let's learn about the food we eat",
      icon: Icons.restaurant_rounded,
    ),
  ];

  @override
  State<FirstEnglishChaptersScreen> createState() =>
      _FirstEnglishChaptersScreenState();
}

class _FirstEnglishChaptersScreenState
    extends State<FirstEnglishChaptersScreen> {
  late final TextEditingController _searchController;
  int _navIndex = 0;
  bool _showAllChapters = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BalvatikaChapter> get _filteredChapters {
    var list = FirstEnglishChaptersScreen.englishChapters;
    if (_searchQuery.isNotEmpty) {
      list = list.where((c) {
        return c.title.toLowerCase().contains(_searchQuery) ||
            c.description.toLowerCase().contains(_searchQuery) ||
            'chapter ${c.number}'.contains(_searchQuery);
      }).toList();
    } else if (!_showAllChapters) {
      list = list.take(8).toList();
    }
    return list;
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

  void _onChapterTap(BalvatikaChapter chapter) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ChapterOptionsScreen(
          className: 'First',
          chapterNumber: chapter.number,
          chapterName: chapter.title,
          subject: 'English',
          chapterDescription: "Let's learn and practice.",
          topic: chapter.topic ??
              ChapterRepository.getTopic(
                'First',
                chapter.number,
                chapter.title,
              ),
          lesson: chapter.lesson ??
              ChapterRepository.getLesson(
                'First',
                chapter.number,
                chapter.title,
              ),
          chapterEmoji:
              chapter.emoji ?? ChapterRepository.getEmoji(chapter.title),
          chapterImage: chapter.chapterImage,
          onNavigateTab: widget.onNavigateTab,
        ),
      ),
    );
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

                            // 2. English Header: Title Info + Info Card
                            _buildEnglishHeader(isTablet),

                            SizedBox(height: isTablet ? 18.0 : 16.0),

                            // 3. Chapter Listing Container
                            _buildChaptersContainer(isTablet),

                            SizedBox(height: isTablet ? 16.0 : 14.0),

                            // 4. "Keep Learning!" Encouragement Card
                            _buildKeepLearningCard(isTablet),
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
        // Back Button on the top left
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

        // Centered Official AyoVaani Logo
        Center(
          child: AyoLogo(
            height: logoHeight,
            assetPath: 'assets/images/ayovaani_logo.png',
          ),
        ),
      ],
    );
  }

  /// 2. Header: English Class 1
  Widget _buildEnglishHeader(bool isTablet) {
    final titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Cultural Illustration / Badge
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

        // Title and description text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'English',
                    style: TextStyle(
                      fontFamily: AppTypography.headingFontFamily,
                      fontSize: isTablet ? 26.0 : 22.0,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBurgundy,
                      letterSpacing: -0.2,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // Active Available pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0E4),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(
                        color: const Color(0xFFCCE0C8),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'Available',
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
              const SizedBox(height: 3.0),
              Text(
                'Grade 1 | Learn, Listen, Speak',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: isTablet ? 13.5 : 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF8B4B3E),
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                'Explore foundational English chapters, audio vocabulary & activities.',
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

    // Compact Info Card: Warli Art + Total Chapters & Level
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
          // Warli thumbnail illustration
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

          // Details: Total Chapters & Level
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Chapters',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF765E49),
                  ),
                ),
                Text(
                  '${FirstEnglishChaptersScreen.englishChapters.length}',
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
                  'Subject Status',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF765E49),
                  ),
                ),
                Text(
                  'Functional',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF385E32),
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

  /// 3. Main Chapter Listing Container
  Widget _buildChaptersContainer(bool isTablet) {
    final chapters = _filteredChapters;

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
          // Header Controls Row: "Chapters" pill, Search field, Filter button
          _buildChapterControlsRow(isTablet),

          SizedBox(height: isTablet ? 16.0 : 12.0),

          // Chapters Cards Display: 2-column on tablet, 1-column on mobile
          if (chapters.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36.0),
              child: Center(
                child: Text(
                  'No chapters found matching "$_searchQuery"',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 14.0,
                    color: const Color(0xFF95806E),
                  ),
                ),
              ),
            )
          else if (isTablet)
            _buildTabletChaptersGrid(chapters)
          else
            _buildMobileChaptersList(chapters),

          const SizedBox(height: 16.0),

          // "View More Chapters" Center Button
          Center(
            child: Material(
              color: const Color(0xFFF6EDE2),
              borderRadius: BorderRadius.circular(20.0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showAllChapters = !_showAllChapters;
                  });
                },
                borderRadius: BorderRadius.circular(20.0),
                splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 9.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: const Color(0xFFE5D5BF),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showAllChapters
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20.0,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        _showAllChapters
                            ? 'Show Less'
                            : 'View More Chapters',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Header Controls: "Chapters" pill on left, search + filter on right
  Widget _buildChapterControlsRow(bool isTablet) {
    final chaptersPill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.primaryBurgundy,
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.menu_book_rounded,
            color: Colors.white,
            size: 16.0,
          ),
          const SizedBox(width: 6.0),
          Text(
            'Chapters',
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
    );

    final searchField = Container(
      height: 38.0,
      width: isTablet ? 220.0 : 170.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFFE8DECF),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 18.0,
            color: Color(0xFF95806E),
          ),
          const SizedBox(width: 6.0),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13.0,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search chapters...',
                hintStyle: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12.5,
                  color: const Color(0xFF95806E),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
              },
              child: const Icon(
                Icons.close_rounded,
                size: 16.0,
                color: Color(0xFF95806E),
              ),
            ),
        ],
      ),
    );

    final filterButton = Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.0),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Showing all Class 1 English chapters',
                style: TextStyle(fontFamily: AppTypography.bodyFontFamily),
              ),
              backgroundColor: const Color(0xFF4A3B32),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: const EdgeInsets.all(16.0),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          height: 38.0,
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: const Color(0xFFE8DECF),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.tune_rounded,
                size: 16.0,
                color: Color(0xFF6B5849),
              ),
              const SizedBox(width: 6.0),
              Text(
                'Filter',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B5849),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isTablet) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          chaptersPill,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              searchField,
              const SizedBox(width: 10.0),
              filterButton,
            ],
          ),
        ],
      );
    } else {
      return Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10.0,
        runSpacing: 10.0,
        children: [
          chaptersPill,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              searchField,
              const SizedBox(width: 8.0),
              filterButton,
            ],
          ),
        ],
      );
    }
  }

  /// Tablet 2-column Grid for Chapters
  Widget _buildTabletChaptersGrid(List<BalvatikaChapter> chapters) {
    final leftColumn = <BalvatikaChapter>[];
    final rightColumn = <BalvatikaChapter>[];

    for (int i = 0; i < chapters.length; i++) {
      if (i.isEven) {
        leftColumn.add(chapters[i]);
      } else {
        rightColumn.add(chapters[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              for (final chapter in leftColumn) ...[
                _buildChapterCard(chapter),
                const SizedBox(height: 10.0),
              ],
            ],
          ),
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Column(
            children: [
              for (final chapter in rightColumn) ...[
                _buildChapterCard(chapter),
                const SizedBox(height: 10.0),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Mobile Single-column List for Chapters
  Widget _buildMobileChaptersList(List<BalvatikaChapter> chapters) {
    return Column(
      children: [
        for (final chapter in chapters) ...[
          _buildChapterCard(chapter),
          const SizedBox(height: 10.0),
        ],
      ],
    );
  }

  /// Individual Chapter Card
  Widget _buildChapterCard(BalvatikaChapter chapter) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.0),
      child: InkWell(
        onTap: () => _onChapterTap(chapter),
        borderRadius: BorderRadius.circular(14.0),
        splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.08),
        highlightColor: AppColors.primaryBurgundy.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: const Color(0xFFEFE8DD),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x064A3B32),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Small Circular Maroon Chapter Number Badge
              Container(
                width: 22.0,
                height: 22.0,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBurgundy,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${chapter.number}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),

              // Educational Icon
              Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7EBE7),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color(0xFFEAD8D0),
                    width: 1.0,
                  ),
                ),
                child: Icon(
                  chapter.icon,
                  size: 20.0,
                  color: AppColors.primaryBurgundy,
                ),
              ),
              const SizedBox(width: 12.0),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapter.title,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFontFamily,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      chapter.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Right Arrow Indicator
              const Icon(
                Icons.chevron_right_rounded,
                size: 22.0,
                color: Color(0xFF8B4B3E),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 4. "Keep Learning!" Encouragement Card
  Widget _buildKeepLearningCard(bool isTablet) {
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
              color: Color(0xFFE8F0E4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Color(0xFF4C7544),
              size: 20.0,
            ),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep Learning!',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  'Practice flashcards, games & worksheets with your students every day.',
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
