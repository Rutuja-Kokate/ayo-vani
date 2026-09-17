import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../app/responsive/responsive.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/english_activities_data.dart';
import '../../../widgets/ayo_bottom_nav_bar.dart';
import '../../../widgets/ayo_logo.dart';
import '../../../widgets/ayo_screen_background.dart';

import '../../../services/content_generation_service.dart';

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.questionOdia,
    this.optionsOdia,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? questionOdia;
  final List<String>? optionsOdia;

  /// Aliases using Devanagari naming
  String? get questionDevanagari => questionOdia;
  List<String>? get optionsDevanagari => optionsOdia;
}

/// Reusable Quizzes Screen for ANY chapter of ANY class.
class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({
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
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  int _navIndex = 1;
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswerSubmitted = false;
  int _score = 0;
  bool _isLoading = true;
  final ContentGenerationService _ragService = ContentGenerationService();

  List<QuizQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final cached = await _ragService.isCached(widget.chapterName, GenerationArtifactType.quiz);
    if (cached) {
      try {
        final ragQuiz = await _ragService.generateQuiz(widget.chapterName, widget.className);
        final ragItems = ragQuiz.questions.map((q) => QuizQuestion(
          question: q.questionHindi,
          options: q.optionsHindi,
          correctIndex: q.answerIndex,
          explanation: q.explanationHindi,
          questionOdia: q.questionMundari,
          optionsOdia: q.optionsMundari,
        )).toList();
        
        if (mounted) {
          setState(() {
            _questions = ragItems;
            _isLoading = false;
          });
        }
        return;
      } catch (e) {
        debugPrint('[RAG] Failed to load cached quiz: $e');
      }
    }

    if (mounted) {
      setState(() {
        _questions = _generateQuestions();
        _isLoading = false;
      });
    }
  }

  List<QuizQuestion> _generateQuestions() {
    final hardcodedQuizzes = EnglishActivitiesData.getQuizQuestions(widget.chapterName);
    if (hardcodedQuizzes != null && hardcodedQuizzes.isNotEmpty) {
      return hardcodedQuizzes.map((q) {
        return QuizQuestion(
          question: q.question,
          questionOdia: q.questionOdia,
          options: q.options,
          optionsOdia: q.optionsOdia,
          correctIndex: q.correctIndex,
          explanation: q.explanation,
        );
      }).toList();
    }

    final lower = widget.chapterName.toLowerCase();
    if (lower.contains('fruit') || lower.contains('color')) {
      return const [
        QuizQuestion(
          question: 'Which is a red fruit?',
          options: ['Apple', 'Banana', 'Grapes'],
          correctIndex: 0,
          explanation: 'Apple is typically bright red and crisp!',
        ),
        QuizQuestion(
          question: 'What color is a ripe banana?',
          options: ['Blue', 'Yellow', 'Black'],
          correctIndex: 1,
          explanation: 'Ripe bananas are yellow and sweet.',
        ),
        QuizQuestion(
          question: 'Which of these fruits grows in bunches?',
          options: ['Watermelon', 'Grapes', 'Papaya'],
          correctIndex: 1,
          explanation: 'Grapes grow in clusters or bunches on vines.',
        ),
      ];
    } else if (lower.contains('number') || lower.contains('count')) {
      return const [
        QuizQuestion(
          question: 'How many legs does a cow have?',
          options: ['Two (2)', 'Four (4)', 'Six (6)'],
          correctIndex: 1,
          explanation: 'Cows have 4 legs.',
        ),
        QuizQuestion(
          question: 'Which number comes right after 4?',
          options: ['3', '5', '6'],
          correctIndex: 1,
          explanation: 'Counting: 1, 2, 3, 4, 5!',
        ),
      ];
    } else {
      return [
        QuizQuestion(
          question: 'What is the main theme of ${widget.chapterName}?',
          options: [
            widget.chapterName,
            'Unrelated concept',
            'General knowledge',
          ],
          correctIndex: 0,
          explanation: 'Focuses on foundational learning for ${widget.className}.',
        ),
      ];
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

  void _submitAnswer(int index) {
    if (_isAnswerSubmitted) return;
    setState(() {
      _selectedAnswerIndex = index;
      _isAnswerSubmitted = true;
      if (index == _questions[_currentQuestionIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _currentQuestionIndex++;
      _selectedAnswerIndex = null;
      _isAnswerSubmitted = false;
    });
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswerIndex = null;
      _isAnswerSubmitted = false;
      _score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final isTablet = Responsive.isTabletOrLarger(context);
    final isQuizFinished = _currentQuestionIndex >= _questions.length;

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

              // Content
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
                      maxWidth: isTablet ? 840.0 : double.infinity,
                    ),
                    child: Column(
                      children: [
                        _buildTopBar(isTablet),
                        const SizedBox(height: 16.0),
                        _buildHeader(isTablet),
                        const SizedBox(height: 24.0),

                        if (isQuizFinished)
                          _buildCompletionCard(isTablet)
                        else
                          _buildQuestionCard(isTablet),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF526B4F), // Olive Green
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
                const SizedBox(width: 10.0),
                Flexible(
                  child: Text(
                    widget.chapterName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.headingFontFamily,
                      fontSize: isTablet ? 18.0 : 15.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          if (_currentQuestionIndex < _questions.length)
            Text(
              'Q ${_currentQuestionIndex + 1}/${_questions.length}',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(bool isTablet) {
    final currentQ = _questions[_currentQuestionIndex];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: const Color(0xFF526B4F),
          width: 1.8,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x104A3B32),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 28.0 : 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Title & Odia Translation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentQ.question,
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: isTablet ? 22.0 : 18.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (currentQ.questionOdia != null && currentQ.questionOdia!.isNotEmpty) ...[
                const SizedBox(height: 4.0),
                Text(
                  currentQ.questionOdia!,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 18.0 : 15.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBurgundy,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 22.0),

          // Options List
          for (int i = 0; i < currentQ.options.length; i++) ...[
            _buildOptionTile(
              index: i,
              text: currentQ.options[i],
              textOdia: (currentQ.optionsOdia != null && currentQ.optionsOdia!.length > i)
                  ? currentQ.optionsOdia![i]
                  : null,
              isCorrect: i == currentQ.correctIndex,
              isSelected: _selectedAnswerIndex == i,
              isTablet: isTablet,
            ),
            const SizedBox(height: 12.0),
          ],

          if (_isAnswerSubmitted) ...[
            const SizedBox(height: 14.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFE8DECF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedAnswerIndex == currentQ.correctIndex
                            ? Icons.check_circle_rounded
                            : Icons.info_rounded,
                        color: _selectedAnswerIndex == currentQ.correctIndex
                            ? const Color(0xFF385E32)
                            : const Color(0xFFB33222),
                      ),
                      const SizedBox(width: 8.0),
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Correct answer: ${currentQ.options[currentQ.correctIndex]}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (currentQ.optionsDevanagari != null &&
                                  currentQ.optionsDevanagari!.length > currentQ.correctIndex) ...[
                                TextSpan(
                                  text: ' (${currentQ.optionsDevanagari![currentQ.correctIndex]})',
                                  style: TextStyle(
                                    fontFamily: AppTypography.bodyFontFamily,
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryBurgundy,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    currentQ.explanation,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _nextQuestion,
                icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                label: Text(
                  _currentQuestionIndex < _questions.length - 1
                      ? (AppLocalizations.of(context)?.btnNext ?? 'Next Question')
                      : (AppLocalizations.of(context)?.labelQuizCompleted ?? 'View Results'),
                  style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF526B4F),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required int index,
    required String text,
    String? textOdia,
    required bool isCorrect,
    required bool isSelected,
    required bool isTablet,
  }) {
    Color bg = const Color(0xFFFDFBF7);
    Color border = const Color(0xFFE8DECF);

    if (_isAnswerSubmitted) {
      if (isCorrect) {
        bg = const Color(0xFFEFF8EE);
        border = const Color(0xFF385E32);
      } else if (isSelected) {
        bg = const Color(0xFFFBEFEF);
        border = const Color(0xFFB33222);
      }
    } else if (isSelected) {
      bg = const Color(0xFFFAF2E9);
      border = const Color(0xFF526B4F);
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14.0),
      child: InkWell(
        onTap: () => _submitAnswer(index),
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: border, width: isSelected || (_isAnswerSubmitted && isCorrect) ? 2.0 : 1.0),
          ),
          child: Row(
            children: [
              Container(
                width: 22.0,
                height: 22.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? border : Colors.white,
                  border: Border.all(color: border, width: 1.5),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14.0, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: text,
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: isTablet ? 15.0 : 14.0,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (textOdia != null && textOdia.isNotEmpty) ...[
                        TextSpan(
                          text: ' ($textOdia)',
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: isTablet ? 15.0 : 14.0,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: AppColors.primaryBurgundy,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionCard(bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: const Color(0xFF526B4F), width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x104A3B32),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 36.0 : 24.0),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, color: Color(0xFFD49B2A), size: 64.0),
          const SizedBox(height: 12.0),
          Text(
            AppLocalizations.of(context)?.labelQuizCompleted ?? 'Quiz Completed!',
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: isTablet ? 26.0 : 22.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'You scored $_score of ${_questions.length}',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF385E32),
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: _restartQuiz,
            icon: const Icon(Icons.replay_rounded, color: Colors.white),
            label: Text(
              AppLocalizations.of(context)?.btnTryAgain ?? 'Try Again',
              style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF526B4F),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
            ),
          ),
        ],
      ),
    );
  }
}
