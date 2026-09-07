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

/// Game 1: "Handy Actions Match Game" for Chapter "Two Little Hands"
class HandyActionsMatchGame extends StatefulWidget {
  const HandyActionsMatchGame({
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
  State<HandyActionsMatchGame> createState() => _HandyActionsMatchGameState();
}

class _HandyActionsMatchGameState extends State<HandyActionsMatchGame> {
  int _navIndex = 1;
  int _currentIndex = 0;
  int _score = 0;
  bool _isFinished = false;

  int? _selectedOptionIndex;
  bool? _isSelectionCorrect;
  bool _isProcessing = false;

  late final List<EnglishMundariWord> _words;
  late List<EnglishMundariWord> _currentOptions;

  @override
  void initState() {
    super.initState();
    final data = EnglishActivitiesData.getWords(widget.chapterName) ?? [];
    _words = List.from(data);
    _loadCurrentRound();
  }

  void _loadCurrentRound() {
    if (_words.isEmpty || _currentIndex >= _words.length) {
      _isFinished = true;
      return;
    }

    final currentWord = _words[_currentIndex];
    final otherWords = _words.where((w) => w.english != currentWord.english).toList();
    otherWords.shuffle(Random());

    final distractors = otherWords.take(2).toList();
    final options = <EnglishMundariWord>[currentWord, ...distractors];
    options.shuffle(Random());

    _currentOptions = options;
    _selectedOptionIndex = null;
    _isSelectionCorrect = null;
    _isProcessing = false;
  }

  void _handleOptionTap(int index) {
    if (_isProcessing) return;

    final selectedWord = _currentOptions[index];
    final targetWord = _words[_currentIndex];
    final isCorrect = selectedWord.english == targetWord.english;

    setState(() {
      _selectedOptionIndex = index;
      _isSelectionCorrect = isCorrect;
    });

    if (isCorrect) {
      _isProcessing = true;
      setState(() {
        _score += 10;
      });

      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          if (_currentIndex + 1 < _words.length) {
            _currentIndex++;
            _loadCurrentRound();
          } else {
            _isFinished = true;
          }
        });
      });
    } else {
      // Allow retry
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() {
          _selectedOptionIndex = null;
          _isSelectionCorrect = null;
        });
      });
    }
  }

  void _restartGame() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _isFinished = false;
      _loadCurrentRound();
    });
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
                        const SizedBox(height: 20.0),

                        if (_isFinished)
                          _buildCompletionCard(isTablet)
                        else
                          _buildGameCard(isTablet),
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
                    color: AppColors.primaryBurgundy,
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
                    'Handy Actions Match',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF2E9),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(color: const Color(0xFFE2D4C0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFD49B2A), size: 20.0),
                const SizedBox(width: 4.0),
                Text(
                  '⭐ $_score',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 13.0,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(bool isTablet) {
    if (_words.isEmpty) return const SizedBox.shrink();
    final currentWord = _words[_currentIndex];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: AppColors.primaryBurgundy,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Word Progress Badge
          Text(
            'Word ${_currentIndex + 1} of ${_words.length}',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12.0),

          // Big Emoji + English Word
          Text(
            currentWord.emoji,
            style: TextStyle(fontSize: isTablet ? 72.0 : 58.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            currentWord.english,
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: isTablet ? 30.0 : 26.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Select the matching Mundari word:',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 13.0,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20.0),

          // 3 Option Buttons
          for (int i = 0; i < _currentOptions.length; i++) ...[
            if (i > 0) const SizedBox(height: 12.0),
            _buildOptionButton(i, _currentOptions[i], isTablet),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionButton(int index, EnglishMundariWord optionWord, bool isTablet) {
    Color bg = const Color(0xFFFDFBF7);
    Color border = const Color(0xFFE8DECF);
    Color textColor = AppColors.textPrimary;

    if (_selectedOptionIndex == index) {
      if (_isSelectionCorrect == true) {
        bg = const Color(0xFFEFF8EE);
        border = const Color(0xFF385E32);
        textColor = const Color(0xFF385E32);
      } else if (_isSelectionCorrect == false) {
        bg = const Color(0xFFFBEFEF);
        border = const Color(0xFFB33222);
        textColor = const Color(0xFFB33222);
      }
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16.0),
      child: InkWell(
        onTap: () => _handleOptionTap(index),
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: border, width: _selectedOptionIndex == index ? 2.0 : 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '( ${optionWord.mundariRoman} / ',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: isTablet ? 17.0 : 15.0,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      TextSpan(
                        text: '${optionWord.mundariOdia} )',
                        style: TextStyle(
                          fontFamily: 'NotoSansOriya',
                          fontSize: isTablet ? 17.0 : 15.0,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_selectedOptionIndex == index && _isSelectionCorrect == true) ...[
                const SizedBox(width: 8.0),
                const Icon(Icons.check_circle_rounded, color: Color(0xFF385E32), size: 22.0),
              ] else if (_selectedOptionIndex == index && _isSelectionCorrect == false) ...[
                const SizedBox(width: 8.0),
                const Icon(Icons.cancel_rounded, color: Color(0xFFB33222), size: 22.0),
              ],
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
        border: Border.all(color: AppColors.primaryBurgundy, width: 1.8),
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
          const Icon(Icons.stars_rounded, color: Color(0xFFD49B2A), size: 68.0),
          const SizedBox(height: 12.0),
          Text(
            'Well done!',
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: isTablet ? 28.0 : 24.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'You completed all body parts with $_score points!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF385E32),
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: _restartGame,
            icon: const Icon(Icons.replay_rounded, color: Colors.white),
            label: const Text(
              'Play Again',
              style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBurgundy,
              padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 13.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
            ),
          ),
        ],
      ),
    );
  }
}
