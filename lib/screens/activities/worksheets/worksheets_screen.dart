import 'dart:math';
import 'package:flutter/material.dart';
import '../../../app/responsive/responsive.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/english_activities_data.dart';
import '../../../widgets/ayo_bottom_nav_bar.dart';
import '../../../widgets/ayo_logo.dart';
import '../../../widgets/ayo_screen_background.dart';
import '../../../services/worksheet_pdf_service.dart';
import '../../../services/content_generation_service.dart';

class OddOneOutRow {
  final List<EnglishMundariWord> items;
  final int oddIndex;

  const OddOneOutRow({required this.items, required this.oddIndex});
}

/// Reusable Worksheets Screen for ANY chapter of ANY class.
class WorksheetsScreen extends StatefulWidget {
  const WorksheetsScreen({
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
  State<WorksheetsScreen> createState() => _WorksheetsScreenState();
}

class _WorksheetsScreenState extends State<WorksheetsScreen> {
  final ContentGenerationService _ragService = ContentGenerationService();
  int _navIndex = 1;
  int _selectedWorksheet = 0;
  bool _isDownloading = false;
  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();
    _loadWorksheet();
  }

  Future<void> _loadWorksheet({bool forceRefresh = false}) async {
    if (forceRefresh) {
      setState(() => _isRegenerating = true);
    }
    try {
      await _ragService.generateWorksheet(
        widget.chapterName,
        widget.className,
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          _isRegenerating = false;
        });
        if (forceRefresh) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ RAG कार्यपत्रक (Worksheet) पुनः जनरेट एवं सहेजा गया!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[RAG] Failed to load/generate worksheet: $e');
      if (mounted) {
        setState(() => _isRegenerating = false);
      }
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

              // Scrollable Content
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(isTablet),
                        const SizedBox(height: 16.0),
                        _buildHeader(isTablet),
                        const SizedBox(height: 20.0),
                        _buildWorksheetTabs(isTablet),
                        const SizedBox(height: 20.0),
                        _buildWorksheetPreview(isTablet),
                        const SizedBox(height: 24.0),
                        _buildActionButtons(isTablet),
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
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFC88A22), // Warm Amber
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
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chapterName,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: isTablet ? 19.0 : 16.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Downloadable printable handwriting and concept worksheets',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton.filledTonal(
            onPressed: _isRegenerating ? null : () => _loadWorksheet(forceRefresh: true),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFC88A22).withValues(alpha: 0.15),
              foregroundColor: const Color(0xFFC88A22),
            ),
            icon: _isRegenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC88A22)),
                  )
                : const Icon(Icons.refresh_rounded, size: 18),
            tooltip: 'नया RAG वर्कशीट तैयार करें',
          ),
        ],
      ),
    );
  }

  Widget _buildWorksheetTabs(bool isTablet) {
    final sheets = [
      '1. Tracing & Writing',
      '2. Matching & Drawing',
      '3. Riddles',
      '4. Odd One Out',
    ];

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: List.generate(sheets.length, (index) {
        final isSelected = index == _selectedWorksheet;
        return ChoiceChip(
          label: Text(sheets[index]),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedWorksheet = index),
          selectedColor: const Color(0xFFC88A22),
          backgroundColor: const Color(0xFFFDFBF7),
          labelStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
            side: BorderSide(
              color: isSelected ? const Color(0xFFC88A22) : const Color(0xFFE5DACB),
            ),
          ),
        );
      }),
    );
  }

  List<EnglishMundariWord> _getChapterWords() {
    final words = EnglishActivitiesData.getWords(widget.chapterName);
    if (words != null && words.isNotEmpty) {
      return words;
    }
    return const [
      EnglishMundariWord(
        english: 'Banana',
        mundariRoman: 'Kela',
        mundariDevanagari: 'केला',
        meaning: 'Yellow fruit',
        pronunciation: 'buh-nan-uh',
        emoji: '🍌',
        syllables: ['Ba', 'na', 'na'],
      ),
      EnglishMundariWord(
        english: 'Apple',
        mundariRoman: 'Seb',
        mundariDevanagari: 'सेब',
        meaning: 'Red fruit',
        pronunciation: 'ap-uhl',
        emoji: '🍎',
        syllables: ['Ap', 'ple'],
      ),
      EnglishMundariWord(
        english: 'Grapes',
        mundariRoman: 'Angoor',
        mundariDevanagari: 'अंगूर',
        meaning: 'Purple fruit',
        pronunciation: 'grayps',
        emoji: '🍇',
        syllables: ['Grapes'],
      ),
    ];
  }

  List<OddOneOutRow> _getOddOneOutRowsForChapter(String chapterName) {
    final bodyWords = EnglishActivitiesData.getWords('Two Little Hands') ?? [];
    final animalWords = EnglishActivitiesData.getWords('Life Around Us') ?? [];
    final foodWords = EnglishActivitiesData.getWords('The Food We Eat') ?? [];

    final bodyMap = {for (var w in bodyWords) w.english: w};
    final animalMap = {for (var w in animalWords) w.english: w};
    final foodMap = {for (var w in foodWords) w.english: w};

    if (chapterName == 'Two Little Hands') {
      return [
        OddOneOutRow(
          items: [
            bodyMap['Hand']!,
            bodyMap['Leg']!,
            animalMap['Lion']!,
          ],
          oddIndex: 2,
        ),
        OddOneOutRow(
          items: [
            bodyMap['Eye']!,
            foodMap['Roti']!,
            bodyMap['Ear']!,
          ],
          oddIndex: 1,
        ),
        OddOneOutRow(
          items: [
            foodMap['Mango']!,
            bodyMap['Nose']!,
            bodyMap['Mouth']!,
          ],
          oddIndex: 0,
        ),
      ];
    } else if (chapterName == 'Life Around Us') {
      return [
        OddOneOutRow(
          items: [
            animalMap['Lion']!,
            animalMap['Monkey']!,
            foodMap['Milk']!,
          ],
          oddIndex: 2,
        ),
        OddOneOutRow(
          items: [
            bodyMap['Hand']!,
            animalMap['Fish']!,
            animalMap['Elephant']!,
          ],
          oddIndex: 0,
        ),
        OddOneOutRow(
          items: [
            animalMap['Frog']!,
            foodMap['Carrot']!,
            animalMap['Rabbit']!,
          ],
          oddIndex: 1,
        ),
      ];
    } else {
      return [
        OddOneOutRow(
          items: [
            foodMap['Roti']!,
            foodMap['Milk']!,
            bodyMap['Leg']!,
          ],
          oddIndex: 2,
        ),
        OddOneOutRow(
          items: [
            animalMap['Frog']!,
            foodMap['Mango']!,
            foodMap['Carrot']!,
          ],
          oddIndex: 0,
        ),
        OddOneOutRow(
          items: [
            foodMap['Butter']!,
            bodyMap['Ear']!,
            foodMap['Fruits']!,
          ],
          oddIndex: 1,
        ),
      ];
    }
  }

  Widget _buildWorksheetPreview(bool isTablet) {
    final words = _getChapterWords();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFFE2D4C0),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E4A3B32),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 28.0 : 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet Header with Stacked Bilingual Label
          if (isTablet)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AYOVAANI Classroom Worksheet',
                      style: TextStyle(
                        fontFamily: AppTypography.headingFontFamily,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBurgundy,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      worksheetLabels['AYOVAANI Classroom Worksheet']!,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBurgundy,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name: ____________  Date: ______',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 12.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '${worksheetLabels['Name:']} ____________  ${worksheetLabels['Date:']} ______',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 11.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AYOVAANI Classroom Worksheet',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  worksheetLabels['AYOVAANI Classroom Worksheet']!,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  'Name: ____________  Date: ______',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  '${worksheetLabels['Name:']} ____________  ${worksheetLabels['Date:']} ______',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          const Divider(height: 24.0, thickness: 1.0, color: Color(0xFFE2D4C0)),

          if (_selectedWorksheet == 0)
            _buildTracingAndWritingPreview(words, isTablet)
          else if (_selectedWorksheet == 1)
            _buildMatchingAndDrawingPreview(words, isTablet)
          else if (_selectedWorksheet == 2)
            _buildRiddlesPreview(words, isTablet)
          else
            _buildOddOneOutPreview(words, isTablet),
        ],
      ),
    );
  }

  Widget _buildTracingAndWritingPreview(
    List<EnglishMundariWord> words,
    bool isTablet,
  ) {
    final tracingWords = words.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise: Trace and write the words below',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              worksheetLabels['Exercise: Trace and write the words below']!,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBurgundy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        for (int i = 0; i < tracingWords.length; i++) ...[
          if (i > 0) const SizedBox(height: 16.0),
          _buildSampleTracingRow(
            tracingWords[i].english,
            tracingWords[i].mundariRoman,
            tracingWords[i].mundariDevanagari,
            tracingWords[i].emoji,
          ),
        ],
      ],
    );
  }

  Widget _buildMatchingAndDrawingPreview(
    List<EnglishMundariWord> words,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSentenceMatchingExercise(words, isTablet),
        const SizedBox(height: 24.0),
        const Divider(height: 1.0, thickness: 1.0, color: Color(0xFFE2D4C0)),
        const SizedBox(height: 20.0),
        _buildFunWithWordsExercise(words, isTablet),
      ],
    );
  }

  Widget _buildSentenceMatchingExercise(
    List<EnglishMundariWord> words,
    bool isTablet,
  ) {
    final sentences = EnglishActivitiesData.getSentences(widget.chapterName) ?? [];
    if (sentences.isEmpty) return const SizedBox.shrink();

    final wordMap = {for (var w in words) w.english: w};

    // Deterministic shuffle for right column matching
    final shuffledSentences = List<BilingualSentence>.from(sentences)
      ..shuffle(Random(widget.chapterNumber + 42));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise 1: Draw lines to match each picture to its sentence',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              worksheetLabels['Exercise 1: Draw lines to match each picture to its sentence']!,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBurgundy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),
        for (int i = 0; i < sentences.length; i++) ...[
          if (i > 0) const SizedBox(height: 12.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Emoji Image Box
              Container(
                width: isTablet ? 52.0 : 44.0,
                height: isTablet ? 52.0 : 44.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFC88A22), width: 1.2),
                ),
                child: Center(
                  child: Text(
                    wordMap[sentences[i].relatedWord]?.emoji ?? '📖',
                    style: TextStyle(fontSize: isTablet ? 26.0 : 22.0),
                  ),
                ),
              ),
              const SizedBox(width: 6.0),
              const Text(
                '•',
                style: TextStyle(
                  color: Color(0xFFC88A22),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Middle: Dotted connecting line space
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  height: 1.5,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5DACB),
                  ),
                ),
              ),

              // Right: Shuffled Sentence Box with Odia script sentence
              const Text(
                '•',
                style: TextStyle(
                  color: Color(0xFFC88A22),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6.0),
              Flexible(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7F2),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFEDE4D7), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        shuffledSentences[i].englishSentence,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isTablet ? 13.0 : 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        shuffledSentences[i].mundariOdia,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: isTablet ? 12.0 : 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBurgundy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFunWithWordsExercise(
    List<EnglishMundariWord> words,
    bool isTablet,
  ) {
    final sampleWords = words.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise 2: Fun with Words - Read the syllables',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              worksheetLabels['Exercise 2: Fun with Words - Read the syllables']!,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBurgundy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14.0),
        for (int i = 0; i < sampleWords.length; i++) ...[
          if (i > 0) const SizedBox(height: 10.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: const Color(0xFFEDE4D7)),
            ),
            child: Row(
              children: [
                // Syllable boxes
                Expanded(
                  child: Wrap(
                    spacing: 6.0,
                    runSpacing: 4.0,
                    children: sampleWords[i].syllables.map((syl) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: const Color(0xFFC88A22),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          syl.toLowerCase(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: isTablet ? 14.0 : 13.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 8.0),

                // Arrow / Connector
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 16.0,
                  color: Color(0xFFC88A22),
                ),
                const SizedBox(width: 10.0),

                // Bilingual Mundari Translation
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '( ${sampleWords[i].mundariRoman} / ',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: isTablet ? 13.0 : 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBurgundy,
                          ),
                        ),
                        TextSpan(
                          text: '${sampleWords[i].mundariDevanagari} )',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: isTablet ? 13.0 : 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBurgundy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRiddlesPreview(
    List<EnglishMundariWord> words,
    bool isTablet,
  ) {
    final riddles = EnglishActivitiesData.getRiddles(widget.chapterName) ?? [];
    if (riddles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise: Read the riddles and write the answers below',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              worksheetLabels['Exercise: Read the riddles and write the answers below']!,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBurgundy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        for (int i = 0; i < riddles.length; i++) ...[
          if (i > 0) const SizedBox(height: 14.0),
          Container(
            padding: EdgeInsets.all(isTablet ? 16.0 : 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFEDE4D7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC88A22),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Riddle ${i + 1}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            riddles[i].englishRiddle,
                            style: TextStyle(
                              fontFamily: AppTypography.headingFontFamily,
                              fontSize: isTablet ? 15.0 : 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          Text(
                            riddles[i].mundariDevanagari,
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: isTablet ? 13.0 : 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBurgundy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),

                // Student Answer Line with Stacked Odia Label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Answer: _______________________',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF8B7361),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '${worksheetLabels['Answer:']} _______________________',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryBurgundy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),

                // Teacher/Parent Answer Key
                Row(
                  children: [
                    const Text(
                      'Answer key: ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9E8B7A),
                      ),
                    ),
                    Text(
                      '${riddles[i].answerEnglish} ',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF9E8B7A),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '( ${riddles[i].answerMundariRoman} / ',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9E8B7A),
                            ),
                          ),
                          TextSpan(
                            text: '${riddles[i].answerMundariDevanagari} )',
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9E8B7A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOddOneOutPreview(
    List<EnglishMundariWord> words,
    bool isTablet,
  ) {
    final rows = _getOddOneOutRowsForChapter(widget.chapterName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise: Circle the odd one out in each row below',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              worksheetLabels['Exercise: Circle the odd one out in each row below']!,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBurgundy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        for (int r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: 14.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFEDE4D7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Row ${r + 1}:',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFC88A22),
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (int itemIndex = 0; itemIndex < 3; itemIndex++) ...[
                      _buildOddOneOutItemBox(
                        rows[r].items[itemIndex],
                        isTablet,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOddOneOutItemBox(
    EnglishMundariWord word,
    bool isTablet,
  ) {
    return Container(
      width: isTablet ? 110.0 : 92.0,
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE2D4C0), width: 1.2),
      ),
      child: Column(
        children: [
          // Emoji
          Text(
            word.emoji,
            style: TextStyle(fontSize: isTablet ? 28.0 : 22.0),
          ),
          const SizedBox(height: 4.0),

          // English Word
          Text(
            word.english,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: isTablet ? 12.5 : 11.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2.0),

          // Bilingual Mundari
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '( ${word.mundariRoman} / ',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 10.5 : 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
                TextSpan(
                  text: '${word.mundariDevanagari} )',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 10.5 : 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6.0),

          // Printable Circle / Checkbox
          Container(
            width: 18.0,
            height: 18.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC88A22), width: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleTracingRow(
    String word,
    String mundariRoman,
    String mundariDevanagari,
    String emoji,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFEDE4D7)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24.0)),
          const SizedBox(width: 10.0),
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  word,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (mundariRoman.isNotEmpty || mundariDevanagari.isNotEmpty) ...[
                  const SizedBox(height: 1.0),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '( $mundariRoman / ',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBurgundy,
                          ),
                        ),
                        TextSpan(
                          text: '$mundariDevanagari )',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBurgundy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            flex: 3,
            child: Container(
              height: 2.0,
              color: const Color(0xFFD4C7B5),
            ),
          ),
          const SizedBox(width: 10.0),
          Flexible(
            flex: 2,
            child: Text(
              word,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15.0,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.5,
                color: Color(0xFFB0A294),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16.0,
      runSpacing: 12.0,
      children: [
        ElevatedButton.icon(
          onPressed: _isDownloading ? null : () async {
            setState(() => _isDownloading = true);
            try {
              await WorksheetPdfService.printOrShare(
                chapterName: widget.chapterName,
                className: widget.className,
                words: _getChapterWords(),
              );
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error generating PDF: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } finally {
              if (mounted) setState(() => _isDownloading = false);
            }
          },
          icon: _isDownloading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.download_rounded, color: Colors.white, size: 20.0),
          label: Text(
            _isDownloading ? 'Generating...' : 'Download PDF',
            style: const TextStyle(
                fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC88A22),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _isDownloading ? null : () async {
            setState(() => _isDownloading = true);
            try {
              await WorksheetPdfService.printOrShare(
                chapterName: widget.chapterName,
                className: widget.className,
                words: _getChapterWords(),
              );
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error printing: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } finally {
              if (mounted) setState(() => _isDownloading = false);
            }
          },
          icon: const Icon(Icons.print_rounded, color: AppColors.textPrimary, size: 20.0),
          label: const Text(
            'Print',
            style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 14.0),
            side: const BorderSide(color: Color(0xFFC88A22), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
        ),
      ],
    );
  }
}
