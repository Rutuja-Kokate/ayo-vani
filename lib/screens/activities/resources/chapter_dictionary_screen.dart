import 'package:flutter/material.dart';
import '../../../app/responsive/responsive.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/chapter_dictionary_data.dart';
import '../../../services/tts_service.dart';
import '../../../widgets/ayo_bottom_nav_bar.dart';
import '../../../widgets/ayo_logo.dart';
import '../../../widgets/ayo_screen_background.dart';

/// Screen: Dedicated English → Mundari Dictionary for Chapter 1 Resources.
///
/// Features:
/// - 30 words categorized into Actions (15) and Body Parts (15)
/// - English → Mundari translations generated via MtTranslationService
/// - Search filter by English word
/// - Category filter tabs (All | Actions | Body Parts)
/// - Interactive speaker button connected to TtsService
/// - Responsive mobile and tablet layout
class ChapterDictionaryScreen extends StatefulWidget {
  const ChapterDictionaryScreen({
    super.key,
    required this.className,
    required this.chapterNumber,
    required this.chapterName,
    this.subject = 'English',
  });

  final String className;
  final int chapterNumber;
  final String chapterName;
  final String subject;

  @override
  State<ChapterDictionaryScreen> createState() =>
      _ChapterDictionaryScreenState();
}

class _ChapterDictionaryScreenState extends State<ChapterDictionaryScreen> {
  int _navIndex = 1;
  DictionaryCategory _selectedCategory = DictionaryCategory.all;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late final List<DictionaryEntry> _allEntries;
  String? _speakingWord;

  @override
  void initState() {
    super.initState();
    _allEntries =
        ChapterDictionaryData.getEntriesForChapter(widget.chapterNumber);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DictionaryEntry> get _filteredEntries {
    return _allEntries.where((entry) {
      // 1. Category filter
      if (_selectedCategory == DictionaryCategory.actions &&
          entry.category != DictionaryCategory.actions) {
        return false;
      }
      if (_selectedCategory == DictionaryCategory.bodyParts &&
          entry.category != DictionaryCategory.bodyParts) {
        return false;
      }

      // 2. Search query filter (English word, case-insensitive)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return entry.english.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  Future<void> _playPronunciation(DictionaryEntry entry) async {
    if (!entry.isAvailable || entry.mundari.isEmpty) return;

    setState(() {
      _speakingWord = entry.english;
    });

    try {
      await TtsService().speakWordAndMundari(entry.english, entry.mundari);
    } catch (e) {
      debugPrint('[Dictionary] Audio playback error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _speakingWord = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = isTablet ? 40.0 : 16.0;
    final filtered = _filteredEntries;

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Top Bar: Back Button + Logo
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isTablet ? 12.0 : 8.0,
                ),
                child: _buildTopBar(isTablet),
              ),

              // 2. Header & Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildHeaderBar(isTablet),
              ),

              const SizedBox(height: 12.0),

              // 3. Search Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildSearchBar(isTablet),
              ),

              const SizedBox(height: 10.0),

              // 4. Category Filter Chips
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildFilterChips(isTablet),
              ),

              const SizedBox(height: 12.0),

              // 5. Word Entries Count / Meta
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} of ${_allEntries.length} words',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF765E49),
                      ),
                    ),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.offline_pin_rounded,
                          size: 13.0,
                          color: Color(0xFF526B4F),
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          'MT Offline',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF526B4F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8.0),

              // 6. Entries List / Grid
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: filtered.isEmpty
                      ? _buildEmptyState(isTablet)
                      : (isTablet
                          ? _buildTabletGrid(filtered)
                          : _buildMobileList(filtered)),
                ),
              ),

              const SizedBox(height: 12.0),
            ],
          ),
        ),
        bottomNavigationBar: AyoBottomNavBar(
          selectedIndex: _navIndex,
          onItemSelected: (index) {
            if (index == 0) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else {
              setState(() => _navIndex = index);
            }
          },
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
              onTap: () => Navigator.of(context).maybePop(),
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
            height: isTablet ? 90.0 : 70.0,
            assetPath: 'assets/images/ayovaani_logo.png',
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderBar(bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16.0),
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
        horizontal: isTablet ? 18.0 : 14.0,
        vertical: isTablet ? 14.0 : 12.0,
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 44.0 : 38.0,
            height: isTablet ? 44.0 : 38.0,
            decoration: BoxDecoration(
              color: const Color(0xFF671D21),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_stories_rounded,
                color: Colors.white,
                size: 22.0,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dictionary',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: isTablet ? 20.0 : 17.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2.0),
                const Text(
                  'English → Mundari',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF671D21),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF4ECE1),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFFD8C6AC), width: 1.0),
            ),
            child: Text(
              widget.chapterName,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
                color: Color(0xFF765E49),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isTablet) {
    return Container(
      height: 44.0,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: const Color(0xFFE8DECF),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x064A3B32),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 20.0,
            color: Color(0xFF95806E),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13.5,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Search a word...',
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.0,
                  color: Color(0xFF95806E),
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
                size: 18.0,
                color: Color(0xFF95806E),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(bool isTablet) {
    final categories = [
      DictionaryCategory.all,
      DictionaryCategory.actions,
      DictionaryCategory.bodyParts,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(cat.label),
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
                color: isSelected
                    ? const Color(0xFF671D21)
                    : const Color(0xFFE8DECF),
                width: 1.2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
              onSelected: (_) {
                setState(() {
                  _selectedCategory = cat;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileList(List<DictionaryEntry> entries) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10.0),
      itemBuilder: (context, index) {
        return _buildDictionaryCard(entries[index], isTablet: false);
      },
    );
  }

  Widget _buildTabletGrid(List<DictionaryEntry> entries) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 3.2,
      ),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return _buildDictionaryCard(entries[index], isTablet: true);
      },
    );
  }

  Widget _buildDictionaryCard(DictionaryEntry entry, {required bool isTablet}) {
    final isSpeaking = _speakingWord == entry.english;

    return Material(
      color: const Color(0xFFFDFBF7),
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: const Color(0xFFE8DECF),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x064A3B32),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18.0 : 16.0,
          vertical: isTablet ? 14.0 : 12.0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: English word + Mundari meaning
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Row with English word and Category Tag
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.english,
                          style: TextStyle(
                            fontFamily: AppTypography.headingFontFamily,
                            fontSize: isTablet ? 18.0 : 16.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4ECE1),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Text(
                          entry.category.label,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF765E49),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),

                  // Mundari translation line
                  Row(
                    children: [
                      const Text(
                        'Mundari: ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF765E49),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          entry.isAvailable ? entry.mundari : 'Unavailable',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: isTablet ? 17.0 : 15.0,
                            fontWeight: FontWeight.w700,
                            color: entry.isAvailable
                                ? const Color(0xFF671D21)
                                : const Color(0xFF95806E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10.0),

            // Right: Speaker Icon Button
            Material(
              color: isSpeaking
                  ? const Color(0xFF671D21)
                  : const Color(0xFFF4ECE1),
              borderRadius: BorderRadius.circular(12.0),
              child: InkWell(
                onTap: () => _playPronunciation(entry),
                borderRadius: BorderRadius.circular(12.0),
                splashColor: const Color(0xFF671D21).withValues(alpha: 0.2),
                child: Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isSpeaking
                          ? const Color(0xFF671D21)
                          : const Color(0xFFD8C6AC),
                      width: 1.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      isSpeaking
                          ? Icons.volume_up_rounded
                          : Icons.volume_up_outlined,
                      size: 22.0,
                      color: isSpeaking
                          ? Colors.white
                          : const Color(0xFF671D21),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF4ECE1),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Center(
                child: Icon(
                  Icons.search_off_rounded,
                  size: 28.0,
                  color: Color(0xFF95806E),
                ),
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              'No words found',
              style: TextStyle(
                fontFamily: AppTypography.headingFontFamily,
                fontSize: 16.0,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No matching English word for "$_searchQuery"'
                  : 'No words available in this category',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.0,
                color: Color(0xFF765E49),
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 14.0),
              TextButton.icon(
                onPressed: () => _searchController.clear(),
                icon: const Icon(Icons.clear_rounded, size: 16.0),
                label: const Text('Clear search'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF671D21),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
