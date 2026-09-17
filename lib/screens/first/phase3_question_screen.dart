import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../../widgets/mundari_audio_text.dart';
import '../learn/widgets/phase_selection_dialog.dart';

/// Data model for a Sentence-Building Question in Phase 3.
class Phase3QuestionData {
  const Phase3QuestionData({
    required this.questionNumber,
    required this.totalQuestions,
    required this.progressValue,
    required this.progressPercentText,
    required this.mundariSentence,
    required this.wordTiles,
    required this.correctWordOrder,
    required this.feedbackExplanation,
    this.instruction = 'सही हिन्दी वाक्य सलाएमे',
    this.englishHelperText = '(Choose the correct sentence in hindi)',
    this.chapterLabel = 'First • Ch 1',
    this.levelLabel = 'Level 1',
  });

  final int questionNumber;
  final int totalQuestions;
  final double progressValue;
  final String progressPercentText;

  /// Mundari sentence displayed in the question card.
  final String mundariSentence;

  /// Common instruction for all Phase 3 questions.
  final String instruction;

  /// English subtitle for the instruction.
  final String englishHelperText;

  /// Hindi word tiles shown to the student (shuffled on load).
  final List<String> wordTiles;

  /// Correct word order for the Hindi translation.
  final List<String> correctWordOrder;

  /// Feedback text shown after a correct answer.
  final String feedbackExplanation;

  final String chapterLabel;
  final String levelLabel;
}

/// Level 1 -> Phase 3 Sentence-Building Question Screen for AYOVAANI.
///
/// Activity: Mundari sentence is displayed; student constructs the Hindi
/// meaning by tapping word tiles in the correct order.
///
/// Q1: अमअः नुतुम चेकनअः?               -> आपका नाम क्या है?
/// Q2: तिसिङ आम चिलका मेनाःमा?          -> आप आज कैसे हैं?
/// Q3: चेनअःम चेकातना?                   -> आप क्या कर रहे हैं?
/// Q4: अम कोतअः रेम तइन तना?            -> आप कहाँ रहते हैं?
/// Q5: अमअः सुकु सनङ जोमेअः चिनअः तना? -> आपका पसंदीदा खाना क्या है?
class Phase3QuestionScreen extends StatefulWidget {
  const Phase3QuestionScreen({
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
  final List<Phase3QuestionData> questions;
  final VoidCallback? onBack;
  final ValueChanged<int>? onNavigateTab;
  final VoidCallback? onNextQuestion;
  final VoidCallback? onCompletePhase;
  final ValueChanged<String>? onPlayMundariAudio;
  final int? randomSeed;

  static const List<Phase3QuestionData> defaultQuestions = [
    Phase3QuestionData(
      questionNumber: 1,
      totalQuestions: 5,
      progressValue: 0.20,
      progressPercentText: '20%',
      mundariSentence: 'अमअः नुतुम चेकनअः?',
      wordTiles: ['आपका', 'नाम', 'क्या', 'है'],
      correctWordOrder: ['आपका', 'नाम', 'क्या', 'है'],
      feedbackExplanation:
          'शानदार! "अमअः नुतुम चेकनअः?" का अर्थ है: "आपका नाम क्या है?"',
    ),
    Phase3QuestionData(
      questionNumber: 2,
      totalQuestions: 5,
      progressValue: 0.40,
      progressPercentText: '40%',
      mundariSentence: 'तिसिङ आम चिलका मेनाःमा?',
      wordTiles: ['आप', 'आज', 'कैसे', 'हैं'],
      correctWordOrder: ['आप', 'आज', 'कैसे', 'हैं'],
      feedbackExplanation:
          'शानदार! "तिसिङ आम चिलका मेनाःमा?" का अर्थ है: "आप आज कैसे हैं?"',
    ),
    Phase3QuestionData(
      questionNumber: 3,
      totalQuestions: 5,
      progressValue: 0.60,
      progressPercentText: '60%',
      mundariSentence: 'चेनअःम चेकातना?',
      wordTiles: ['आप', 'क्या', 'कर', 'रहे', 'हैं'],
      correctWordOrder: ['आप', 'क्या', 'कर', 'रहे', 'हैं'],
      feedbackExplanation:
          'शानदार! "चेनअःम चेकातना?" का अर्थ है: "आप क्या कर रहे हैं?"',
    ),
    Phase3QuestionData(
      questionNumber: 4,
      totalQuestions: 5,
      progressValue: 0.80,
      progressPercentText: '80%',
      mundariSentence: 'अम कोतअः रेम तइन तना?',
      wordTiles: ['आप', 'कहाँ', 'रहते', 'हैं'],
      correctWordOrder: ['आप', 'कहाँ', 'रहते', 'हैं'],
      feedbackExplanation:
          'शानदार! "अम कोतअः रेम तइन तना?" का अर्थ है: "आप कहाँ रहते हैं?"',
    ),
    Phase3QuestionData(
      questionNumber: 5,
      totalQuestions: 5,
      progressValue: 1.0,
      progressPercentText: '100%',
      mundariSentence: 'अमअः सुकु सनङ जोमेअः चिनअः तना?',
      wordTiles: ['आपका', 'पसंदीदा', 'खाना', 'क्या', 'है'],
      correctWordOrder: ['आपका', 'पसंदीदा', 'खाना', 'क्या', 'है'],
      feedbackExplanation:
          'शानदार! "अमअः सुकु सनङ जोमेअः चिनअः तना?" का अर्थ है: "आपका पसंदीदा खाना क्या है?"',
    ),
  ];

  @override
  State<Phase3QuestionScreen> createState() => _Phase3QuestionScreenState();
}

class _Phase3QuestionScreenState extends State<Phase3QuestionScreen> {
  int _navIndex = 1;
  late int _currentQuestionIndex;
  late math.Random _random;

  late List<String> _shuffledTiles;
  late List<bool> _tileUsed;
  late List<String> _selectedWords;

  bool _isChecked = false;
  bool _isCorrect = false;

  Phase3QuestionData get _currentQuestion =>
      widget.questions[_currentQuestionIndex];

  @override
  void initState() {
    super.initState();
    _random = widget.randomSeed != null
        ? math.Random(widget.randomSeed)
        : math.Random();
    _currentQuestionIndex = widget.initialQuestionIndex.clamp(
      0,
      widget.questions.isNotEmpty ? widget.questions.length - 1 : 0,
    );
    _setupQuestion();
  }

  void _setupQuestion() {
    _isChecked = false;
    _isCorrect = false;
    _selectedWords = [];
    final tiles = List<String>.from(_currentQuestion.wordTiles);
    tiles.shuffle(_random);
    _shuffledTiles = tiles;
    _tileUsed = List<bool>.filled(tiles.length, false);
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
      debugPrint('[AyoVani Audio] Play Mundari for: "$text"');
    }
  }

  void _onTileTap(int tileIndex) {
    if (_isChecked && _isCorrect) return;
    if (_tileUsed[tileIndex]) return;
    setState(() {
      _tileUsed[tileIndex] = true;
      _selectedWords.add(_shuffledTiles[tileIndex]);
      _isChecked = false;
    });
  }

  void _onAnswerWordTap(int answerIndex) {
    if (_isChecked && _isCorrect) return;
    final removedWord = _selectedWords[answerIndex];
    setState(() {
      _selectedWords.removeAt(answerIndex);
      for (int i = 0; i < _shuffledTiles.length; i++) {
        if (_shuffledTiles[i] == removedWord && _tileUsed[i]) {
          _tileUsed[i] = false;
          break;
        }
      }
      _isChecked = false;
    });
  }

  void _handleCheckOrContinue() {
    if (_isChecked && _isCorrect) {
      final isLastQuestion = _currentQuestionIndex == widget.questions.length - 1;
      if (isLastQuestion) {
        _finishPhase();
      } else {
        _advanceToNextQuestion();
      }
      return;
    }

    if (_selectedWords.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryBurgundy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: const Text(
            'कृपया शब्द चुनें! (Please select words first!)',
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

    final allTilesUsed = _tileUsed.every((used) => used);
    if (!allTilesUsed) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primaryBurgundy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          content: Text(
            'कृपया सभी ${_currentQuestion.wordTiles.length} शब्दों का उपयोग करें।',
            style: const TextStyle(
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

    final correct = _currentQuestion.correctWordOrder;
    final isAnswerCorrect = (_selectedWords.length == correct.length) &&
        List.generate(
            correct.length, (i) => _selectedWords[i] == correct[i]).every((m) => m);

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
            Icon(Icons.emoji_events_rounded,
                color: Color(0xFFC0882A), size: 28.0),
            SizedBox(width: 10.0),
            Flexible(
              child: Text(
                'Phase 3 Completed!',
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
          'शानदार! आपने Phase 3 के सभी 5 वाक्य-निर्माण प्रश्नों को सफलतापूर्वक पूरा कर लिया है!\n'
          '(Congratulations! You completed all 5 sentence-building questions of Phase 3.)',
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
                  color: Color(0xFF671D21)),
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
    final isTablet =
        Responsive.isTabletOrLarger(context) || screenWidth >= 600;

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
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
              Positioned.fill(
                child: _Phase3BackgroundDecoration(isTablet: isTablet),
              ),
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
                    constraints:
                        BoxConstraints(maxWidth: isTablet ? 680.0 : 440.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(isTablet),
                        const SizedBox(height: 12.0),
                        _buildProgressCard(isTablet),
                        const SizedBox(height: 16.0),
                        _buildCartoonAndQuestionSection(isTablet),
                        const SizedBox(height: 16.0),
                        _buildWordBuildingLabel(isTablet),
                        const SizedBox(height: 10.0),
                        _buildAnswerArea(isTablet),
                        const SizedBox(height: 10.0),
                        _buildWordTiles(isTablet),
                        const SizedBox(height: 14.0),
                        if (_isChecked) ...[
                          _buildFeedbackBanner(isTablet),
                          const SizedBox(height: 14.0),
                        ],
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
                        color: const Color(0xFFE8DECF), width: 1.0),
                  ),
                  child: const Center(
                    child: Icon(Icons.arrow_back_rounded,
                        color: Color(0xFF251E11), size: 22.0),
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

  Widget _buildProgressCard(bool isTablet) {
    final currentQ = _currentQuestion;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF7),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xFFEBE3D7), width: 1.2),
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
                          horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                          color: const Color(0xFF4C6647),
                          borderRadius: BorderRadius.circular(12.0)),
                      child: Text(
                        currentQ.chapterLabel,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2),
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
                            color: const Color(0xFF251E11)),
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
                    color: const Color(0xFF4A3B32)),
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
                        Color(0xFF671D21)),
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
                    color: Color(0xFF4A3B32)),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
            Expanded(child: _buildQuestionCard(isTablet)),
          ],
        );
      },
    );
  }

  Widget _buildSpeechBubble(bool isTablet) {
    return CustomPaint(
      painter: const _Phase3SpeechBubblePainter(),
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
              height: 1.2),
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
        border: Border.all(color: const Color(0xFF4C6647), width: 1.8),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF251E11).withValues(alpha: 0.08),
              blurRadius: 10.0,
              offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(38.0, 38.0),
                  painter:
                      const _GreenCornerMandalaPainter(corner: _Corner.topRight),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(38.0, 38.0),
                  painter: const _GreenCornerMandalaPainter(
                      corner: _Corner.bottomLeft),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(38.0, 38.0),
                  painter: const _GreenCornerMandalaPainter(
                      corner: _Corner.bottomRight),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 18.0 : 10.0,
                  vertical: isTablet ? 22.0 : 14.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: MundariAudioText(
                      text: currentQ.instruction,
                      onAudioTap: () =>
                          _playMundariAudio(currentQ.instruction),
                      iconSize: isTablet ? 22.0 : 18.0,
                      iconColor: const Color(0xFF671D21),
                      spacing: isTablet ? 7.0 : 5.0,
                      style: TextStyle(
                        fontFamilyFallback: const [
                          'Noto Sans Devanagari',
                          'Mangal',
                          'Nirmala UI',
                          'sans-serif',
                        ],
                        fontSize: isTablet ? 17.0 : 14.0,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF671D21),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    currentQ.englishHelperText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: isTablet ? 11.5 : 10.0,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4A3B32)),
                  ),
                  const SizedBox(height: 10.0),
                  Divider(
                      color: const Color(0xFF4C6647).withValues(alpha: 0.20),
                      thickness: 1.0,
                      height: 1.0),
                  const SizedBox(height: 10.0),
                  MundariAudioText(
                    text: currentQ.mundariSentence,
                    onAudioTap: () =>
                        _playMundariAudio(currentQ.mundariSentence),
                    iconSize: isTablet ? 26.0 : 22.0,
                    iconColor: const Color(0xFF671D21),
                    spacing: isTablet ? 8.0 : 6.0,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    style: TextStyle(
                      fontFamilyFallback: const [
                        'Noto Sans Devanagari',
                        'Mangal',
                        'Nirmala UI',
                        'sans-serif',
                      ],
                      fontSize: isTablet ? 20.0 : 16.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E170E),
                      height: 1.3,
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

  Widget _buildWordBuildingLabel(bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18.0 : 14.0,
          vertical: isTablet ? 9.0 : 7.0),
      decoration: BoxDecoration(
          color: const Color(0xFF4C6647),
          borderRadius: BorderRadius.circular(10.0)),
      child: Text(
        'शब्द चुनें (शब्दों को सही क्रम में लगाएं)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamilyFallback: const [
            'Noto Sans Devanagari',
            'Mangal',
            'Nirmala UI',
            'sans-serif',
          ],
          fontSize: isTablet ? 14.5 : 12.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildAnswerArea(bool isTablet) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isTablet ? 64.0 : 56.0),
      padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 14.0 : 10.0,
          vertical: isTablet ? 10.0 : 8.0),
      decoration: BoxDecoration(
        color: _isChecked
            ? (_isCorrect
                ? const Color(0xFFF1F7EE)
                : const Color(0xFFFDF0EF))
            : const Color(0xFFFAF6F0),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: _isChecked
              ? (_isCorrect
                  ? const Color(0xFF386633)
                  : const Color(0xFF9E2A2B))
              : const Color(0xFFD5C9B8),
          width: _isChecked ? 1.8 : 1.3,
        ),
      ),
      child: _selectedWords.isEmpty
          ? Center(
              child: Text(
                'नीचे से शब्द चुनें…',
                style: TextStyle(
                  fontFamilyFallback: const [
                    'Noto Sans Devanagari',
                    'Mangal',
                    'sans-serif',
                  ],
                  fontSize: isTablet ? 14.0 : 12.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFB3A596),
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          : Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: List.generate(
                _selectedWords.length,
                (i) => _buildAnswerWordChip(
                    word: _selectedWords[i], index: i, isTablet: isTablet),
              ),
            ),
    );
  }

  Widget _buildAnswerWordChip({
    required String word,
    required int index,
    required bool isTablet,
  }) {
    final canRemove = !(_isChecked && _isCorrect);
    Color chipColor;
    Color textColor = Colors.white;
    Color borderColor;

    if (_isChecked) {
      if (_isCorrect) {
        chipColor = const Color(0xFF386633);
        borderColor = const Color(0xFF386633);
      } else {
        chipColor = const Color(0xFF9E2A2B);
        borderColor = const Color(0xFF9E2A2B);
      }
    } else {
      chipColor = const Color(0xFF4C6647);
      borderColor = const Color(0xFF4C6647);
    }

    return GestureDetector(
      onTap: canRemove ? () => _onAnswerWordTap(index) : null,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 14.0 : 10.0,
            vertical: isTablet ? 8.0 : 6.0),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
                color: chipColor.withValues(alpha: 0.30),
                blurRadius: 4.0,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              word,
              style: TextStyle(
                fontFamilyFallback: const [
                  'Noto Sans Devanagari',
                  'Mangal',
                  'Nirmala UI',
                  'sans-serif',
                ],
                fontSize: isTablet ? 17.0 : 15.0,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            if (canRemove) ...[
              const SizedBox(width: 4.0),
              Icon(Icons.close_rounded,
                  size: isTablet ? 14.0 : 12.0,
                  color: textColor.withValues(alpha: 0.80)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWordTiles(bool isTablet) {
    return Wrap(
      spacing: isTablet ? 10.0 : 8.0,
      runSpacing: isTablet ? 10.0 : 8.0,
      children: List.generate(
        _shuffledTiles.length,
        (i) => _buildWordTile(
            word: _shuffledTiles[i], tileIndex: i, isTablet: isTablet),
      ),
    );
  }

  Widget _buildWordTile({
    required String word,
    required int tileIndex,
    required bool isTablet,
  }) {
    final isUsed = _tileUsed[tileIndex];
    return GestureDetector(
      onTap: isUsed ? null : () => _onTileTap(tileIndex),
      child: AnimatedOpacity(
        opacity: isUsed ? 0.30 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 20.0 : 15.0,
              vertical: isTablet ? 14.0 : 11.0),
          decoration: BoxDecoration(
            color: isUsed
                ? const Color(0xFFEDE8E0)
                : const Color(0xFFFAF6F0),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: isUsed
                  ? const Color(0xFFD5C9B8)
                  : const Color(0xFF4A3B32),
              width: isUsed ? 1.0 : 1.5,
            ),
            boxShadow: isUsed
                ? []
                : [
                    BoxShadow(
                        color: const Color(0xFF251E11).withValues(alpha: 0.07),
                        blurRadius: 5.0,
                        offset: const Offset(0, 2))
                  ],
          ),
          child: Text(
            word,
            style: TextStyle(
              fontFamilyFallback: const [
                'Noto Sans Devanagari',
                'Mangal',
                'Nirmala UI',
                'sans-serif',
              ],
              fontSize: isTablet ? 20.0 : 17.0,
              fontWeight: FontWeight.w700,
              color: isUsed
                  ? const Color(0xFFB3A596)
                  : const Color(0xFF251E11),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner(bool isTablet) {
    final currentQ = _currentQuestion;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: _isCorrect
            ? const Color(0xFFEBF5E7)
            : const Color(0xFFFBECEB),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
            color: _isCorrect
                ? const Color(0xFF9BC294)
                : const Color(0xFFE6A6A6),
            width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            _isCorrect
                ? Icons.check_circle_rounded
                : Icons.cancel_rounded,
            color: _isCorrect
                ? const Color(0xFF386633)
                : const Color(0xFF9E2A2B),
            size: 24.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isCorrect
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
                    color: _isCorrect
                        ? const Color(0xFF2B5226)
                        : const Color(0xFF7A1C1D),
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  _isCorrect
                      ? currentQ.feedbackExplanation
                      : 'कृपया पुनः प्रयास करें। शब्दों का सही क्रम चुनें।',
                  style: TextStyle(
                    fontFamilyFallback: const [
                      'Noto Sans Devanagari',
                      'Mangal',
                      'sans-serif',
                    ],
                    fontSize: isTablet ? 13.0 : 12.0,
                    fontWeight: FontWeight.w500,
                    color: _isCorrect
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
        color: const Color(0xFF5E171B),
        borderRadius: BorderRadius.circular(28.0),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF5E171B).withValues(alpha: 0.32),
              blurRadius: 10.0,
              offset: const Offset(0, 3))
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
                  letterSpacing: 1.2),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Speech Bubble Painter (same as Phase 1)
// ---------------------------------------------------------------------------
class _Phase3SpeechBubblePainter extends CustomPainter {
  const _Phase3SpeechBubblePainter();

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
// Green Corner Mandala (same as Phase 1)
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
    canvas.drawArc(Rect.fromCircle(center: center, radius: w * 0.85),
        startAngle, math.pi * 0.5, false, linePaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: w * 0.58),
        startAngle, math.pi * 0.5, false, linePaint);
    final innerPaint = Paint()
      ..color = const Color(0xFF4C6647).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawArc(Rect.fromCircle(center: center, radius: w * 0.32),
        startAngle, math.pi * 0.5, true, innerPaint);
    final tickPaint = Paint()
      ..color = const Color(0xFF4C6647).withValues(alpha: 0.70)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (int i = 1; i <= 5; i++) {
      final angle = startAngle + (i * (math.pi * 0.5 / 6.0));
      final r1 = w * 0.58;
      final r2 = w * 0.76;
      canvas.drawLine(
          Offset(center.dx + r1 * math.cos(angle),
              center.dy + r1 * math.sin(angle)),
          Offset(center.dx + r2 * math.cos(angle),
              center.dy + r2 * math.sin(angle)),
          tickPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Grass Decoration (same as Phase 1)
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
    Widget image = Image.asset(assetPath, width: width,
        fit: BoxFit.contain, filterQuality: FilterQuality.medium);
    if (isFlipped) image = Transform.flip(flipX: true, child: image);
    return Opacity(opacity: opacity, child: image);
  }
}

class _Phase3BackgroundDecoration extends StatelessWidget {
  const _Phase3BackgroundDecoration({required this.isTablet});
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
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
      final leftEdgeX =
          isTablet ? math.max(12.0, (gutter - grass1Width) / 2) : 4.0;
      final rightEdgeX =
          isTablet ? math.max(12.0, (gutter - grass1Width) / 2) : 4.0;

      return IgnorePointer(
        child: Stack(children: [
          Positioned(
            left: leftEdgeX, top: h * 0.31,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _GrassDecorationItem(assetPath: 'assets/images/grass1.png',
                    width: grass1Width, opacity: 0.50),
                Transform.translate(
                  offset: const Offset(-8.0, 3.0),
                  child: _GrassDecorationItem(
                      assetPath: 'assets/images/grass2.png',
                      width: smallGrass2Width, opacity: 0.45),
                ),
              ],
            ),
          ),
          Positioned(
            right: rightEdgeX, top: h * 0.34,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _GrassDecorationItem(assetPath: 'assets/images/grass2.png',
                    width: smallGrass2Width, isFlipped: true, opacity: 0.45),
                Transform.translate(
                  offset: const Offset(-6.0, 0.0),
                  child: _GrassDecorationItem(
                      assetPath: 'assets/images/grass1.png',
                      width: smallGrass1Width, isFlipped: true, opacity: 0.48),
                ),
              ],
            ),
          ),
          Positioned(
            left: leftEdgeX + (isTablet ? 6.0 : 2.0), top: h * 0.64,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _GrassDecorationItem(assetPath: 'assets/images/grass2.png',
                    width: grass2Width, opacity: 0.52),
                Transform.translate(
                  offset: const Offset(-10.0, -5.0),
                  child: _GrassDecorationItem(
                      assetPath: 'assets/images/grass1.png',
                      width: smallGrass1Width, opacity: 0.46),
                ),
              ],
            ),
          ),
          Positioned(
            right: rightEdgeX + (isTablet ? 6.0 : 2.0), top: h * 0.67,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _GrassDecorationItem(assetPath: 'assets/images/grass1.png',
                    width: grass1Width, isFlipped: true, opacity: 0.50),
                Transform.translate(
                  offset: const Offset(-8.0, 4.0),
                  child: _GrassDecorationItem(
                      assetPath: 'assets/images/grass2.png',
                      width: smallGrass2Width, isFlipped: true, opacity: 0.45),
                ),
              ],
            ),
          ),
          Positioned(
            left: leftEdgeX + (isTablet ? 14.0 : 8.0), top: h * 0.82,
            child: _GrassDecorationItem(assetPath: 'assets/images/grass2.png',
                width: smallGrass2Width * 0.9, opacity: 0.42),
          ),
          Positioned(
            right: rightEdgeX + (isTablet ? 14.0 : 8.0), top: h * 0.84,
            child: _GrassDecorationItem(assetPath: 'assets/images/grass1.png',
                width: smallGrass1Width * 0.88, isFlipped: true, opacity: 0.42),
          ),
          if (isTablet) ...[
            Positioned(
              left: leftEdgeX + 8.0, top: h * 0.16,
              child: _GrassDecorationItem(assetPath: 'assets/images/grass2.png',
                  width: smallGrass2Width, opacity: 0.40),
            ),
            Positioned(
              right: rightEdgeX + 8.0, top: h * 0.18,
              child: _GrassDecorationItem(
                  assetPath: 'assets/images/grass1.png',
                  width: smallGrass1Width, isFlipped: true, opacity: 0.40),
            ),
          ],
        ]),
      );
    });
  }
}
