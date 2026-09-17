import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/mundari_audio_text.dart';
import '../../services/tts_service.dart';

/// Supported Question Types in the Teacher Practice Phase.
enum TeacherPracticeQuestionType {
  /// Match the correct meanings question (Question 1)
  matching,

  /// Single-choice multiple choice question (Questions 2 to 5)
  mcq,
}

/// Data model representing a Practice Question in the Teacher Practice Flow.
class TeacherPracticeQuestionData {
  const TeacherPracticeQuestionData({
    required this.questionNumber,
    required this.totalQuestions,
    required this.progressValue,
    required this.progressPercentText,
    required this.instruction,
    required this.englishHelperText,
    this.type = TeacherPracticeQuestionType.mcq,
    // For MCQ
    this.question = '',
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
  final TeacherPracticeQuestionType type;

  // MCQ fields
  final String question;
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
}

/// Interactive Teacher Practice Phase Screen for AyoVani Level 1.
///
/// Features:
/// - Question 1: "Match the Words" (5 pairs: होन→बच्चा, दअः→पानी, जोम-नू→खाना, ओड़अः→घर, दुब→बैठना)
///   with shuffled right-hand Hindi column and clickable maroon MundariAudioButtons.
/// - Questions 2–5: "Choose the Correct Mundari Sentence" (बैठो।, किताब खोलो।, आपका नाम क्या है?, पानी चाहिए?)
///   with randomized options and clickable maroon MundariAudioButtons before each Mundari sentence.
/// - Dynamic progress header (Q 1/5 .. Q 5/5, progress bar & percentage).
/// - "CHECK" button for validation; "CONTINUE" for Q1–Q4; "FINISH" on Q5 to return to Phase Popup.
/// - Responsive on mobile and tablet without overflow.
class TeacherPracticeScreen extends StatefulWidget {
  const TeacherPracticeScreen({
    super.key,
    this.levelNumber = 1,
    this.initialQuestionIndex = 0,
    this.onBack,
    this.onFinish,
    this.onNavigateTab,
    this.onPlayAudio,
  });

  final int levelNumber;
  final int initialQuestionIndex;
  final VoidCallback? onBack;
  final VoidCallback? onFinish;
  final ValueChanged<int>? onNavigateTab;
  final ValueChanged<String>? onPlayAudio;

  @override
  State<TeacherPracticeScreen> createState() => _TeacherPracticeScreenState();
}

class _TeacherPracticeScreenState extends State<TeacherPracticeScreen> {
  int _navIndex = 1; // "Learn" tab active
  late int _currentQuestionIndex;

  // Randomized question dataset created in initState
  late List<TeacherPracticeQuestionData> _questions;

  // MCQ state
  int? _selectedOptionIndex;

  // Matching state (Question 1)
  int? _selectedLeftIndex;
  int? _selectedRightIndex;
  final Map<int, int> _matches = {}; // leftIndex -> rightIndex

  bool _isChecked = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _currentQuestionIndex = widget.initialQuestionIndex.clamp(0, 4);
    _initializeQuestions();
  }

  void _initializeQuestions() {
    // -------------------------------------------------------------------------
    // Question 1: Matching
    // Left: होन, दअः, जोम-नू, ओड़अः, दुब
    // Right: बच्चा, पानी, खाना, घर, बैठना (shuffled)
    // -------------------------------------------------------------------------
    const leftWords = ['होन', 'दअः', 'जोम-नू', 'ओड़अः', 'दुब'];
    const originalPairs = {
      'होन': 'बच्चा',
      'दअः': 'पानी',
      'जोम-नू': 'खाना',
      'ओड़अः': 'घर',
      'दुब': 'बैठना',
    };

    // Shuffled right items (deterministic non-trivial order with seed for reproducibility, or random)
    final rightMeanings = ['पानी', 'बैठना', 'बच्चा', 'घर', 'खाना'];
    final Map<int, int> q1CorrectPairs = {};
    for (int l = 0; l < leftWords.length; l++) {
      final targetMeaning = originalPairs[leftWords[l]]!;
      final rIndex = rightMeanings.indexOf(targetMeaning);
      q1CorrectPairs[l] = rIndex;
    }

    // -------------------------------------------------------------------------
    // Questions 2 to 5: MCQs with randomized option positions
    // -------------------------------------------------------------------------
    final q2Options = ['हिजुःमे।', 'दुब मे।', 'लेलेमे', 'कजिलेम']..shuffle(math.Random());
    final q3Options = ['नेरे ओलेमे।', 'किताब निइपे', 'तिंगु कोःमे', 'धेआन ते अयुमेपे।']..shuffle(math.Random());
    final q4Options = ['अम चिलका मेनाःमा?', 'नेअ चेकनअः?', 'अमगअ लुतुम चेकनअः?', 'कोतेमतना?']..shuffle(math.Random());
    final q5Options = ['मंडी जोम केदा?', 'दअः लगतिङअ?', 'चेनअःम चेकातना?', 'हे/का।']..shuffle(math.Random());

    _questions = [
      // Q1: Matching
      TeacherPracticeQuestionData(
        questionNumber: 1,
        totalQuestions: 5,
        progressValue: 0.20,
        progressPercentText: '20%',
        type: TeacherPracticeQuestionType.matching,
        instruction: 'सही अर्थ से मिलाएँ',
        englishHelperText: '(Match the correct meanings)',
        leftColumnHeading: 'मुंडारी शब्द',
        rightColumnHeading: 'हिंदी अर्थ',
        leftItems: leftWords,
        rightItems: rightMeanings,
        correctPairs: q1CorrectPairs,
        feedbackExplanation:
            '"होन" → "बच्चा" • "दअः" → "पानी" • "जोम-नू" → "खाना" • "ओड़अः" → "घर" • "दुब" → "बैठना"',
        levelLabel: 'Level ${widget.levelNumber}',
      ),

      // Q2: MCQ - बैठो। -> दुब मे।
      TeacherPracticeQuestionData(
        questionNumber: 2,
        totalQuestions: 5,
        progressValue: 0.40,
        progressPercentText: '40%',
        type: TeacherPracticeQuestionType.mcq,
        instruction: 'सही मुंडारी वाक्य चुनें',
        englishHelperText: '(Choose the correct Mundari sentence)',
        question: 'बैठो।',
        options: q2Options,
        correctAnswer: 'दुब मे।',
        feedbackExplanation: '"बैठो।" का सही मुंडारी वाक्य "दुब मे।" है।',
        levelLabel: 'Level ${widget.levelNumber}',
      ),

      // Q3: MCQ - किताब खोलो। -> किताब निइपे
      TeacherPracticeQuestionData(
        questionNumber: 3,
        totalQuestions: 5,
        progressValue: 0.60,
        progressPercentText: '60%',
        type: TeacherPracticeQuestionType.mcq,
        instruction: 'सही मुंडारी वाक्य चुनें',
        englishHelperText: '(Choose the correct Mundari sentence)',
        question: 'किताब खोलो।',
        options: q3Options,
        correctAnswer: 'किताब निइपे',
        feedbackExplanation: '"किताब खोलो।" का सही मुंडारी वाक्य "किताब निइपे" है।',
        levelLabel: 'Level ${widget.levelNumber}',
      ),

      // Q4: MCQ - आपका नाम क्या है? -> अमगअ लुतुम चेकनअः?
      TeacherPracticeQuestionData(
        questionNumber: 4,
        totalQuestions: 5,
        progressValue: 0.80,
        progressPercentText: '80%',
        type: TeacherPracticeQuestionType.mcq,
        instruction: 'सही मुंडारी वाक्य चुनें',
        englishHelperText: '(Choose the correct Mundari sentence)',
        question: 'आपका नाम क्या है?',
        options: q4Options,
        correctAnswer: 'अमगअ लुतुम चेकनअः?',
        feedbackExplanation: '"आपका नाम क्या है?" का सही मुंडारी वाक्य "अमगअ लुतुम चेकनअः?" है।',
        levelLabel: 'Level ${widget.levelNumber}',
      ),

      // Q5: MCQ - पानी चाहिए? -> दअः लगतिङअ?
      TeacherPracticeQuestionData(
        questionNumber: 5,
        totalQuestions: 5,
        progressValue: 1.0,
        progressPercentText: '100%',
        type: TeacherPracticeQuestionType.mcq,
        instruction: 'सही मुंडारी वाक्य चुनें',
        englishHelperText: '(Choose the correct Mundari sentence)',
        question: 'पानी चाहिए?',
        options: q5Options,
        correctAnswer: 'दअः लगतिङअ?',
        feedbackExplanation: '"पानी चाहिए?" का सही मुंडारी वाक्य "दअः लगतिङअ?" है।',
        levelLabel: 'Level ${widget.levelNumber}',
      ),
    ];
  }

  TeacherPracticeQuestionData get _currentQuestion => _questions[_currentQuestionIndex];
  bool get _isMatching => _currentQuestion.type == TeacherPracticeQuestionType.matching;

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop(false);
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

  void _playMundariAudio(String text) {
    if (widget.onPlayAudio != null) {
      widget.onPlayAudio!(text);
    } else {
      TtsService().speakCodeMixedClassroomScript(text);
    }
  }

  // ---------------------------------------------------------------------------
  // MCQ Option Selection
  // ---------------------------------------------------------------------------
  void _selectOption(int index) {
    if (_isChecked && _isCorrect) return;

    setState(() {
      _selectedOptionIndex = index;
      _isChecked = false;
    });
  }

  // ---------------------------------------------------------------------------
  // Matching Selection Logic
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
        if (_matches.containsKey(leftIndex)) {
          _matches.remove(leftIndex);
          _selectedLeftIndex = leftIndex;
        } else if (_selectedLeftIndex == leftIndex) {
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
        if (_matches.containsValue(rightIndex)) {
          _matches.removeWhere((k, v) => v == rightIndex);
          _selectedRightIndex = rightIndex;
        } else if (_selectedRightIndex == rightIndex) {
          _selectedRightIndex = null;
        } else {
          _selectedRightIndex = rightIndex;
        }
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Check & Continue / Finish Logic
  // ---------------------------------------------------------------------------
  void _handleCheckOrContinue() {
    if (_isChecked && _isCorrect) {
      final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
      if (isLastQuestion) {
        _finishPhase();
      } else {
        _advanceToNextQuestion();
      }
      return;
    }

    if (_isMatching) {
      // Validate that all 5 pairs are matched
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

      // Check all matches
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
    }
  }

  void _advanceToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
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
    widget.onFinish?.call();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = Responsive.isTabletOrLarger(context) || screenWidth >= 600;

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // 1. Top-Left Traditional Warli Corner Ornament
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

              // 2. Top-Right Traditional Warli Corner Ornament (Flipped)
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

              // 3. Natural Grass Background Decoration
              Positioned.fill(
                child: _AyoQuestionBackgroundDecoration(isTablet: isTablet),
              ),

              // 4. Scrollable Question Content
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
                        // Header: Circular Back Button & AyoVaani Logo
                        _buildHeader(isTablet),
                        const SizedBox(height: 12.0),

                        // Progress Header Card: "First • Ch 1" | "Level 1" | "Q X/5" | Progress%
                        _buildProgressCard(isTablet),
                        const SizedBox(height: 16.0),

                        // Character + Question Card
                        _buildCartoonAndQuestionSection(isTablet),
                        const SizedBox(height: 18.0),

                        // Content: Either Matching Columns (Q1) OR MCQ Options (Q2-Q5)
                        if (_isMatching)
                          _buildMatchingSection(isTablet)
                        else
                          _buildAnswerOptions(isTablet),
                        const SizedBox(height: 16.0),

                        // Optional Feedback Message Banner
                        if (_isChecked) ...[
                          _buildFeedbackBanner(isTablet),
                          const SizedBox(height: 14.0),
                        ],

                        // Action Button: "CHECK" / "CONTINUE" / "FINISH"
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
  // Top Header (Back Button & Centered Logo)
  // ---------------------------------------------------------------------------
  Widget _buildHeader(bool isTablet) {
    return SizedBox(
      height: isTablet ? 82.0 : 70.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
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
          Center(
            child: AyoLogo(
              height: isTablet ? 80.0 : 66.0,
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
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Green Pill: "First • Ch 1"
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C6647),
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

              // "Q X/5"
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

          // Progress Bar + Percentage
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
                      Color(0xFF671D21),
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
  // Cartoon + Question Area
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
            // Speech Bubble + Squirrel Cartoon
            SizedBox(
              width: cartoonWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSpeechBubble(isTablet),
                  const SizedBox(height: 4.0),
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

            // Decorative Question Card
            Expanded(
              child: _buildQuestionCard(isTablet),
            ),
          ],
        );
      },
    );
  }

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

  Widget _buildQuestionCard(bool isTablet) {
    final currentQ = _currentQuestion;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF6),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFF4C6647),
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
            // Mandala Corners
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

            // Question Text
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 18.0 : 10.0,
                vertical: isTablet ? 22.0 : (_isMatching ? 18.0 : 14.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    currentQ.instruction,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamilyFallback: const [
                        'Noto Sans Devanagari',
                        'Mangal',
                        'Nirmala UI',
                        'sans-serif',
                      ],
                      fontSize: isTablet ? 19.0 : 16.0,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF671D21),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3.0),
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
                  if (!_isMatching && currentQ.question.isNotEmpty) ...[
                    const SizedBox(height: 10.0),
                    Center(
                      child: Text(
                        currentQ.question,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamilyFallback: const [
                            'Noto Sans Devanagari',
                            'Mangal',
                            'Nirmala UI',
                            'sans-serif',
                          ],
                          fontSize: isTablet ? 32.0 : 26.0,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E170E),
                          letterSpacing: 0.3,
                          height: 1.2,
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
  // Matching Section (Question 1)
  // ---------------------------------------------------------------------------
  Widget _buildMatchingSection(bool isTablet) {
    final currentQ = _currentQuestion;

    return Column(
      children: [
        // Column Headings
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
            // Left Column (Mundari words with speaker buttons)
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

            // Right Column (Hindi meanings)
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
        color: const Color(0xFF4C6647),
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

    Color backgroundColor = const Color(0xFFFAF6F0);
    Color borderColor = const Color(0xFFB3A596);
    double borderWidth = 1.3;
    Widget indicatorWidget;

    if (_isChecked && isMatched) {
      if (isPairCorrect == true) {
        backgroundColor = const Color(0xFFF1F7EE);
        borderColor = const Color(0xFF386633);
        borderWidth = 2.0;
        indicatorWidget = _buildCircleIndicator(
          fillColor: const Color(0xFF386633),
          borderColor: const Color(0xFF386633),
          child: const Icon(Icons.check, color: Colors.white, size: 15.0),
        );
      } else {
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
      backgroundColor = const Color(0xFFF6FAF3);
      borderColor = const Color(0xFF4C6647);
      borderWidth = 1.8;
      indicatorWidget = _buildCircleIndicator(
        fillColor: const Color(0xFF4C6647),
        borderColor: const Color(0xFF4C6647),
        child: const Icon(Icons.check, color: Colors.white, size: 14.0),
      );
    } else {
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
                      fontSize: isTablet ? 18.0 : 15.0,
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
  // Answer Options List (MCQ: Questions 2 to 5)
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
    final isSelected = (_selectedOptionIndex == index);

    Color backgroundColor = const Color(0xFFFAF6F0);
    Color borderColor = const Color(0xFF4A3B32);
    double borderWidth = 1.3;
    Widget indicatorWidget;

    if (isSelected) {
      if (_isChecked) {
        if (_isCorrect) {
          backgroundColor = const Color(0xFFF1F7EE);
          borderColor = const Color(0xFF386633);
          borderWidth = 2.0;
          indicatorWidget = _buildCircleIndicator(
            fillColor: const Color(0xFF386633),
            borderColor: const Color(0xFF386633),
            child: const Icon(Icons.check, color: Colors.white, size: 17.0),
          );
        } else {
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
      indicatorWidget = _buildCircleIndicator(
        fillColor: Colors.transparent,
        borderColor: const Color(0xFFB3A596),
        child: null,
      );
    }

    final verticalPad = isTablet ? 16.0 : 12.0;

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
              horizontal: 14.0,
              vertical: verticalPad,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Radio Button Indicator
                indicatorWidget,
                const SizedBox(width: 10.0),

                // Mundari Clickable Speaker Icon (Deep Maroon)
                MundariAudioButton(
                  text: text,
                  onTap: () => _playMundariAudio(text),
                  iconSize: isTablet ? 24.0 : 20.0,
                  color: const Color(0xFF671D21),
                ),
                const SizedBox(width: 10.0),

                // Mundari Option Sentence
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
                      fontSize: isTablet ? 21.0 : 18.0,
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
  // Feedback Banner
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
  // Check / Continue / Finish Action Button
  // ---------------------------------------------------------------------------
  Widget _buildCheckButton(bool isTablet) {
    final isCompleted = _isChecked && _isCorrect;
    final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
    final String buttonLabel;
    if (!isCompleted) {
      buttonLabel = 'CHECK';
    } else if (isLastQuestion) {
      buttonLabel = 'FINISH';
    } else {
      buttonLabel = 'CONTINUE';
    }

    return Container(
      height: isTablet ? 56.0 : 50.0,
      decoration: BoxDecoration(
        color: const Color(0xFF671D21), // AyoVaani Deep burgundy
        borderRadius: BorderRadius.circular(28.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF671D21).withValues(alpha: 0.32),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
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
// Speech Bubble Painter
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
// Green Corner Mandala Painter
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

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: w * 0.85),
      startAngle,
      math.pi * 0.5,
      false,
      linePaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: w * 0.58),
      startAngle,
      math.pi * 0.5,
      false,
      linePaint,
    );

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
// Subtle Natural Grass Decoration Items
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

class _AyoQuestionBackgroundDecoration extends StatelessWidget {
  const _AyoQuestionBackgroundDecoration({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final maxContentWidth = isTablet ? 680.0 : 440.0;
        final sidePadding = isTablet ? 36.0 : 18.0;
        final contentWidth = math.min(w - (sidePadding * 2), maxContentWidth);
        final gutter = math.max(0.0, (w - contentWidth) / 2.0);

        final scale = isTablet ? 1.25 : (w < 370 ? 0.85 : 1.0);
        final grass1Width = 34.0 * scale;
        final grass2Width = 36.0 * scale;
        final smallGrass1Width = 26.0 * scale;
        final smallGrass2Width = 28.0 * scale;

        final leftEdgeX = isTablet ? math.max(12.0, (gutter - grass1Width) / 2) : 4.0;
        final rightEdgeX = isTablet ? math.max(12.0, (gutter - grass1Width) / 2) : 4.0;

        return IgnorePointer(
          child: Stack(
            children: [
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
            ],
          ),
        );
      },
    );
  }
}
