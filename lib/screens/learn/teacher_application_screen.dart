import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/mundari_audio_text.dart';

/// Data model representing an Application Question in the Teacher Application Phase.
class TeacherApplicationQuestionData {
  const TeacherApplicationQuestionData({
    required this.questionNumber,
    required this.totalQuestions,
    required this.progressValue,
    required this.progressPercentText,
    required this.situation,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.correctMeaning,
    this.chapterLabel = 'First • Ch 1',
    this.levelLabel = 'Level 1',
  });

  final int questionNumber;
  final int totalQuestions;
  final double progressValue;
  final String progressPercentText;
  final String situation;
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String correctMeaning;
  final String chapterLabel;
  final String levelLabel;
}

/// Interactive Teacher Application Phase Screen for AyoVani Level 1.
///
/// Features:
/// - 5 Situational Classroom Communication Questions:
///   Q1: Attention in class ("आप पढ़ा रहे हैं...") -> "धेआन ते अयुमेपे।" (ध्यान से सुनो।)
///   Q2: Asking what student is doing ("आप देखते हैं...") -> "चेनअःम चेकातना?" (क्या कर रहे हो?)
///   Q3: Checking understanding ("आपने एक छात्र को समझाया...") -> "बुजव जनम?" (समझ आया?)
///   Q4: Opening books ("आप छात्रों को किताब खोलने...") -> "किताब निइपे।" (किताब खोलो।)
///   Q5: Repeating a sentence ("आपने एक वाक्य बोला है...") -> "दोहरवएपे।" (दोहराओ।)
/// - Pure Hindi "स्थिति" and "प्रश्न" inside the decorative question card (no English labels).
/// - Exactly 3 large selectable Mundari options with clickable deep maroon MundariAudioButtons.
/// - Dynamic progress header (Q 1/5 .. Q 5/5, progress bar & percentage).
/// - "CHECK" button for validation; "CONTINUE" for Q1–Q4; "FINISH" on Q5 to return to Phase Popup.
/// - Responsive on mobile and tablet without overflow.
class TeacherApplicationScreen extends StatefulWidget {
  const TeacherApplicationScreen({
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
  State<TeacherApplicationScreen> createState() => _TeacherApplicationScreenState();
}

class _TeacherApplicationScreenState extends State<TeacherApplicationScreen> {
  int _navIndex = 1; // "Learn" tab active
  late int _currentQuestionIndex;

  late List<TeacherApplicationQuestionData> _questions;
  int? _selectedOptionIndex;
  bool _isChecked = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _currentQuestionIndex = widget.initialQuestionIndex.clamp(0, 4);
    _initializeQuestions();
  }

  void _initializeQuestions() {
    _questions = [
      // -----------------------------------------------------------------------
      // Question 1
      // -----------------------------------------------------------------------
      TeacherApplicationQuestionData(
        questionNumber: 1,
        totalQuestions: 5,
        progressValue: 0.20,
        progressPercentText: '20%',
        situation: 'आप पढ़ा रहे हैं, लेकिन एक छात्र ध्यान नहीं दे रहा है।',
        question: 'आप छात्र से क्या कहेंगे?',
        options: const [
          'कजिलेम।',
          'धेआन ते अयुमेपे।',
          'लेलेमे।',
        ],
        correctAnswer: 'धेआन ते अयुमेपे।',
        correctMeaning: 'ध्यान से सुनो।',
        levelLabel: 'Level ${widget.levelNumber}',
      ),

      // -----------------------------------------------------------------------
      // Question 2
      // -----------------------------------------------------------------------
      TeacherApplicationQuestionData(
        questionNumber: 2,
        totalQuestions: 5,
        progressValue: 0.40,
        progressPercentText: '40%',
        situation: 'आप देखते हैं कि एक छात्र कोई काम कर रहा है।',
        question: 'आप उससे क्या पूछेंगे?',
        options: const [
          'चेनअःम चेकातना?',
          'अम चिलका मेनाःमा?',
          'नेअ चेकनअः?',
        ],
        correctAnswer: 'चेनअःम चेकातना?',
        correctMeaning: 'क्या कर रहे हो?',
        levelLabel: 'Level ${widget.levelNumber}',
      ),

      // -----------------------------------------------------------------------
      // Question 3
      // -----------------------------------------------------------------------
      TeacherApplicationQuestionData(
        questionNumber: 3,
        totalQuestions: 5,
        progressValue: 0.60,
        progressPercentText: '60%',
        situation: 'आपने एक छात्र को कुछ समझाया है और अब जानना चाहते हैं कि उसे समझ आया या नहीं।',
        question: 'आप छात्र से क्या पूछेंगे?',
        options: const [
          'बुजव जनम?',
          'दअः लगतिङअ?',
          'कोतेमतना?',
        ],
        correctAnswer: 'बुजव जनम?',
        correctMeaning: 'समझ आया?',
        levelLabel: 'Level ${widget.levelNumber}',
      ),

      // -----------------------------------------------------------------------
      // Question 4
      // -----------------------------------------------------------------------
      TeacherApplicationQuestionData(
        questionNumber: 4,
        totalQuestions: 5,
        progressValue: 0.80,
        progressPercentText: '80%',
        situation: 'आप छात्रों को अपनी किताब खोलने के लिए कहते हैं।',
        question: 'आप क्या कहेंगे?',
        options: const [
          'किताब निइपे।',
          'दुब मे।',
          'कजिलेम।',
        ],
        correctAnswer: 'किताब निइपे।',
        correctMeaning: 'किताब खोलो।',
        levelLabel: 'Level ${widget.levelNumber}',
      ),

      // -----------------------------------------------------------------------
      // Question 5
      // -----------------------------------------------------------------------
      TeacherApplicationQuestionData(
        questionNumber: 5,
        totalQuestions: 5,
        progressValue: 1.0,
        progressPercentText: '100%',
        situation: 'आपने एक वाक्य बोला है और चाहते हैं कि छात्र उसे फिर से बोलें।',
        question: 'आप छात्रों से क्या कहेंगे?',
        options: const [
          'दोहरवएपे।',
          'बुजव जनम?',
          'दअः लगतिङअ?',
        ],
        correctAnswer: 'दोहरवएपे।',
        correctMeaning: 'दोहराओ।',
        levelLabel: 'Level ${widget.levelNumber}',
      ),
    ];
  }

  TeacherApplicationQuestionData get _currentQuestion => _questions[_currentQuestionIndex];

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
      debugPrint('Playing Mundari pronunciation: $text');
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
      final isLastQuestion = _currentQuestionIndex == _questions.length - 1;
      if (isLastQuestion) {
        _finishPhase();
      } else {
        _advanceToNextQuestion();
      }
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

    final selectedText = _currentQuestion.options[_selectedOptionIndex!];
    final isAnswerCorrect = (selectedText == _currentQuestion.correctAnswer);

    setState(() {
      _isChecked = true;
      _isCorrect = isAnswerCorrect;
    });
  }

  void _advanceToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
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

                        // 3 Selectable Option Cards
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

            // Decorative Question Card (Pure Hindi "स्थिति" and "प्रश्न")
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

            // Question Card Content (स्थिति & प्रश्न in Hindi)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 18.0 : 10.0,
                vertical: isTablet ? 18.0 : 14.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Heading 1: स्थिति
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBECEB),
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: const Color(0xFFE8C7C9),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'स्थिति',
                          style: TextStyle(
                            fontFamilyFallback: const [
                              'Noto Sans Devanagari',
                              'Mangal',
                              'Nirmala UI',
                              'sans-serif',
                            ],
                            fontSize: isTablet ? 13.5 : 12.0,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF671D21),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),

                  // Situation Text
                  Text(
                    currentQ.situation,
                    style: TextStyle(
                      fontFamilyFallback: const [
                        'Noto Sans Devanagari',
                        'Mangal',
                        'Nirmala UI',
                        'sans-serif',
                      ],
                      fontSize: isTablet ? 14.5 : 13.0,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF251E11),
                      height: 1.3,
                    ),
                  ),

                  // Visual Divider between Situation and Question
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      height: 1.0,
                      color: const Color(0xFFEADBCE),
                    ),
                  ),

                  // Heading 2: प्रश्न
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF5E7),
                          borderRadius: BorderRadius.circular(6.0),
                          border: Border.all(
                            color: const Color(0xFFB5D4B0),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          'प्रश्न',
                          style: TextStyle(
                            fontFamilyFallback: const [
                              'Noto Sans Devanagari',
                              'Mangal',
                              'Nirmala UI',
                              'sans-serif',
                            ],
                            fontSize: isTablet ? 13.5 : 12.0,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2B5226),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),

                  // Question Text
                  Text(
                    currentQ.question,
                    style: TextStyle(
                      fontFamilyFallback: const [
                        'Noto Sans Devanagari',
                        'Mangal',
                        'Nirmala UI',
                        'sans-serif',
                      ],
                      fontSize: isTablet ? 17.5 : 15.0,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E170E),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3 Answer Options List (Mundari Options with Speaker Icons)
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
                      ? '"${currentQ.correctAnswer}" का सही अर्थ "${currentQ.correctMeaning}" है।'
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
        color: const Color(0xFF671D21),
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
