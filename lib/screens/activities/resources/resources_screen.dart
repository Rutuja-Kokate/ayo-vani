import 'package:flutter/material.dart';
import '../../../app/responsive/responsive.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/chapter_resources_data.dart';
import '../../../widgets/ayo_bottom_nav_bar.dart';
import '../../../widgets/ayo_logo.dart';
import '../../../widgets/ayo_screen_background.dart';
import 'chapter_dictionary_screen.dart';
import 'chapter_pdf_viewer_screen.dart';
import 'chapter_video_player_screen.dart';

/// Screen: Dedicated Resources & Materials Screen for Class 1 English Chapters.
///
/// Follows the exact AyoVaani visual language:
/// - Warm parchment background & Warli corner decorations
/// - Centered AyoVaani logo & circular back button
/// - Distinct chapter context badge and title
/// - Isolated chapter-specific resources (Chapter 1, 2, or 3)
/// - Responsive mobile and tablet layout
class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({
    super.key,
    required this.className,
    required this.chapterNumber,
    required this.chapterName,
    this.subject = 'English',
    this.onBack,
    this.onNavigateTab,
  });

  final String className;
  final int chapterNumber;
  final String chapterName;
  final String subject;
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  int _navIndex = 1; // 'Learn' tab highlighted
  ResourceCategory _selectedCategory = ResourceCategory.all;
  late final List<ChapterResourceItem> _allResources;

  @override
  void initState() {
    super.initState();
    _allResources = ChapterResourcesData.getResourcesForChapter(
      widget.chapterNumber,
      widget.chapterName,
    );
  }

  List<ChapterResourceItem> get _filteredResources {
    if (_selectedCategory == ResourceCategory.all) {
      return _allResources;
    }
    return _allResources
        .where((item) => item.category == _selectedCategory)
        .toList();
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

  void _openVideoPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterVideoPlayerScreen(
          className: widget.className,
          chapterNumber: widget.chapterNumber,
          chapterName: widget.chapterName,
          subject: widget.subject,
        ),
      ),
    );
  }

  void _openPdfViewer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterPdfViewerScreen(
          className: widget.className,
          chapterNumber: widget.chapterNumber,
          chapterName: widget.chapterName,
          subject: widget.subject,
        ),
      ),
    );
  }

  void _openDictionary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterDictionaryScreen(
          className: widget.className,
          chapterNumber: widget.chapterNumber,
          chapterName: widget.chapterName,
          subject: widget.subject,
        ),
      ),
    );
  }

  Widget _buildChapter1Options(bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChapter1Card(
          title: 'Video',
          subtitle: 'Watch chapter poem video offline',
          icon: Icons.play_arrow_rounded,
          badgeText: 'Offline MP4',
          actionIcon: Icons.play_circle_fill_rounded,
          isTablet: isTablet,
          onTap: _openVideoPlayer,
        ),
        SizedBox(height: isTablet ? 16.0 : 12.0),
        _buildChapter1Card(
          title: 'Reading Material',
          subtitle: 'Read textbook poem & lesson notes',
          icon: Icons.picture_as_pdf_rounded,
          badgeText: 'Offline PDF',
          actionIcon: Icons.arrow_forward_rounded,
          isTablet: isTablet,
          onTap: _openPdfViewer,
        ),
        SizedBox(height: isTablet ? 16.0 : 12.0),
        _buildChapter1Card(
          title: 'Dictionary',
          subtitle: 'Vocabulary & bilingual word meanings',
          icon: Icons.auto_stories_rounded,
          badgeText: 'Curriculum Ready',
          actionIcon: Icons.arrow_forward_rounded,
          isTablet: isTablet,
          onTap: _openDictionary,
        ),
      ],
    );
  }

  Widget _buildChapter1Card({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required IconData actionIcon,
    required bool isTablet,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFFFDFBF7),
      borderRadius: BorderRadius.circular(20.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.12),
        highlightColor: AppColors.primaryBurgundy.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: AppColors.primaryBurgundy,
              width: 1.6,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A4A3B32),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 22.0 : 18.0,
            vertical: isTablet ? 20.0 : 16.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Icon Container
              Container(
                width: isTablet ? 54.0 : 46.0,
                height: isTablet ? 54.0 : 46.0,
                decoration: BoxDecoration(
                  color: AppColors.primaryBurgundy.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: AppColors.primaryBurgundy.withValues(alpha: 0.28),
                    width: 1.4,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: isTablet ? 28.0 : 24.0,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16.0 : 14.0),

              // Middle: Title, Subtitle, and Tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontSize: isTablet ? 22.0 : 18.0,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4ECE1),
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(
                              color: const Color(0xFFD8C6AC),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF671D21),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: isTablet ? 13.5 : 12.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12.0),

              // Right: Action button
              Container(
                width: isTablet ? 40.0 : 34.0,
                height: isTablet ? 40.0 : 34.0,
                decoration: BoxDecoration(
                  color: AppColors.primaryBurgundy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Icon(
                    actionIcon,
                    color: AppColors.primaryBurgundy,
                    size: isTablet ? 22.0 : 18.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openResourcePreview(ChapterResourceItem resource) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildResourceDetailSheet(resource),
    );
  }

  Widget _buildResourceDetailSheet(ChapterResourceItem resource) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFBF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8C6AC),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const SizedBox(height: 18.0),

            // Header Row: Icon + Title + Format Tag
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: BoxDecoration(
                    color: resource.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: resource.accentColor.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    resource.icon,
                    size: 26.0,
                    color: resource.accentColor,
                  ),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        resource.title,
                        style: TextStyle(
                          fontFamily: AppTypography.headingFontFamily,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 3.0,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2EADC),
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                color: const Color(0xFFD8C6AC),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              resource.format,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF671D21),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          const Icon(
                            Icons.offline_pin_rounded,
                            size: 14.0,
                            color: Color(0xFF526B4F),
                          ),
                          const SizedBox(width: 3.0),
                          const Text(
                            'Offline Ready',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF526B4F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Description
            Text(
              resource.description,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 14.0,
                color: AppColors.textPrimary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16.0),

            // Key Highlights / Contents
            if (resource.keyPoints.isNotEmpty) ...[
              Text(
                'Key Materials Included:',
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF765E49),
                ),
              ),
              const SizedBox(height: 8.0),
              ...resource.keyPoints.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 4.0, right: 8.0),
                        child: Icon(
                          Icons.circle,
                          size: 6.0,
                          color: Color(0xFF671D21),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 13.0,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📂 Ready for offline use: ${resource.title}'),
                          backgroundColor: const Color(0xFF526B4F),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download_done_rounded, size: 18.0),
                    label: const Text('Save Offline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF765E49),
                      side: const BorderSide(color: Color(0xFFD8C6AC), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('📖 Viewing ${resource.title} for ${widget.chapterName}'),
                          backgroundColor: const Color(0xFF671D21),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 18.0),
                    label: const Text('Open Material'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF671D21),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
              // Top-left Warli Corner
              Positioned(
                top: 0,
                left: 0,
                child: IgnorePointer(
                  child: _buildCornerDecoration(isRight: false, size: cornerSize),
                ),
              ),

              // Top-right Warli Corner
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: _buildCornerDecoration(isRight: true, size: cornerSize),
                ),
              ),

              // Main Scrollable Content
              LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = isTablet ? 48.0 : AppSpacing.lg;
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
                            // 1. Top Bar: Back Button + Logo
                            _buildTopBar(isTablet),
                            SizedBox(height: isTablet ? 14.0 : 12.0),

                            // 2. Chapter Header
                            _buildHeader(isTablet),
                            SizedBox(height: isTablet ? 18.0 : 14.0),

                            // 3. Resources Content
                            if (widget.chapterNumber == 1) ...[
                              // Chapter 1: Exactly 3 dedicated options
                              _buildChapter1Options(isTablet),
                            ] else ...[
                              // Chapters 2 & 3: Preserved categorized resources
                              _buildFilterChips(isTablet),
                              SizedBox(height: isTablet ? 20.0 : 16.0),
                              if (isTablet)
                                _buildTabletResourceGrid()
                              else
                                _buildMobileResourceList(),
                            ],
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

  Widget _buildCornerDecoration({required bool isRight, required double size}) {
    final imageWidget = Image.asset(
      'assets/images/corner-design.png',
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/corner-desing.png',
          width: size,
          fit: BoxFit.contain,
        );
      },
    );

    return isRight ? Transform.flip(flipX: true, child: imageWidget) : imageWidget;
  }

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
                  border: Border.all(color: const Color(0xFFE8DECF), width: 1.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x084A3B32),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
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
            height: logoHeight,
            assetPath: 'assets/images/ayovaani_logo.png',
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: const Color(0xFFE8DECF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x064A3B32),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20.0 : 16.0,
        vertical: isTablet ? 16.0 : 14.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Chapter Number Badge
          Container(
            width: isTablet ? 54.0 : 44.0,
            height: isTablet ? 54.0 : 44.0,
            decoration: BoxDecoration(
              color: const Color(0xFF671D21),
              borderRadius: BorderRadius.circular(14.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x20671D21),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${widget.chapterNumber}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isTablet ? 22.0 : 18.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 16.0 : 12.0),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chapterName,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: isTablet ? 22.0 : 18.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  'Resources & Learning Materials • Class 1 English',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 13.5 : 12.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF765E49),
                  ),
                ),
              ],
            ),
          ),

          // Right badge: Offline Ready
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE2EADF),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFF526B4F), width: 1.0),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.offline_pin_rounded, size: 14.0, color: Color(0xFF526B4F)),
                SizedBox(width: 4.0),
                Text(
                  'Offline',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF526B4F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isTablet) {
    final categories = [
      (ResourceCategory.all, 'All Materials', Icons.apps_rounded),
      (ResourceCategory.lessonPlan, 'Lesson Plans', Icons.menu_book_rounded),
      (ResourceCategory.audioGuide, 'Audio Guides', Icons.audiotrack_rounded),
      (ResourceCategory.printable, 'Printables', Icons.picture_as_pdf_rounded),
      (ResourceCategory.teachingAid, 'Teaching Aids', Icons.auto_awesome_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              avatar: Icon(
                cat.$3,
                size: 16.0,
                color: isSelected ? Colors.white : const Color(0xFF765E49),
              ),
              label: Text(cat.$2),
              labelStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              selected: isSelected,
              showCheckmark: false,
              backgroundColor: const Color(0xFFFDFBF7),
              selectedColor: const Color(0xFF671D21),
              side: BorderSide(
                color: isSelected ? const Color(0xFF671D21) : const Color(0xFFE8DECF),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = cat.$1;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileResourceList() {
    final resources = _filteredResources;
    if (resources.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resources.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12.0),
      itemBuilder: (context, index) {
        return _buildResourceCard(resources[index], isTablet: false);
      },
    );
  }

  Widget _buildTabletResourceGrid() {
    final resources = _filteredResources;
    if (resources.isEmpty) {
      return _buildEmptyState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = <Widget>[];
        for (var i = 0; i < resources.length; i += 2) {
          final first = resources[i];
          final second = i + 1 < resources.length ? resources[i + 1] : null;

          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildResourceCard(first, isTablet: true)),
                const SizedBox(width: 16.0),
                Expanded(
                  child: second != null
                      ? _buildResourceCard(second, isTablet: true)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
          if (i + 2 < resources.length) {
            rows.add(const SizedBox(height: 16.0));
          }
        }

        return Column(children: rows);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE8DECF), width: 1.0),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 48.0, color: Color(0xFF95806E)),
          const SizedBox(height: 12.0),
          Text(
            'No resources found in this category',
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Try selecting "All Materials" to see all available items for ${widget.chapterName}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 13.0,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(ChapterResourceItem item, {required bool isTablet}) {
    return Material(
      color: const Color(0xFFFDFBF7),
      borderRadius: BorderRadius.circular(18.0),
      child: InkWell(
        onTap: () => _openResourcePreview(item),
        borderRadius: BorderRadius.circular(18.0),
        splashColor: item.accentColor.withValues(alpha: 0.12),
        highlightColor: item.accentColor.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: const Color(0xFFE8DECF),
              width: 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x084A3B32),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(isTablet ? 18.0 : 15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Themed resource icon box
              Container(
                width: isTablet ? 50.0 : 44.0,
                height: isTablet ? 50.0 : 44.0,
                decoration: BoxDecoration(
                  color: item.accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: item.accentColor.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  item.icon,
                  size: isTablet ? 26.0 : 22.0,
                  color: item.accentColor,
                ),
              ),
              SizedBox(width: isTablet ? 14.0 : 12.0),

              // Center: Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFontFamily,
                        fontSize: isTablet ? 16.5 : 15.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: isTablet ? 13.0 : 12.0,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4ECE1),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(
                            item.format,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: item.accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Flexible(
                          child: Text(
                            item.details,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF765E49),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),

              // Right: Arrow Button
              Container(
                width: 32.0,
                height: 32.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F2E9),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFE2D4C0), width: 1.0),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.0,
                  color: Color(0xFF765E49),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
