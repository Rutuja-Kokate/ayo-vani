import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/mundari_audio_text.dart';
import '../../services/tts_service.dart';
import '../learn/widgets/phase_selection_dialog.dart';

/// Supported Question Types in the AyoVani learning flow.
enum QuestionType {
  /// Single-choice multiple choice question (Questions 1 to 4)
  mcq,

  /// Match the correct meanings question (Question 5)
  matching,
}

/// Data model representing a Question in the AyoVani learning flow.
class Phase1QuestionData {
  const Phase1QuestionData({
    required this.questionNumber,
    required this.totalQuestions,
    required this.progressValue,
    required this.progressPercentText,
    required this.instruction,
    required this.englishHelperText,
    this.type = QuestionType.mcq,
    // For MCQ
    this.word = '',
    this.options = const [],
    this.correctAnswer = '',
    // For Matching
    this.leftColumnHeading = 'मुंडारी शब्द',
    this.rightColumnHeading = 'हिंदी अर्थ',
    this.leftItems = const [],
    this.rightItems = const [],
    this.correctPairs = const {},
    required this.feedbackExplanation,
    this.chapterLabel = 'First • Ch 1',
    this.levelLabel = 'Level 1',
  });

  final int questionNumber;
  final int totalQuestions;
  final double progressValue;
  final String progressPercentText;
  final String instruction;
  final String englishHelperText;
  final QuestionType type;

  // MCQ fields
  final String word;
  final List<String> options;
  final String correctAnswer;

  // Matching fields
  final String leftColumnHeading;
  final String rightColumnHeading;
  final List<String> leftItems;
  final List<String> rightItems;
  final Map<int, int> correctPairs; // leftIndex -> rightIndex

  final String feedbackExplanation;
  final String chapterLabel;
  final String levelLabel;

  int get correctIndex => options.indexOf(correctAnswer);
}

/// Level 1 → Phase 1 Question Flow Screen for AYOVAANI.
///
/// Data-driven question runner displaying:
/// - Question 1: "एंगा" -> "माँ" (Q 1/5, 20%)
/// - Question 2: "अपुते" -> "पिता" (Q 2/5, 40%)
/// - Question 3: "हगा" -> "भाई" (Q 3/5, 60%)
/// - Question 4: "मिसी" -> "बहन" (4 options: भाई, बहन, माँ, पिता) (Q 4/5, 80%)
/// - Question 5: Match the meanings (Q 5/5, 100%)
///   मुंडारी शब्द: कोड़ा, कुड़िहोन, दुअर, लिजअः, चटु
///   हिंदी अर्थ: दरवाजा, पति, कपड़ा, बर्तन, पत्नी
///
/// Follows the exact visual template, styling, responsive sizing, and
/// larger squirrel cartoon display without UI overlap.
class Phase1Question1Screen extends StatefulWidget {
  const Phase1Question1Screen({
    super.key,
    this.initialQuestionIndex = 0,
    this.questions = defaultQuestions,
    this.onBack,
    this.onNavigateTab,
    this.onNextQuestion,
    this.onCompletePhase,
    this.onPlayMundariAudio,
  });

  final int initialQuestionIndex;
  final List<Phase1QuestionData> questions;
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;
  final VoidCallback? onNextQuestion;
  final VoidCallback? onCompletePhase;
  final ValueChanged<String>? onPlayMundariAudio;

  /// Canonical Phase 1 Question dataset (Questions 1 to 5)
  static const List<Phase1QuestionData> defaultQuestions = [
    // -------------------------------------------------------------------------
    // Question 1
    // -------------------------------------------------------------------------
    Phase1QuestionData(
      questionNumber: 1,
      totalQuestions: 5,
      progressValue: 0.20,
      progressPercentText: '20%',
      type: QuestionType.mcq,
      instruction: 'सरते ओरोतो सलाएमे',
      englishHelperText: '(choose the correct meaning)',
      word: 'एंगा',
      options: [
        'माँ', // Must be spelled exactly with nasalization 'माँ'
        'पिता',
        'भाई',
      ],
      correctAnswer: 'माँ',
      feedbackExplanation: '"एंगा" का अर्थ "माँ" होता है।',
    ),

    // -------------------------------------------------------------------------
    // Question 2
    // -------------------------------------------------------------------------
    Phase1QuestionData(
      questionNumber: 2,
      totalQuestions: 5,
      progressValue: 0.40,
      progressPercentText: '40%',
      type: QuestionType.mcq,
      instruction: 'सरते ओरोतो सलाएमे',
      englishHelperText: '(choose the correct meaning)',
      word: 'अपुते',
      options: [
        'भाई',
        'पिता',
        'माँ',
      ],
      correctAnswer: 'पिता',
      feedbackExplanation: '"अपुते" का अर्थ "पिता" होता है।',
    ),

    // -------------------------------------------------------------------------
    // Question 3
    // -------------------------------------------------------------------------
    Phase1QuestionData(
      questionNumber: 3,
      totalQuestions: 5,
      progressValue: 0.60,
      progressPercentText: '60%',
      type: QuestionType.mcq,
      instruction: 'सरते ओरोतो सलाएमे',
      englishHelperText: '(choose the correct meaning)',
      word: 'हगा',
      options: [
        'पिता',
        'भाई',
        'माँ',
      ],
      correctAnswer: 'भाई',
      feedbackExplanation: '"हगा" का अर्थ "भाई" होता है।',
    ),

    // -------------------------------------------------------------------------
    // Question 4 (4 Options)
    // -------------------------------------------------------------------------
    Phase1QuestionData(
      questionNumber: 4,
      totalQuestions: 5,
      progressValue: 0.80,
      progressPercentText: '80%',
      type: QuestionType.mcq,
      instruction: 'सरते ओरोतो सलाएमे',
      englishHelperText: '(choose the correct meaning)',
      word: 'मिसी',
      options: [
        'भाई',
        'बहन',
        'माँ',
        'पिता',
      ],
      correctAnswer: 'बहन',
      feedbackExplanation: '"मिसी" का अर्थ "बहन" होता है।',
    ),

    // -------------------------------------------------------------------------
    // Question 5 (Matching Question: 5 Mundari words -> 5 Hindi meanings)
    // -------------------------------------------------------------------------
    Phase1QuestionData(
      questionNumber: 5,
      totalQuestions: 5,
      progressValue: 1.0,
      progressPercentText: '100%',
      type: QuestionType.matching,
      instruction: 'सरते ओरोतो को जोकाएपे',
      englishHelperText: '(match the correct meanings)',
      leftColumnHeading: 'मुंडारी शब्द',
      rightColumnHeading: 'हिंदी अर्थ',
      leftItems: [
        'कोड़ा',
        'कुड़िहोन',
        'दुअर',
        'लिजअः',
        'चटु',
      ],
      rightItems: [
        'दरवाजा',
        'पति',
        'कपड़ा',
        'बर्तन',
        'पत्नी',
      ],
      correctPairs: {
        0: 1, // कोड़ा → पति
        1: 4, // कुड़िहोन → पत्नी
        2: 0, // दुअर → दरवाजा
        3: 2, // लिजअः → कपड़ा
        4: 3, // चटु → बर्तन
      },
      feedbackExplanation:
          '"कोड़ा" → "पति" • "कुड़िहोन" → "पत्नी" • "दुअर" → "दरवाजा" • "लिजअः" → "कपड़ा" • "चटु" → "बर्तन"',
    ),
  ];

  @override
  State<Phase1Question1Screen> createState() => _Phase1Question1ScreenState();
}

class _Phase1Question1ScreenState extends State<Phase1Question1Screen> {
  int _navIndex = 1; // "Learn" tab active
  late int _currentQuestionIndex;

  // MCQ state
  int? _selectedOptionIndex; // Initially null (none selected)

  // Matching state (Question 5)
  int? _selectedLeftIndex;
  int? _selectedRightIndex;
  final Map<int, int> _matches = {}; // leftIndex -> rightIndex

  bool _isChecked = false;
  bool _isCorrect = false;

  Phase1QuestionData get _currentQuestion => widget.questions[_currentQuestionIndex];
  bool get _isMatching => _currentQuestion.type == QuestionType.matching;

  @override
  void initState() {
    super.initState();
    TtsService().init();
    _currentQuestionIndex = widget.initialQuestionIndex.clamp(
      0,
      widget.questions.isNotEmpty ? widget.questions.length - 1 : 0,
    );
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

  // ---------------------------------------------------------------------------
  // Mundari Audio Pronunciation Trigger
  // ---------------------------------------------------------------------------
  void _playMundariAudio(String text) {
    if (widget.onPlayMundariAudio != null) {
      widget.onPlayMundariAudio!(text);
    } else {
      TtsService().speak(text);
    }
  }

  // ---------------------------------------------------------------------------
  // MCQ Selection Logic (Questions 1 to 4)
  // ---------------------------------------------------------------------------
  void _selectOption(int index) {
    if (_isChecked && _isCorrect) return;

    setState(() {
      _selectedOptionIndex = index;
      _isChecked = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Matching Selection Logic (Question 5)
  // ---------------------------------------------------------------------------
  void _onLeftItemTap(int leftIndex) {
    if (_isChecked && _isCorrect) return;

    setState(() {
      _isChecked = false;

      // If a right item is already selected, pair them!
      if (_selectedRightIndex != null) {
        final r = _selectedRightIndex!;
        _matches.remove(leftIndex);
        _matches.removeWhere((k, v) => v == r);
        _matches[leftIndex] = r;
        _selectedLeftIndex = null;
        _selectedRightIndex = null;
      } else {
        // If this left item was already matched, unpair so user can reselect
        if (_matches.containsKey(leftIndex)) {
          _matches.remove(leftIndex);
          _selectedLeftIndex = leftIndex;
        } else if (_selectedLeftIndex == leftIndex) {
          // Deselect
          _selectedLeftIndex = null;
        } else {
          _selectedLeftIndex = leftIndex;
        }
      }
    });
  }

  void _onRightItemTap(int rightIndex) {
    if (_isChecked && _isCorrect) return;

    setState(() {
      _isChecked = false;

      // If a left item is already selected, pair them!
      if (_selectedLeftIndex != null) {
        final l = _selectedLeftIndex!;
        _matches.remove(l);
        _matches.removeWhere((k, v) => v == rightIndex);
        _matches[l] = rightIndex;
        _selectedLeftIndex = null;
        _selectedRightIndex = null;
      } else {
        // If this right item was already matched, unpair so user can reselect
        if (_matches.containsValue(rightIndex)) {
          _matches.removeWhere((k, v) => v == rightIndex);
          _selectedRightIndex = rightIndex;
        } else if (_selectedRightIndex == rightIndex) {
          // Deselect
          _selectedRightIndex = null;
        } else {
          _selectedRightIndex = rightIndex;
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Check / Continue Logic
  // ---------------------------------------------------------------------------
  void _handleCheckOrContinue() {
    // 1. If currently in answered + correct state, tapping action advances or finishes
    if (_isChecked && _isCorrect) {
      final isLastQuestion = _currentQuestionIndex == widget.questions.length - 1;
      if (isLastQuestion) {
        _finishPhase();
      } else {
        _advanceToNextQuestion();
      }
      return;
    }

    if (_isMatching) {
      // Validate matching: all 5 pairs must be matched
      if (_matches.length < _currentQuestion.leftItems.length) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primaryBurgundy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            content: const Text(
              'कृपया सभी 5 जोड़ों का मिलान करें (Please match all 5 pairs!)',
              style: TextStyle(
                fontFamilyFallback: ['Noto Sans Devanagari', 'Mangal', 'sans-serif'],
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Check each pair against correctPairs
      bool allCorrect = true;
      for (final entry in _currentQuestion.correctPairs.entries) {
        if (_matches[entry.key] != entry.value) {
          allCorrect = false;
          break;
        }
      }

      setState(() {
        _isChecked = true;
        _isCorrect = allCorrect;
      });
    } else {
      // Validate MCQ selection
      if (_selectedOptionIndex == null) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primaryBurgundy,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            content: const Text(
              'Please select an answer first!',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      final selectedText = _currentQuestion.options[_selectedOptionIndex!];
      final isAnswerCorrect = (selectedText == _currentQuestion.correctAnswer);

      setState(() {
        _isChecked = true;
        _isCorrect = isAnswerCorrect;
      });

      if (isAnswerCorrect) {
        _playMundariAudio(_currentQuestion.correctAnswer);
      }
    }
  }

  void _advanceToNextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _selectedLeftIndex = null;
        _selectedRightIndex = null;
        _matches.clear();
        _isChecked = false;
        _isCorrect = false;
      });
    } else {
      _finishPhase();
    }
  }

  void _finishPhase() {
    PhaseSelectionDialog.showAfterPhaseCompletion(
      context: context,
      levelNumber: 1,
      levelTitle: 'Level 1',
      onCompletePhase: widget.onCompletePhase,
    );
  }

  void _showPhaseCompletionDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFFFCFAF6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Color(0xFFE5D7C3), width: 1.2),
        ),
        title: Row(
          children: const [
            Icon(Icons.emoji_events_rounded, color: Color(0xFFC0882A), size: 28.0),
            SizedBox(width: 10.0),
            Flexible(
              child: Text(
                'Phase 1 Completed!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF251E11),
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'शानदार! आपने Phase 1 के सभी 5 प्रश्नों को सफलतापूर्वक पूरा कर लिया है!\n(Congratulations! You have completed all 5 questions of Phase 1.)',
          style: TextStyle(
            fontFamilyFallback: ['Noto Sans Devanagari', 'Mangal', 'sans-serif'],
            fontSize: 14.0,
            color: Color(0xFF4A3B32),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).maybePop();
            },
            child: const Text(
              'FINISH',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                color: Color(0xFF671D21),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = Responsive.isTabletOrLarger(context) || screenWidth >= 600;

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // 1. Top-Left Traditional Warli/Indian Corner Ornament
              Positioned(
                top: 0,
                left: 0,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/corner-design.png',
                    width: isTablet ? 115.0 : 88.0,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/corner-desing.png',
                      width: isTablet ? 115.0 : 88.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // 2. Top-Right Traditional Warli/Indian Corner Ornament (Flipped)
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: Transform.flip(
                    flipX: true,
                    child: Image.asset(
                      'assets/images/corner-design.png',
                      width: isTablet ? 115.0 : 88.0,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/corner-desing.png',
                        width: isTablet ? 115.0 : 88.0,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Subtle Natural Grass Background Decoration (grass1.png & grass2.png)
              Positioned.fill(
                child: _AyoQuestionBackgroundDecoration(isTablet: isTablet),
              ),

              // 4. Main Scrollable Page Content
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.only(
                  left: isTablet ? 36.0 : 18.0,
                  right: isTablet ? 36.0 : 18.0,
                  top: 10.0,
                  bottom: 36.0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 680.0 : 440.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header: Circular Back Button & Centered AyoVaani Logo
                        _buildHeader(isTablet),
                        const SizedBox(height: 12.0),

                        // Progress Header Card: "First • Ch 1" | "Level 1" | "Q X/5" | Progress%
                        _buildProgressCard(isTablet),
                        const SizedBox(height: 16.0),

                        // Cartoon Character (Noticeably Larger) + Speech Bubble + Decorative Question Card
                        _buildCartoonAndQuestionSection(isTablet),
                        const SizedBox(height: 18.0),

                        // Question Content: Either MCQ Options (Q1-Q4) OR Matching Columns (Q5)
                        if (_isMatching)
                          _buildMatchingSection(isTablet)
                        else
                          _buildAnswerOptions(isTablet),
                        const SizedBox(height: 16.0),

                        // Optional Feedback Message Banner (Shown on check)
                        if (_isChecked) ...[
                          _buildFeedbackBanner(isTablet),
                          const SizedBox(height: 14.0),
                        ],

                        // Full-Width Burgundy "CHECK" / "CONTINUE" Action Button
                        _buildCheckButton(isTablet),
                        const SizedBox(height: 12.0),
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

  // ---------------------------------------------------------------------------
  // Top Header (Back Button & Official AyoVaani Logo)
  // ---------------------------------------------------------------------------
  Widget _buildHeader(bool isTablet) {
    return SizedBox(
      height: isTablet ? 82.0 : 70.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular White Back Button with Black Arrow
          Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2.0,
              shadowColor: Colors.black.withValues(alpha: 0.10),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _handleBack,
                splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.12),
                child: Container(
                  width: isTablet ? 46.0 : 42.0,
                  height: isTablet ? 46.0 : 42.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE8DECF),
                      width: 1.0,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF251E11),
                      size: 22.0,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Official AyoVaani Centered Logo
          Center(
            child: AyoLogo(
              height: isTablet ? 80.0 : 66.0,
              assetPath: 'assets/images/ayovaani_logo.png',
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Progress Header Card
  // ---------------------------------------------------------------------------
  Widget _buildProgressCard(bool isTablet) {
    final currentQ = _currentQuestion;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFFEBE3D7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF251E11).withValues(alpha: 0.05),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Green Pill "First • Ch 1", "Level 1", "Q X/5"
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Left: Green Pill "First • Ch 1"
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C6647), // Muted dark olive green
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        currentQ.chapterLabel,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),

                    // "Level 1"
                    Flexible(
                      child: Text(
                        currentQ.levelLabel,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: isTablet ? 16.0 : 15.0,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF251E11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),

              // Right: "Q X/5"
              Text(
                'Q ${currentQ.questionNumber}/${currentQ.totalQuestions}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: isTablet ? 14.0 : 13.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A3B32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Row 2: Horizontal Progress Bar + Percentage Label
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6.0),
                  child: LinearProgressIndicator(
                    value: currentQ.progressValue,
                    minHeight: 7.0,
                    backgroundColor: const Color(0xFFE4DCD0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF671D21), // AyoVaani deep burgundy
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Text(
                currentQ.progressPercentText,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A3B32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cartoon + Question Area (Noticeably Larger Cartoon)
  // ---------------------------------------------------------------------------
  Widget _buildCartoonAndQuestionSection(bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final cartoonWidth = isTablet
            ? 230.0
            : (totalWidth * 0.43).clamp(148.0, 164.0);
        final cartoonHeight = isTablet ? 215.0 : 158.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Left Column: Speech Bubble + Larger Squirrel Cartoon
            SizedBox(
              width: cartoonWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Speech bubble: "Let's learn together!"
                  _buildSpeechBubble(isTablet),
                  const SizedBox(height: 4.0),

                  // Squirrel Cartoon Asset: assets/images/cartoon.png (Enlarged)
                  SizedBox(
                    width: cartoonWidth,
                    height: cartoonHeight,
                    child: Image.asset(
                      'assets/images/cartoon.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),

            // Right Column: Decorative Question Card
            Expanded(
              child: _buildQuestionCard(isTablet),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Speech Bubble Above Cartoon
  // ---------------------------------------------------------------------------
  Widget _buildSpeechBubble(bool isTablet) {
    return CustomPaint(
      painter: const _SpeechBubblePainter(),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          isTablet ? 12.0 : 9.0,
          isTablet ? 9.0 : 7.0,
          isTablet ? 12.0 : 9.0,
          isTablet ? 13.0 : 11.0,
        ),
        child: Text(
          "Let's learn\ntogether!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isTablet ? 12.5 : 11.0,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF251E11),
            height: 1.2,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Decorative Question Card (Off-white, Dark Green Outline, Green Corner Mandala)
  // ---------------------------------------------------------------------------
  Widget _buildQuestionCard(bool isTablet) {
    final currentQ = _currentQuestion;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF6), // Light cream
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFF4C6647), // Dark green outline
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF251E11).withValues(alpha: 0.08),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          children: [
            // Top-Right Green Mandala Corner
            Positioned(
              top: 0,
              right: 0,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(38.0, 38.0),
                  painter: const _GreenCornerMandalaPainter(corner: _Corner.topRight),
                ),
              ),
            ),

            // Bottom-Left Green Mandala Corner
            Positioned(
              bottom: 0,
              left: 0,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(38.0, 38.0),
                  painter: const _GreenCornerMandalaPainter(corner: _Corner.bottomLeft),
                ),
              ),
            ),

            // Bottom-Right Green Mandala Corner
            Positioned(
              bottom: 0,
              right: 0,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(38.0, 38.0),
                  painter: const _GreenCornerMandalaPainter(corner: _Corner.bottomRight),
                ),
              ),
            ),

            // Card Inner Text Hierarchy
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 18.0 : 10.0,
                vertical: isTablet ? 22.0 : (_isMatching ? 18.0 : 14.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Question instruction in Devanagari with Speaker Icon (Burgundy)
                  Center(
                    child: MundariAudioText(
                      text: currentQ.instruction,
                      onAudioTap: () => _playMundariAudio(currentQ.instruction),
                      iconSize: isTablet ? 24.0 : 20.0,
                      iconColor: const Color(0xFF671D21),
                      spacing: isTablet ? 7.0 : 5.0,
                      style: TextStyle(
                        fontFamilyFallback: const [
                          'Noto Sans Devanagari',
                          'Mangal',
                          'Nirmala UI',
                          'sans-serif',
                        ],
                        fontSize: isTablet ? 19.5 : 16.0,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF671D21), // AyoVaani burgundy
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3.0),

                  // English explanation
                  Text(
                    currentQ.englishHelperText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: isTablet ? 12.5 : 11.0,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4A3B32),
                    ),
                  ),

                  // Prominently displayed word with Speaker Icon (Only for MCQ questions)
                  if (!_isMatching && currentQ.word.isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    Center(
                      child: MundariAudioText(
                        text: currentQ.word,
                        onAudioTap: () => _playMundariAudio(currentQ.word),
                        iconSize: isTablet ? 34.0 : 28.0,
                        iconColor: const Color(0xFF671D21),
                        spacing: isTablet ? 10.0 : 8.0,
                        style: TextStyle(
                          fontFamilyFallback: const [
                            'Noto Sans Devanagari',
                            'Mangal',
                            'Nirmala UI',
                            'sans-serif',
                          ],
                          fontSize: isTablet ? 42.0 : 34.0,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E170E),
                          letterSpacing: 0.5,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Matching Columns Section (Question 5)
  // ---------------------------------------------------------------------------
  Widget _buildMatchingSection(bool isTablet) {
    final currentQ = _currentQuestion;

    return Column(
      children: [
        // Column Headings: "मुंडारी शब्द" & "हिंदी अर्थ"
        Row(
          children: [
            Expanded(
              child: _buildColumnHeader(currentQ.leftColumnHeading, isTablet),
            ),
            SizedBox(width: isTablet ? 16.0 : 10.0),
            Expanded(
              child: _buildColumnHeader(currentQ.rightColumnHeading, isTablet),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 12.0 : 8.0),

        // Two Columns of 5 Cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Mundari Words
            Expanded(
              child: Column(
                children: [
                  for (int i = 0; i < currentQ.leftItems.length; i++) ...[
                    _buildMatchingCard(
                      text: currentQ.leftItems[i],
                      index: i,
                      isLeft: true,
                      isTablet: isTablet,
                    ),
                    if (i < currentQ.leftItems.length - 1)
                      SizedBox(height: isTablet ? 10.0 : 8.0),
                ],
              ],
            ),
          ),
          SizedBox(width: isTablet ? 16.0 : 10.0),

          // Right Column: Hindi Meanings
          Expanded(
            child: Column(
              children: [
                for (int i = 0; i < currentQ.rightItems.length; i++) ...[
                  _buildMatchingCard(
                    text: currentQ.rightItems[i],
                    index: i,
                    isLeft: false,
                    isTablet: isTablet,
                  ),
                  if (i < currentQ.rightItems.length - 1)
                    SizedBox(height: isTablet ? 10.0 : 8.0),
                ],
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildColumnHeader(String title, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: isTablet ? 8.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF4C6647), // Muted dark olive green
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontFamilyFallback: const [
              'Noto Sans Devanagari',
              'Mangal',
              'Nirmala UI',
              'sans-serif',
            ],
            fontSize: isTablet ? 15.0 : 13.0,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchingCard({
    required String text,
    required int index,
    required bool isLeft,
    required bool isTablet,
  }) {
    final currentQ = _currentQuestion;
    final isSelected = isLeft ? (_selectedLeftIndex == index) : (_selectedRightIndex == index);
    final isMatched = isLeft ? _matches.containsKey(index) : _matches.containsValue(index);

    // Determine correctness after CHECK
    bool? isPairCorrect;
    if (_isChecked) {
      if (isLeft) {
        final rightMatch = _matches[index];
        isPairCorrect = (rightMatch != null && currentQ.correctPairs[index] == rightMatch);
      } else {
        int? leftMatch;
        for (final entry in _matches.entries) {
          if (entry.value == index) {
            leftMatch = entry.key;
            break;
          }
        }
        isPairCorrect = (leftMatch != null && currentQ.correctPairs[leftMatch] == index);
      }
    }

    // Colors & indicator logic
    Color backgroundColor = const Color(0xFFFAF6F0);
    Color borderColor = const Color(0xFFB3A596);
    double borderWidth = 1.3;
    Widget indicatorWidget;

    if (_isChecked && isMatched) {
      if (isPairCorrect == true) {
        // Correct pair
        backgroundColor = const Color(0xFFF1F7EE);
        borderColor = const Color(0xFF386633);
        borderWidth = 2.0;
        indicatorWidget = _buildCircleIndicator(
          fillColor: const Color(0xFF386633),
          borderColor: const Color(0xFF386633),
          child: const Icon(Icons.check, color: Colors.white, size: 15.0),
        );
      } else {
        // Incorrect pair
        backgroundColor = const Color(0xFFFDF0EF);
        borderColor = const Color(0xFF9E2A2B);
        borderWidth = 2.0;
        indicatorWidget = _buildCircleIndicator(
          fillColor: const Color(0xFF9E2A2B),
          borderColor: const Color(0xFF9E2A2B),
          child: const Icon(Icons.close_rounded, color: Colors.white, size: 15.0),
        );
      }
    } else if (isSelected) {
      // Actively tapped item waiting for partner
      backgroundColor = const Color(0xFFF6FAF3);
      borderColor = const Color(0xFF4C6647);
      borderWidth = 2.0;
      indicatorWidget = _buildCircleIndicator(
        fillColor: const Color(0xFF4C6647),
        borderColor: const Color(0xFF4C6647),
        child: Container(
          width: 8.0,
          height: 8.0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      );
    } else if (isMatched) {
      // Matched before check
      backgroundColor = const Color(0xFFF6FAF3);
      borderColor = const Color(0xFF4C6647);
      borderWidth = 1.8;
      indicatorWidget = _buildCircleIndicator(
        fillColor: const Color(0xFF4C6647),
        borderColor: const Color(0xFF4C6647),
        child: const Icon(Icons.check, color: Colors.white, size: 14.0),
      );
    } else {
      // Unselected & unmatched
      indicatorWidget = _buildCircleIndicator(
        fillColor: Colors.transparent,
        borderColor: const Color(0xFFB3A596),
        child: null,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF251E11).withValues(alpha: isSelected || isMatched ? 0.06 : 0.02),
            blurRadius: 5.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => isLeft ? _onLeftItemTap(index) : _onRightItemTap(index),
          borderRadius: BorderRadius.circular(14.0),
          splashColor: const Color(0xFF4C6647).withValues(alpha: 0.12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12.0 : 8.0,
              vertical: isTablet ? 14.0 : 10.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Radio-Like Indicator
                indicatorWidget,
                if (isLeft) ...[
                  SizedBox(width: isTablet ? 8.0 : 6.0),
                  MundariAudioButton(
                    text: text,
                    onTap: () => _playMundariAudio(text),
                    iconSize: isTablet ? 22.0 : 18.0,
                    color: const Color(0xFF671D21),
                  ),
                  SizedBox(width: isTablet ? 8.0 : 6.0),
                ] else ...[
                  const SizedBox(width: 10.0),
                ],

                // Devanagari Word/Meaning Text
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamilyFallback: const [
                        'Noto Sans Devanagari',
                        'Mangal',
                        'Nirmala UI',
                        'sans-serif',
                      ],
                      fontSize: isTablet ? 18.5 : 15.0,
                      fontWeight: FontWeight.w700,
                      color: isSelected || isMatched
                          ? const Color(0xFF4C6647)
                          : const Color(0xFF251E11),
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

  // ---------------------------------------------------------------------------
  // Answer Options List (MCQ: Questions 1 to 4)
  // ---------------------------------------------------------------------------
  Widget _buildAnswerOptions(bool isTablet) {
    final currentQ = _currentQuestion;

    return Column(
      children: [
        for (int i = 0; i < currentQ.options.length; i++) ...[
          _buildOptionCard(
            index: i,
            text: currentQ.options[i],
            isTablet: isTablet,
          ),
          if (i < currentQ.options.length - 1) const SizedBox(height: 10.0),
        ],
      ],
    );
  }

  Widget _buildOptionCard({
    required int index,
    required String text,
    required bool isTablet,
  }) {
    final currentQ = _currentQuestion;
    final isSelected = (_selectedOptionIndex == index);

    // Styling based on state
    Color backgroundColor = const Color(0xFFFAF6F0); // Warm cream
    Color borderColor = const Color(0xFF4A3B32); // Dark brown outline
    double borderWidth = 1.3;
    Widget indicatorWidget;

    if (isSelected) {
      if (_isChecked) {
        if (_isCorrect) {
          // Correct state (Green success)
          backgroundColor = const Color(0xFFF1F7EE);
          borderColor = const Color(0xFF386633);
          borderWidth = 2.0;
          indicatorWidget = _buildCircleIndicator(
            fillColor: const Color(0xFF386633),
            borderColor: const Color(0xFF386633),
            child: const Icon(Icons.check, color: Colors.white, size: 17.0),
          );
        } else {
          // Incorrect state (Rust error)
          backgroundColor = const Color(0xFFFDF0EF);
          borderColor = const Color(0xFF9E2A2B);
          borderWidth = 2.0;
          indicatorWidget = _buildCircleIndicator(
            fillColor: const Color(0xFF9E2A2B),
            borderColor: const Color(0xFF9E2A2B),
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 17.0),
          );
        }
      } else {
        // Selected state before checking (Dark Green match)
        backgroundColor = const Color(0xFFF6FAF3);
        borderColor = const Color(0xFF4C6647);
        borderWidth = 2.0;
        indicatorWidget = _buildCircleIndicator(
          fillColor: const Color(0xFF4C6647),
          borderColor: const Color(0xFF4C6647),
          child: const Icon(Icons.check, color: Colors.white, size: 17.0),
        );
      }
    } else {
      // Unselected state
      indicatorWidget = _buildCircleIndicator(
        fillColor: Colors.transparent,
        borderColor: const Color(0xFFB3A596),
        child: null,
      );
    }

    final verticalPad = isTablet
        ? 18.0
        : (currentQ.options.length > 3 ? 12.0 : 14.0);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF251E11).withValues(alpha: isSelected ? 0.06 : 0.02),
            blurRadius: 6.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectOption(index),
          borderRadius: BorderRadius.circular(16.0),
          splashColor: const Color(0xFF4C6647).withValues(alpha: 0.12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: verticalPad,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Radio Button Indicator
                indicatorWidget,
                const SizedBox(width: 16.0),

                // Option Text with Speaker Icon
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MundariAudioButton(
                        text: text,
                        onTap: () => _playMundariAudio(text),
                        iconSize: 22.0,
                        color: isSelected && !_isChecked
                            ? const Color(0xFF4C6647)
                            : const Color(0xFF251E11),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontFamilyFallback: const [
                              'Noto Sans Devanagari',
                              'Mangal',
                              'Nirmala UI',
                              'sans-serif',
                            ],
                            fontSize: isTablet ? 23.0 : 20.0,
                            fontWeight: FontWeight.w700,
                            color: isSelected && !_isChecked
                                ? const Color(0xFF4C6647)
                                : const Color(0xFF251E11),
                          ),
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
    );
  }

  Widget _buildCircleIndicator({
    required Color fillColor,
    required Color borderColor,
    required Widget? child,
  }) {
    return Container(
      width: 22.0,
      height: 22.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: fillColor,
        border: Border.all(
          color: borderColor,
          width: 1.8,
        ),
      ),
      child: child != null ? Center(child: child) : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Visual Feedback Banner (Correct / Incorrect)
  // ---------------------------------------------------------------------------
  Widget _buildFeedbackBanner(bool isTablet) {
    final isCorrect = _isCorrect;
    final currentQ = _currentQuestion;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFEBF5E7) : const Color(0xFFFBECEB),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isCorrect ? const Color(0xFF9BC294) : const Color(0xFFE6A6A6),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isCorrect ? const Color(0xFF386633) : const Color(0xFF9E2A2B),
            size: 24.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCorrect
                      ? 'शानदार! सही उत्तर (Excellent! Correct)'
                      : 'गलत उत्तर (Incorrect)',
                  style: TextStyle(
                    fontFamilyFallback: const [
                      'Noto Sans Devanagari',
                      'Mangal',
                      'sans-serif',
                    ],
                    fontSize: isTablet ? 14.5 : 13.5,
                    fontWeight: FontWeight.w700,
                    color: isCorrect
                        ? const Color(0xFF2B5226)
                        : const Color(0xFF7A1C1D),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  isCorrect
                      ? currentQ.feedbackExplanation
                      : (_isMatching
                          ? 'कुछ जोड़े गलत हैं। कृपया पुनः प्रयास करें।'
                          : 'कृपया पुनः प्रयास करें। कोई दूसरा विकल्प चुनें।'),
                  style: TextStyle(
                    fontFamilyFallback: const [
                      'Noto Sans Devanagari',
                      'Mangal',
                      'sans-serif',
                    ],
                    fontSize: isTablet ? 13.0 : 12.0,
                    fontWeight: FontWeight.w500,
                    color: isCorrect
                        ? const Color(0xFF476B41)
                        : const Color(0xFF8C3839),
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
  // Check / Continue Action Button
  // ---------------------------------------------------------------------------
  Widget _buildCheckButton(bool isTablet) {
    final isCompleted = _isChecked && _isCorrect;
    final isLastQuestion = _currentQuestionIndex == widget.questions.length - 1;
    final String buttonLabel;
    if (!isCompleted) {
      buttonLabel = 'CHECK';
    } else if (isLastQuestion) {
      buttonLabel = 'FINISH';
    } else {
      buttonLabel = 'CONTINUE';
    }

    return Container(
      height: isTablet ? 56.0 : 52.0,
      decoration: BoxDecoration(
        color: const Color(0xFF5E171B), // Deep burgundy / maroon
        borderRadius: BorderRadius.circular(28.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E171B).withValues(alpha: 0.32),
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleCheckOrContinue,
          borderRadius: BorderRadius.circular(28.0),
          splashColor: Colors.white.withValues(alpha: 0.20),
          child: Center(
            child: Text(
              buttonLabel,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: isTablet ? 17.0 : 16.0,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Speech Bubble Painter with Small Tail Pointing Downward Left
// ---------------------------------------------------------------------------
class _SpeechBubblePainter extends CustomPainter {
  const _SpeechBubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height - 6.0);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16.0));

    final fillPaint = Paint()
      ..color = const Color(0xFFFCFAF6)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF4A3B32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    path.addRRect(rrect);

    // Downward-pointing pointer towards the squirrel's paw
    final tailPath = Path()
      ..moveTo(size.width * 0.35, size.height - 6.0)
      ..lineTo(size.width * 0.24, size.height)
      ..lineTo(size.width * 0.46, size.height - 6.0)
      ..close();

    path.addPath(tailPath, Offset.zero);

    canvas.drawShadow(path, const Color(0xFF251E11), 3.0, false);
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Green Corner Mandala Flourish for Question Card
// ---------------------------------------------------------------------------
enum _Corner { topRight, bottomLeft, bottomRight }

class _GreenCornerMandalaPainter extends CustomPainter {
  const _GreenCornerMandalaPainter({required this.corner});

  final _Corner corner;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.save();

    Offset center;
    double startAngle;

    switch (corner) {
      case _Corner.topRight:
        center = Offset(w, 0);
        startAngle = math.pi * 0.5;
        break;
      case _Corner.bottomLeft:
        center = Offset(0, h);
        startAngle = -math.pi * 0.5;
        break;
      case _Corner.bottomRight:
        center = Offset(w, h);
        startAngle = math.pi;
        break;
    }

    final linePaint = Paint()
      ..color = const Color(0xFF4C6647).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Outer concentric arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: w * 0.85),
      startAngle,
      math.pi * 0.5,
      false,
      linePaint,
    );

    // Mid concentric arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: w * 0.58),
      startAngle,
      math.pi * 0.5,
      false,
      linePaint,
    );

    // Inner filled quarter-circle
    final innerPaint = Paint()
      ..color = const Color(0xFF4C6647).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: w * 0.32),
      startAngle,
      math.pi * 0.5,
      true,
      innerPaint,
    );

    // Radiating hatch dots / petal ticks
    final tickPaint = Paint()
      ..color = const Color(0xFF4C6647).withValues(alpha: 0.70)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i <= 5; i++) {
      final angle = startAngle + (i * (math.pi * 0.5 / 6.0));
      final r1 = w * 0.58;
      final r2 = w * 0.76;
      final p1 = Offset(center.dx + r1 * math.cos(angle), center.dy + r1 * math.sin(angle));
      final p2 = Offset(center.dx + r2 * math.cos(angle), center.dy + r2 * math.sin(angle));
      canvas.drawLine(p1, p2, tickPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Reusable Single Grass Asset Item with Subtle Opacity and Horizontal Flip
// ---------------------------------------------------------------------------
class _GrassDecorationItem extends StatelessWidget {
  const _GrassDecorationItem({
    required this.assetPath,
    required this.width,
    this.isFlipped = false,
    this.opacity = 0.50,
  });

  final String assetPath;
  final double width;
  final bool isFlipped;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      assetPath,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
    );

    if (isFlipped) {
      image = Transform.flip(flipX: true, child: image);
    }

    return Opacity(
      opacity: opacity,
      child: image,
    );
  }
}

// ---------------------------------------------------------------------------
// Subtle, Low-Contrast Natural Grass Background Decoration (grass1 & grass2)
// ---------------------------------------------------------------------------
class _AyoQuestionBackgroundDecoration extends StatelessWidget {
  const _AyoQuestionBackgroundDecoration({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        // Content geometry to compute side gutters
        final maxContentWidth = isTablet ? 680.0 : 440.0;
        final sidePadding = isTablet ? 36.0 : 18.0;
        final contentWidth = math.min(w - (sidePadding * 2), maxContentWidth);
        final gutter = math.max(0.0, (w - contentWidth) / 2.0);

        // Responsive scaling for different screen sizes (mobile vs tablet)
        final scale = isTablet ? 1.25 : (w < 370 ? 0.85 : 1.0);
        final grass1Width = 34.0 * scale;
        final grass2Width = 36.0 * scale;
        final smallGrass1Width = 26.0 * scale;
        final smallGrass2Width = 28.0 * scale;

        // On tablet: place comfortably inside the side gutters.
        // On mobile: position along the edges to frame content with breathing room.
        final leftEdgeX = isTablet ? math.max(12.0, (gutter - grass1Width) / 2) : 4.0;
        final rightEdgeX = isTablet ? math.max(12.0, (gutter - grass1Width) / 2) : 4.0;

        return IgnorePointer(
          child: Stack(
            children: [
              // 1. Left Mid Cluster: flanking the middle background / cartoon section
              Positioned(
                left: leftEdgeX,
                top: h * 0.31,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _GrassDecorationItem(
                      assetPath: 'assets/images/grass1.png',
                      width: grass1Width,
                      opacity: 0.50,
                    ),
                    Transform.translate(
                      offset: const Offset(-8.0, 3.0),
                      child: _GrassDecorationItem(
                        assetPath: 'assets/images/grass2.png',
                        width: smallGrass2Width,
                        opacity: 0.45,
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Right Mid Cluster: flanking the question card, flipped horizontally
              Positioned(
                right: rightEdgeX,
                top: h * 0.34,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _GrassDecorationItem(
                      assetPath: 'assets/images/grass2.png',
                      width: smallGrass2Width,
                      isFlipped: true,
                      opacity: 0.45,
                    ),
                    Transform.translate(
                      offset: const Offset(-6.0, 0.0),
                      child: _GrassDecorationItem(
                        assetPath: 'assets/images/grass1.png',
                        width: smallGrass1Width,
                        isFlipped: true,
                        opacity: 0.48,
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Lower-Left Cluster: around the answer section / check button
              Positioned(
                left: leftEdgeX + (isTablet ? 6.0 : 2.0),
                top: h * 0.64,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _GrassDecorationItem(
                      assetPath: 'assets/images/grass2.png',
                      width: grass2Width,
                      opacity: 0.52,
                    ),
                    Transform.translate(
                      offset: const Offset(-10.0, -5.0),
                      child: _GrassDecorationItem(
                        assetPath: 'assets/images/grass1.png',
                        width: smallGrass1Width,
                        opacity: 0.46,
                      ),
                    ),
                  ],
                ),
              ),

              // 4. Lower-Right Cluster: around the answer section / check button
              Positioned(
                right: rightEdgeX + (isTablet ? 6.0 : 2.0),
                top: h * 0.67,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _GrassDecorationItem(
                      assetPath: 'assets/images/grass1.png',
                      width: grass1Width,
                      isFlipped: true,
                      opacity: 0.50,
                    ),
                    Transform.translate(
                      offset: const Offset(-8.0, 4.0),
                      child: _GrassDecorationItem(
                        assetPath: 'assets/images/grass2.png',
                        width: smallGrass2Width,
                        isFlipped: true,
                        opacity: 0.45,
                      ),
                    ),
                  ],
                ),
              ),

              // 5. Subtle Middle/Lower Background Elements: filling empty space above nav
              Positioned(
                left: leftEdgeX + (isTablet ? 14.0 : 8.0),
                top: h * 0.82,
                child: _GrassDecorationItem(
                  assetPath: 'assets/images/grass2.png',
                  width: smallGrass2Width * 0.9,
                  opacity: 0.42,
                ),
              ),
              Positioned(
                right: rightEdgeX + (isTablet ? 14.0 : 8.0),
                top: h * 0.84,
                child: _GrassDecorationItem(
                  assetPath: 'assets/images/grass1.png',
                  width: smallGrass1Width * 0.88,
                  isFlipped: true,
                  opacity: 0.42,
                ),
              ),

              // 6. Tablet side gutter accents: filling wide margins cleanly
              if (isTablet) ...[
                Positioned(
                  left: leftEdgeX + 8.0,
                  top: h * 0.16,
                  child: _GrassDecorationItem(
                    assetPath: 'assets/images/grass2.png',
                    width: smallGrass2Width,
                    opacity: 0.40,
                  ),
                ),
                Positioned(
                  right: rightEdgeX + 8.0,
                  top: h * 0.18,
                  child: _GrassDecorationItem(
                    assetPath: 'assets/images/grass1.png',
                    width: smallGrass1Width,
                    isFlipped: true,
                    opacity: 0.40,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
