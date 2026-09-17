import 'package:flutter/material.dart';

import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/mundari_audio_text.dart';
import 'widgets/winding_levels_path.dart';

/// Data structure for bilingual word and sentence pairs.
class TeacherLearningPair {
  const TeacherLearningPair({
    required this.hindi,
    required this.mundari,
  });

  final String hindi;
  final String mundari;
}

/// Screen: Teacher Learning Phase Screen for AYOVAANI.
///
/// Features a structured 3-page pedagogical flow for Level 1 Learning Phase:
/// - Page 1: Common Classroom Words (कक्षा में बार-बार बोले जाने वाले शब्द)
/// - Page 2: Classroom Instructions (कक्षा में छात्रों को दिए जाने वाले निर्देश)
/// - Page 3: Daily Classroom Conversations (दैनिक वार्तालाप वाक्य)
///
/// Every Mundari term includes a clickable audio speaker icon ready for
/// backend audio playback integration.
///
/// Navigation:
/// Page 1 -> Next -> Page 2 -> Next -> Page 3 -> FINISH -> Teacher Phase Popup.
/// Back arrow: Page 3 -> Page 2 -> Page 1 -> Teacher Phase Popup.
class TeacherPhaseScreen extends StatefulWidget {
  const TeacherPhaseScreen({
    super.key,
    required this.phaseName,
    required this.phaseNumber,
    this.levelNumber = 1,
    this.onBack,
    this.onFinish,
    this.onPlayAudio,
    this.onNavigateTab,
    this.isShellTab = false,
  });

  final String phaseName;
  final int phaseNumber;
  final int levelNumber;
  final VoidCallback? onBack;
  final VoidCallback? onFinish;
  final void Function(String mundariText)? onPlayAudio;
  final ValueChanged<int>? onNavigateTab;
  final bool isShellTab;

  @override
  State<TeacherPhaseScreen> createState() => _TeacherPhaseScreenState();
}

class _TeacherPhaseScreenState extends State<TeacherPhaseScreen> {
  int _currentPage = 0; // 0: Page 1, 1: Page 2, 2: Page 3

  // ===========================================================================
  // Page 1: Common Classroom Words (10 pairs)
  // ===========================================================================
  static const List<TeacherLearningPair> _page1Words = [
    TeacherLearningPair(hindi: 'बच्चा', mundari: 'होन'),
    TeacherLearningPair(hindi: 'किताब', mundari: 'किताब'),
    TeacherLearningPair(hindi: 'पानी', mundari: 'दअः'),
    TeacherLearningPair(hindi: 'खाना', mundari: 'जोम-नू'),
    TeacherLearningPair(hindi: 'घर', mundari: 'ओड़अः'),
    TeacherLearningPair(hindi: 'स्कूल', mundari: 'इसकुल'),
    TeacherLearningPair(hindi: 'बैठना', mundari: 'दुब'),
    TeacherLearningPair(hindi: 'उठना', mundari: 'बिरिद्'),
    TeacherLearningPair(hindi: 'आना', mundari: 'हिजुःमे'),
    TeacherLearningPair(hindi: 'जाना', mundari: 'सेनोः'),
  ];

  // ===========================================================================
  // Page 2: Classroom Instructions (10 pairs)
  // ===========================================================================
  static const List<TeacherLearningPair> _page2Instructions = [
    TeacherLearningPair(hindi: 'इधर आओ।', mundari: 'हिजुःमे।'),
    TeacherLearningPair(hindi: 'बैठो।', mundari: 'दुब मे।'),
    TeacherLearningPair(hindi: 'खड़े हो जाओ।', mundari: 'तिंगु कोःमे'),
    TeacherLearningPair(hindi: 'ध्यान से सुनो।', mundari: 'धेआन ते अयुमेपे।'),
    TeacherLearningPair(hindi: 'बोलो।', mundari: 'कजिलेम'),
    TeacherLearningPair(hindi: 'देखो।', mundari: 'लेलेमे'),
    TeacherLearningPair(hindi: 'किताब खोलो।', mundari: 'किताब निइपे'),
    TeacherLearningPair(hindi: 'यहाँ लिखो।', mundari: 'नेरे ओलेमे।'),
    TeacherLearningPair(hindi: 'दोहराओ।', mundari: 'दोहरवएपे'),
    TeacherLearningPair(hindi: 'समझ आया?', mundari: 'बुजव जनम?'),
  ];

  // ===========================================================================
  // Page 3: Daily Classroom Conversations (10 pairs)
  // ===========================================================================
  static const List<TeacherLearningPair> _page3Conversations = [
    TeacherLearningPair(hindi: 'आपका नाम क्या है?', mundari: 'अमगअ लुतुम चेकनअः?'),
    TeacherLearningPair(hindi: 'आप कैसे हैं?', mundari: 'अम चिलका मेनाःमा?'),
    TeacherLearningPair(hindi: 'पानी चाहिए?', mundari: 'दअः लगतिङअ?'),
    TeacherLearningPair(hindi: 'खाना खाया?', mundari: 'मंडी जोम केदा?'),
    TeacherLearningPair(hindi: 'कहाँ जा रहे हो?', mundari: 'कोतेमतना?'),
    TeacherLearningPair(hindi: 'क्या कर रहे हो?', mundari: 'चेनअःम चेकातना?'),
    TeacherLearningPair(hindi: 'यह क्या है?', mundari: 'नेअ चेकनअः?'),
    TeacherLearningPair(hindi: 'मेरा नाम ___ है।', mundari: 'अइञअः नुतुम..... तनअः।'),
    TeacherLearningPair(hindi: 'हाँ / नहीं।', mundari: 'हे/का।'),
    TeacherLearningPair(hindi: 'धन्यवाद।', mundari: 'धन्यवाद।'),
  ];

  void _handleBack() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    } else if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).pop(false);
    }
  }

  void _handleNext() {
    if (_currentPage < 2) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _handleFinish() {
    widget.onFinish?.call();
    Navigator.of(context).pop(true);
  }

  void _handleAudioTap(String mundariText) {
    if (widget.onPlayAudio != null) {
      widget.onPlayAudio!(mundariText);
    } else {
      // Future audio service hook: audio player will play pronunciation
      debugPrint('Playing Mundari pronunciation: $mundariText');
    }
  }

  void _onBottomNavSelected(BuildContext context, int index) {
    if (index == 1) return;
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(index);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);
    final cornerSize = isTablet ? 120.0 : 88.0;

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentPage > 0) {
          setState(() {
            _currentPage--;
          });
        }
      },
      child: AyoScreenBackground(
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
                    child: LevelCornerDecoration(isRight: false, size: cornerSize),
                  ),
                ),

                // Top-right Warli Corner
                Positioned(
                  top: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: LevelCornerDecoration(isRight: true, size: cornerSize),
                  ),
                ),

                // Main Layout
                Column(
                  children: [
                    // Fixed Header
                    _buildHeader(context, isTablet),

                    // Scrollable Learning Content
                    Expanded(
                      child: widget.phaseNumber == 1
                          ? _buildLearningPhaseBody(isTablet)
                          : _buildPlaceholderBody(isTablet),
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
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Header (AyoVaani Logo, Back Button, For Teachers badge, Title, Divider)
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context, bool isTablet) {
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
          // Top bar with Back Button & AyoVaani Logo
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
                    onTap: _handleBack,
                    splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.12),
                    child: Container(
                      width: 38.0,
                      height: 38.0,
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
                        size: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
              AyoLogo(height: logoHeight),
            ],
          ),
          const SizedBox(height: 8.0),

          // "For Teachers" Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.5),
            decoration: BoxDecoration(
              color: const Color(0xFFF7EBEB),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: const Color(0xFFE5B5B8), width: 1.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.co_present_rounded,
                  size: 15.0,
                  color: AppColors.primaryBurgundy,
                ),
                const SizedBox(width: 6.0),
                Text(
                  'For Teachers',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 13.0 : 12.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6.0),

          // Phase Title
          Text(
            widget.phaseName,
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

          // Level Subtitle
          Text(
            'Level ${widget.levelNumber} \u2022 Plan, prepare & teach',
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

  // ---------------------------------------------------------------------------
  // Three-Page Flow for Teacher Learning Phase (Phase 1)
  // ---------------------------------------------------------------------------
  Widget _buildLearningPhaseBody(bool isTablet) {
    final String pageHeading;
    final List<TeacherLearningPair> pairs;
    final bool isSentencePage;
    final bool isLastPage = (_currentPage == 2);

    switch (_currentPage) {
      case 0:
        pageHeading = 'कक्षा में बार-बार बोले जाने वाले शब्द:';
        pairs = _page1Words;
        isSentencePage = false;
        break;
      case 1:
        pageHeading = 'कक्षा में छात्रों को दिए जाने वाले निर्देश:';
        pairs = _page2Instructions;
        isSentencePage = true;
        break;
      case 2:
      default:
        pageHeading =
            'छात्रों से संवाद करने के लिए कक्षा में उपयोग किए जाने वाले दैनिक वार्तालाप वाक्य:';
        pairs = _page3Conversations;
        isSentencePage = true;
        break;
    }

    final horizontalPadding = isTablet ? 40.0 : AppSpacing.md;
    final maxContentWidth = isTablet ? 640.0 : double.infinity;

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: 6.0,
        bottom: 16.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAF6), // Rounded white/ivory card
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: const Color(0xFFEADBCE),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF251E11).withValues(alpha: 0.08),
                  blurRadius: 18.0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(
              isTablet ? 24.0 : 16.0,
              isTablet ? 20.0 : 16.0,
              isTablet ? 24.0 : 16.0,
              isTablet ? 18.0 : 14.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Step Progress Indicator Bar (Page 1 of 3, 2 of 3, 3 of 3)
                _buildProgressIndicator(isTablet),
                const SizedBox(height: 12.0),

                // Category Section Heading
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 7.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F1EB),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color(0xFFE8D7CB),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    pageHeading,
                    style: TextStyle(
                      fontFamilyFallback: const [
                        'Noto Sans Devanagari',
                        'Mangal',
                        'Nirmala UI',
                        'sans-serif',
                      ],
                      fontSize: isTablet ? 15.5 : 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBurgundy,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8.0),

                // Column Header Labels (Hindi on left, Mundari on right)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          'हिन्दी',
                          style: TextStyle(
                            fontFamilyFallback: const [
                              'Noto Sans Devanagari',
                              'Mangal',
                              'sans-serif',
                            ],
                            fontSize: isTablet ? 12.5 : 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF7A6455),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24.0),
                      Expanded(
                        flex: 6,
                        child: Text(
                          'मुंडारी (Mundari)',
                          style: TextStyle(
                            fontFamilyFallback: const [
                              'Noto Sans Devanagari',
                              'Mangal',
                              'sans-serif',
                            ],
                            fontSize: isTablet ? 12.5 : 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBurgundy,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4.0),

                // Internally scrollable list of 10 Word or Sentence Pairs
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Column(
                      children: [
                        for (var index = 0; index < pairs.length; index++) ...[
                          if (index > 0) const SizedBox(height: 7.0),
                          _buildPairRow(
                            pair: pairs[index],
                            isSentence: isSentencePage,
                            isTablet: isTablet,
                            index: index,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),

                // Bottom Action Button: "Next →" on Pages 1 & 2, "FINISH" on Page 3
                _buildActionButton(
                  isLastPage: isLastPage,
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step Progress Indicator
  // ---------------------------------------------------------------------------
  Widget _buildProgressIndicator(bool isTablet) {
    final pageLabels = ['शब्द (Words)', 'निर्देश (Instructions)', 'संवाद (Conversations)'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'भाग ${_currentPage + 1} / 3: ${pageLabels[_currentPage]}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isTablet ? 12.5 : 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7A6455),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Text(
              '${((_currentPage + 1) / 3 * 100).round()}%',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isTablet ? 12.5 : 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBurgundy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6.0),
        Row(
          children: List.generate(3, (index) {
            final isActive = (index <= _currentPage);
            return Expanded(
              child: Container(
                height: 4.5,
                margin: EdgeInsets.only(
                  right: (index < 2) ? 6.0 : 0.0,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryBurgundy
                      : const Color(0xFFEADBCE),
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Individual Pair Row (Hindi on left, Speaker Icon + Mundari on right)
  // ---------------------------------------------------------------------------
  Widget _buildPairRow({
    required TeacherLearningPair pair,
    required bool isSentence,
    required bool isTablet,
    required int index,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: index.isEven ? const Color(0xFFFFFDF9) : const Color(0xFFF9F6F0),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFEFE6DA),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16.0 : 12.0,
        vertical: isSentence ? 10.0 : 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Hindi Word / Sentence
          Expanded(
            flex: 5,
            child: Text(
              pair.hindi,
              style: TextStyle(
                fontFamilyFallback: const [
                  'Noto Sans Devanagari',
                  'Mangal',
                  'Nirmala UI',
                  'sans-serif',
                ],
                fontSize: isTablet ? 15.5 : 14.0,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C2217),
                height: 1.35,
              ),
            ),
          ),

          // Divider glyph "="
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              '=',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isTablet ? 15.0 : 13.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB8A696),
              ),
            ),
          ),

          // Right: Speaker Button + Mundari Word / Sentence
          Expanded(
            flex: 6,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Interactive Clickable Speaker Button (matching student question style)
                MundariAudioButton(
                  text: pair.mundari,
                  onTap: () => _handleAudioTap(pair.mundari),
                  iconSize: isTablet ? 22.0 : 19.0,
                  color: AppColors.primaryBurgundy,
                ),
                const SizedBox(width: 4.0),

                // Mundari Devanagari text
                Expanded(
                  child: Text(
                    pair.mundari,
                    style: TextStyle(
                      fontFamilyFallback: const [
                        'Noto Sans Devanagari',
                        'Mangal',
                        'Nirmala UI',
                        'sans-serif',
                      ],
                      fontSize: isTablet ? 15.5 : 14.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBurgundy,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action Button ("Next →" on Pages 1 & 2, "FINISH" on Page 3)
  // ---------------------------------------------------------------------------
  Widget _buildActionButton({
    required bool isLastPage,
    required bool isTablet,
  }) {
    return Material(
      color: AppColors.primaryBurgundy,
      borderRadius: BorderRadius.circular(22.0),
      elevation: 1.0,
      shadowColor: AppColors.primaryBurgundy.withValues(alpha: 0.35),
      child: InkWell(
        onTap: isLastPage ? _handleFinish : _handleNext,
        borderRadius: BorderRadius.circular(22.0),
        splashColor: Colors.white.withValues(alpha: 0.2),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: isTablet ? 13.0 : 11.5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLastPage ? 'FINISH' : 'Next',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isTablet ? 15.0 : 14.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: isLastPage ? 0.8 : 0.2,
                ),
              ),
              const SizedBox(width: 6.0),
              Icon(
                isLastPage ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                size: isTablet ? 18.0 : 16.0,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Placeholder card for future phases (Phase 2 Practice & Phase 3 Application)
  // ---------------------------------------------------------------------------
  Widget _buildPlaceholderBody(bool isTablet) {
    final horizontalPadding = isTablet ? 40.0 : AppSpacing.md;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 16.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 560.0 : double.infinity,
          ),
          child: Container(
            padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAF6),
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: const Color(0xFFE5D7C3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF251E11).withValues(alpha: 0.08),
                  blurRadius: 18.0,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64.0,
                  height: 64.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBECEB),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5B5B8),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.phaseNumber == 2
                          ? Icons.edit_note_rounded
                          : Icons.workspace_premium_rounded,
                      size: 32.0,
                      color: AppColors.primaryBurgundy,
                    ),
                  ),
                ),
                const SizedBox(height: 18.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0D6),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: const Color(0xFFE5C07A), width: 1.0),
                  ),
                  child: const Text(
                    'Under Preparation',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8C5810),
                    ),
                  ),
                ),
                const SizedBox(height: 14.0),
                Text(
                  widget.phaseName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: isTablet ? 24.0 : 20.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  widget.phaseNumber == 2
                      ? 'Classroom exercises, printable worksheets, and interactive practice activities for your students.'
                      : 'Summative assessments, practical quizzes, and bilingual evaluation tools.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 14.0 : 13.0,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24.0),
                Material(
                  color: AppColors.primaryBurgundy,
                  borderRadius: BorderRadius.circular(22.0),
                  elevation: 1.0,
                  shadowColor: AppColors.primaryBurgundy.withValues(alpha: 0.35),
                  child: InkWell(
                    onTap: _handleBack,
                    borderRadius: BorderRadius.circular(22.0),
                    splashColor: Colors.white.withValues(alpha: 0.2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22.0),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_rounded,
                            size: 16.0,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            'Back to Level Path',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
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
        ),
      ),
    );
  }
}
