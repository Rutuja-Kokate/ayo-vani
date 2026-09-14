import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/mundari_audio_text.dart';

/// Data model representing an Activity Picture Question in Phase 2.
class Phase2QuestionData {
  const Phase2QuestionData({
    required this.questionNumber,
    required this.totalQuestions,
    required this.progressValue,
    required this.progressPercentText,
    required this.imageAsset,
    required this.instruction,
    required this.englishHelperText,
    required this.options,
    required this.correctAnswer,
    required this.feedbackExplanation,
    this.chapterLabel = 'First • Ch 1',
    this.levelLabel = 'Level 1',
  });

  final int questionNumber;
  final int totalQuestions;
  final double progressValue;
  final String progressPercentText;
  final String imageAsset;
  final String instruction;
  final String englishHelperText;
  final List<String> options;
  final String correctAnswer;
  final String feedbackExplanation;
  final String chapterLabel;
  final String levelLabel;
}

/// Level 1 → Phase 2 Question Flow Screen for AYOVAANI.
///
/// Activity-picture based question runner:
/// - Question 1: play.png  → "एक लड़की खेल रही है।"
/// - Question 2: wakeup.png → "लड़का नींद से उठ रहा है।"
/// - Question 3: brush.png  → "लड़का अपने दाँत साफ कर रहा है।"
/// - Question 4: study.png  → "लड़की पढ़ रही है।"
/// - Question 5: eat.png    → "लड़की खाना खा रही है।"
///
/// Follows the canonical AyoVaani design system with warm parchment vignette,
/// Mundari audio speaker buttons, randomized visual options, and responsive layout.
class Phase2QuestionScreen extends StatefulWidget {
  const Phase2QuestionScreen({
    super.key,
    this.initialQuestionIndex = 0,
    this.questions = defaultQuestions,
    this.onBack,
    this.onNavigateTab,
    this.onNextQuestion,
    this.onCompletePhase,
    this.onPlayMundariAudio,
    this.randomSeed,
  });

  final int initialQuestionIndex;
  final List<Phase2QuestionData> questions;
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;
  final VoidCallback? onNextQuestion;
  final VoidCallback? onCompletePhase;
  final ValueChanged<String>? onPlayMundariAudio;
  final int? randomSeed;

  /// Canonical Phase 2 Question dataset (Questions 1 to 5)
  static const List<Phase2QuestionData> defaultQuestions = [
    // Question 1
    Phase2QuestionData(
      questionNumber: 1,
      totalQuestions: 5,
      progressValue: 0.20,
      progressPercentText: '20%',
      imageAsset: 'assets/images/play.png',
      instruction: 'ओमाकन गतिविधि मेनते सही वाक्य सलाएमे',
      englishHelperText: '(choose the correct sentence for given activity)',
      options: [
        'एक लड़की खेल रही है।',
        'एक लड़की खाना खा रही है।',
        'एक लड़की सो रही है।',
      ],
      correctAnswer: 'एक लड़की खेल रही है।',
      feedbackExplanation: 'शानदार! चित्र में एक लड़की खेल रही है।',
    ),

    // Question 2
    Phase2QuestionData(
      questionNumber: 2,
      totalQuestions: 5,
      progressValue: 0.40,
      progressPercentText: '40%',
      imageAsset: 'assets/images/wakeup.png',
      instruction: 'ओमाकन गतिविधि मेनते सही वाक्य सलाएमे',
      englishHelperText: '(choose the correct sentence for given activity)',
      options: [
        'लड़का अपने दाँत साफ कर रहा है।',
        'लड़का नींद से उठ रहा है।',
        'लड़का खाना खा रहा है।',
      ],
      correctAnswer: 'लड़का नींद से उठ रहा है।',
      feedbackExplanation: 'शानदार! चित्र में लड़का नींद से उठ रहा है।',
    ),

    // Question 3
    Phase2QuestionData(
      questionNumber: 3,
      totalQuestions: 5,
      progressValue: 0.60,
      progressPercentText: '60%',
      imageAsset: 'assets/images/brush.png',
      instruction: 'ओमाकन गतिविधि मेनते सही वाक्य सलाएमे',
      englishHelperText: '(choose the correct sentence for given activity)',
      options: [
        'लड़का खेल रहा है।',
        'लड़का पढ़ रहा है।',
        'लड़का अपने दाँत साफ कर रहा है।',
      ],
      correctAnswer: 'लड़का अपने दाँत साफ कर रहा है।',
      feedbackExplanation: 'शानदार! चित्र में लड़का अपने दाँत साफ कर रहा है।',
    ),

    // Question 4
    Phase2QuestionData(
      questionNumber: 4,
      totalQuestions: 5,
      progressValue: 0.80,
      progressPercentText: '80%',
      imageAsset: 'assets/images/study.png',
      instruction: 'ओमाकन गतिविधि मेनते सही वाक्य सलाएमे',
      englishHelperText: '(choose the correct sentence for given activity)',
      options: [
        'लड़की पढ़ रही है।',
        'लड़की खेल रही है।',
        'लड़की सो रही है।',
      ],
      correctAnswer: 'लड़की पढ़ रही है।',
      feedbackExplanation: 'शानदार! चित्र में लड़की पढ़ रही है।',
    ),

    // Question 5
    Phase2QuestionData(
      questionNumber: 5,
      totalQuestions: 5,
      progressValue: 1.0,
      progressPercentText: '100%',
      imageAsset: 'assets/images/eat.png',
      instruction: 'ओमाकन गतिविधि मेनते सही वाक्य सलाएमे',
      englishHelperText: '(choose the correct sentence for given activity)',
      options: [
        'लड़की पानी पी रही है।',
        'लड़की खाना खा रही है।',
        'लड़की पढ़ रही है।',
      ],
      correctAnswer: 'लड़की खाना खा रही है।',
      feedbackExplanation: 'शानदार! चित्र में लड़की खाना खा रही है।',
    ),
  ];

  @override
  State<Phase2QuestionScreen> createState() => _Phase2QuestionScreenState();
}

class _Phase2QuestionScreenState extends State<Phase2QuestionScreen> {
  int _navIndex = 1; // "Learn" tab active
  late int _currentQuestionIndex;
  late math.Random _random;

  // Question state
  late List<String> _shuffledOptions;
  int? _selectedOptionIndex;
  bool _isChecked = false;
  bool _isCorrect = false;

  Phase2QuestionData get _currentQuestion => widget.questions[_currentQuestionIndex];

  @override
  void initState() {
    super.initState();
    _random = widget.randomSeed != null ? math.Random(widget.randomSeed) : math.Random();
    _currentQuestionIndex = widget.initialQuestionIndex.clamp(
      0,
      widget.questions.isNotEmpty ? widget.questions.length - 1 : 0,
    );
    _setupQuestion();
  }

  void _setupQuestion() {
    _selectedOptionIndex = null;
    _isChecked = false;
    _isCorrect = false;
    final opts = List<String>.from(_currentQuestion.options);
    opts.shuffle(_random);
    _shuffledOptions = opts;
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

  void _playMundariAudio(String text) {
    if (widget.onPlayMundariAudio != null) {
      widget.onPlayMundariAudio!(text);
    } else {
      debugPrint('[AyoVani Audio] Play Mundari pronunciation for: "$text"');
    }
  }

  void _selectOption(int index) {
    if (_isChecked && _isCorrect) return;

    setState(() {
      _selectedOptionIndex = index;
      _isChecked = false;
    });
  }

  void _handleCheckOrContinue() {
    if (_isChecked && _isCorrect) {
      _advanceToNextQuestion();
      return;
    }

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

    final selectedText = _shuffledOptions[_selectedOptionIndex!] ;
    final isAnswerCorrect = (selectedText == _currentQuestion.correctAnswer);

    setState(() {
      _isChecked = true;
      _isCorrect = isAnswerCorrect;
    });
  }

  void _advanceToNextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _setupQuestion();
      });
    } else {
      if (widget.onCompletePhase != null) {
        widget.onCompletePhase!();
      } else if (widget.onNextQuestion != null) {
        widget.onNextQuestion!();
      } else {
        _showPhaseCompletionDialog();
      }
    }
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
                'Phase 2 Completed!',
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
          'शानदार! आपने Phase 2 के सभी 5 गतिविधि प्रश्नों को सफलतापूर्वक पूरा कर लिया है!\n(Congratulations! You have completed all 5 activity questions of Phase 2.)',
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
              // 1. Top-Left Warli/Indian Corner Ornament
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

              // 2. Top-Right Warli/Indian Corner Ornament (Flipped)
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

              // 3. Subtle Natural Grass Background Foliage Decoration
              Positioned.fill(
                child: _Phase2BackgroundDecoration(isTablet: isTablet),
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
                        const SizedBox(height: 14.0),

                        // Instruction Section with Speaker Button & English Helper
                        _buildInstructionSection(isTablet),
                        const SizedBox(height: 14.0),

                        // Activity Image Section (Prominently displayed, preserves aspect ratio)
                        _buildActivityImageSection(isTablet),
                        const SizedBox(height: 16.0),

                        // Randomized Answer Options (Questions 1 to 5)
                        _buildAnswerOptions(isTablet),
                        const SizedBox(height: 14.0),

                        // Feedback Message Banner (Shown on check)
                        if (_isChecked) ...[
                          _buildFeedbackBanner(isTablet),
                          const SizedBox(height: 14.0),
                        ],

                        // Burgundy "CHECK" / "CONTINUE" Action Button
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
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
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
  // Instruction Section with Speaker Icon
  // ---------------------------------------------------------------------------
  Widget _buildInstructionSection(bool isTablet) {
    final currentQ = _currentQuestion;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 18.0 : 14.0,
        vertical: isTablet ? 14.0 : 10.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF6),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFE8DECF),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF251E11).withValues(alpha: 0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: MundariAudioText(
              text: currentQ.instruction,
              onAudioTap: () => _playMundariAudio(currentQ.instruction),
              iconSize: isTablet ? 24.0 : 20.0,
              iconColor: const Color(0xFF671D21),
              spacing: isTablet ? 8.0 : 6.0,
              style: TextStyle(
                fontFamilyFallback: const [
                  'Noto Sans Devanagari',
                  'Mangal',
                  'Nirmala UI',
                  'sans-serif',
                ],
                fontSize: isTablet ? 18.5 : 15.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF671D21),
                letterSpacing: -0.2,
              ),
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
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Activity Image Section (Prominently displayed, authentic aspect ratio)
  // ---------------------------------------------------------------------------
  Widget _buildActivityImageSection(bool isTablet) {
    final currentQ = _currentQuestion;
    final imageHeight = isTablet ? 220.0 : 160.0;

    return Container(
      height: imageHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF6),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFF4C6647), // Dark olive green frame
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF251E11).withValues(alpha: 0.08),
            blurRadius: 12.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          currentQ.imageAsset,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Answer Options List
  // ---------------------------------------------------------------------------
  Widget _buildAnswerOptions(bool isTablet) {
    return Column(
      children: [
        for (int i = 0; i < _shuffledOptions.length; i++) ...[
          _buildOptionCard(
            index: i,
            text: _shuffledOptions[i],
            isTablet: isTablet,
          ),
          if (i < _shuffledOptions.length - 1) const SizedBox(height: 10.0),
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

    final verticalPad = isTablet ? 16.0 : 13.0;

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
                indicatorWidget,
                const SizedBox(width: 14.0),
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
                      fontSize: isTablet ? 19.0 : 16.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected && !_isChecked
                          ? const Color(0xFF4C6647)
                          : const Color(0xFF251E11),
                      height: 1.25,
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
  // Visual Feedback Banner
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
                      : 'कृपया पुनः प्रयास करें। कोई दूसरा विकल्प चुनें।',
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
  // Check / Continue Button
  // ---------------------------------------------------------------------------
  Widget _buildCheckButton(bool isTablet) {
    final isCompleted = _isChecked && _isCorrect;

    return Container(
      height: isTablet ? 56.0 : 52.0,
      decoration: BoxDecoration(
        color: const Color(0xFF5E171B), // Deep burgundy
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
              isCompleted ? 'CONTINUE' : 'CHECK',
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
// Subtle Natural Grass Background Foliage for Phase 2
// ---------------------------------------------------------------------------
class _Phase2BackgroundDecoration extends StatelessWidget {
  const _Phase2BackgroundDecoration({required this.isTablet});

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
              // Mid-Left Cluster
              Positioned(
                left: leftEdgeX,
                top: h * 0.32,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _GrassDecoItem(
                      assetPath: 'assets/images/grass1.png',
                      width: grass1Width,
                      opacity: 0.50,
                    ),
                    Transform.translate(
                      offset: const Offset(-8.0, 3.0),
                      child: _GrassDecoItem(
                        assetPath: 'assets/images/grass2.png',
                        width: smallGrass2Width,
                        opacity: 0.45,
                      ),
                    ),
                  ],
                ),
              ),

              // Mid-Right Cluster (flipped)
              Positioned(
                right: rightEdgeX,
                top: h * 0.34,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _GrassDecoItem(
                      assetPath: 'assets/images/grass2.png',
                      width: smallGrass2Width,
                      isFlipped: true,
                      opacity: 0.45,
                    ),
                    Transform.translate(
                      offset: const Offset(-6.0, 0.0),
                      child: _GrassDecoItem(
                        assetPath: 'assets/images/grass1.png',
                        width: smallGrass1Width,
                        isFlipped: true,
                        opacity: 0.48,
                      ),
                    ),
                  ],
                ),
              ),

              // Lower-Left Cluster
              Positioned(
                left: leftEdgeX + (isTablet ? 6.0 : 2.0),
                top: h * 0.64,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _GrassDecoItem(
                      assetPath: 'assets/images/grass2.png',
                      width: grass2Width,
                      opacity: 0.52,
                    ),
                    Transform.translate(
                      offset: const Offset(-10.0, -5.0),
                      child: _GrassDecoItem(
                        assetPath: 'assets/images/grass1.png',
                        width: smallGrass1Width,
                        opacity: 0.46,
                      ),
                    ),
                  ],
                ),
              ),

              // Lower-Right Cluster
              Positioned(
                right: rightEdgeX + (isTablet ? 6.0 : 2.0),
                top: h * 0.67,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _GrassDecoItem(
                      assetPath: 'assets/images/grass1.png',
                      width: grass1Width,
                      isFlipped: true,
                      opacity: 0.50,
                    ),
                    Transform.translate(
                      offset: const Offset(-8.0, 4.0),
                      child: _GrassDecoItem(
                        assetPath: 'assets/images/grass2.png',
                        width: smallGrass2Width,
                        isFlipped: true,
                        opacity: 0.45,
                      ),
                    ),
                  ],
                ),
              ),

              // Tablet gutter elements
              if (isTablet) ...[
                Positioned(
                  left: leftEdgeX + 8.0,
                  top: h * 0.16,
                  child: _GrassDecoItem(
                    assetPath: 'assets/images/grass2.png',
                    width: smallGrass2Width,
                    opacity: 0.40,
                  ),
                ),
                Positioned(
                  right: rightEdgeX + 8.0,
                  top: h * 0.18,
                  child: _GrassDecoItem(
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

class _GrassDecoItem extends StatelessWidget {
  const _GrassDecoItem({
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
