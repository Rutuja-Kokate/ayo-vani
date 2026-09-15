import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/responsive/responsive.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../data/english_activities_data.dart';
import '../../../widgets/ayo_bottom_nav_bar.dart';
import '../../../widgets/ayo_logo.dart';
import '../../../widgets/ayo_screen_background.dart';

class AnimalSpot {
  final EnglishMundariWord word;
  final double topRatio;
  final double leftRatio;

  const AnimalSpot({
    required this.word,
    required this.topRatio,
    required this.leftRatio,
  });
}

/// Game 3: "Explore & Find Quest Game" for Chapter "Life Around Us"
class ExploreFindQuestGame extends StatefulWidget {
  const ExploreFindQuestGame({
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
  State<ExploreFindQuestGame> createState() => _ExploreFindQuestGameState();
}

class _ExploreFindQuestGameState extends State<ExploreFindQuestGame> {
  int _navIndex = 1;
  int _score = 0;
  int _secondsRemaining = 90;
  Timer? _timer;
  bool _isFinished = false;

  final Set<String> _foundEnglish = {};
  late List<EnglishMundariWord> _words;
  late List<AnimalSpot> _spots;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initGame() {
    _timer?.cancel();
    _score = 0;
    _secondsRemaining = 90;
    _isFinished = false;
    _foundEnglish.clear();

    _words = EnglishActivitiesData.getWords(widget.chapterName) ?? [];

    // Positions on the scene canvas (relative percentages)
    final positions = const [
      Offset(0.12, 0.15), // Lion
      Offset(0.68, 0.12), // Monkey
      Offset(0.42, 0.42), // Fish
      Offset(0.15, 0.65), // Elephant
      Offset(0.72, 0.68), // Frog
      Offset(0.45, 0.78), // Rabbit
    ];

    _spots = [];
    for (int i = 0; i < _words.length; i++) {
      final pos = i < positions.length ? positions[i] : Offset(0.2 * (i % 4), 0.2 * (i ~/ 4));
      _spots.add(
        AnimalSpot(
          word: _words[i],
          leftRatio: pos.dx,
          topRatio: pos.dy,
        ),
      );
    }

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0 && !_isFinished) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
        if (!_isFinished) {
          setState(() {
            _isFinished = true;
          });
        }
      }
    });
  }

  void _onAnimalTap(EnglishMundariWord word) {
    if (_isFinished) return;

    if (_foundEnglish.contains(word.english)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You already found ${word.english}!'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: const Color(0xFF765E49),
        ),
      );
      return;
    }

    setState(() {
      _foundEnglish.add(word.english);
      _score += 10;

      if (_foundEnglish.length == _words.length) {
        _timer?.cancel();
        // Bonus points for time remaining
        _score += _secondsRemaining;
        _isFinished = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Found ${word.english}! (${word.mundariDisplay}) (+10 pts)'),
        duration: const Duration(milliseconds: 900),
        backgroundColor: const Color(0xFF385E32),
      ),
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

  String get _formattedTime {
    final mins = _secondsRemaining ~/ 60;
    final secs = _secondsRemaining % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
                      maxWidth: isTablet ? 920.0 : double.infinity,
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
                          _buildGameBoard(isTablet),
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
                    color: const Color(0xFF385E32),
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
                    'Explore & Find Quest',
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E5E2),
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xFFEAD8D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_rounded, color: AppColors.primaryBurgundy, size: 18.0),
                    const SizedBox(width: 4.0),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: AppColors.primaryBurgundy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF2E9),
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xFFE2D4C0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFD49B2A), size: 18.0),
                    const SizedBox(width: 4.0),
                    Text(
                      '⭐ $_score',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(bool isTablet) {
    return Column(
      children: [
        // Interactive Scene Canvas
        Container(
          width: double.infinity,
          height: isTablet ? 320.0 : 260.0,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFFFF8E1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(22.0),
            border: Border.all(color: const Color(0xFF385E32), width: 2.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x104A3B32),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return Stack(
                children: [
                  // Decorative Trees & Ponds background hints
                  Positioned(
                    bottom: 10,
                    left: 20,
                    child: Opacity(
                      opacity: 0.7,
                      child: Text('🌳', style: TextStyle(fontSize: isTablet ? 48.0 : 38.0)),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 30,
                    child: Opacity(
                      opacity: 0.8,
                      child: Text('☀️', style: TextStyle(fontSize: isTablet ? 42.0 : 34.0)),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 40,
                    child: Opacity(
                      opacity: 0.6,
                      child: Text('🌿', style: TextStyle(fontSize: isTablet ? 36.0 : 28.0)),
                    ),
                  ),

                  // Tappable Animal Spots
                  for (final spot in _spots) ...[
                    Positioned(
                      left: spot.leftRatio * (w - 70.0),
                      top: spot.topRatio * (h - 70.0),
                      child: GestureDetector(
                        onTap: () => _onAnimalTap(spot.word),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _foundEnglish.contains(spot.word.english) ? 0.3 : 1.0,
                          child: Container(
                            width: isTablet ? 68.0 : 56.0,
                            height: isTablet ? 68.0 : 56.0,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _foundEnglish.contains(spot.word.english)
                                    ? const Color(0xFF385E32)
                                    : const Color(0xFFC88A22),
                                width: 2.0,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x124A3B32),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                _foundEnglish.contains(spot.word.english) ? '✓' : spot.word.emoji,
                                style: TextStyle(
                                  fontSize: _foundEnglish.contains(spot.word.english)
                                      ? (isTablet ? 30.0 : 24.0)
                                      : (isTablet ? 36.0 : 28.0),
                                  color: const Color(0xFF385E32),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 18.0),

        // Animals Checklist
        _buildChecklist(isTablet),
      ],
    );
  }

  Widget _buildChecklist(bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xFFE8DECF), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E4A3B32),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 20.0 : 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Find All 6 Animals:',
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: isTablet ? 16.0 : 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Found: ${_foundEnglish.length}/${_words.length}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF385E32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // 2-column or 3-column checklist items
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _words.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: isTablet ? 3.2 : 2.8,
            ),
            itemBuilder: (context, index) {
              final w = _words[index];
              final isFound = _foundEnglish.contains(w.english);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: isFound ? const Color(0xFFEFF8EE) : const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isFound ? const Color(0xFF385E32) : const Color(0xFFEDE4D7),
                    width: isFound ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isFound ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: isFound ? const Color(0xFF385E32) : const Color(0xFF95806E),
                      size: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            w.english,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isFound ? const Color(0xFF385E32) : AppColors.textPrimary,
                              decoration: isFound ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '( ${w.mundariRoman} / ',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10.0,
                                    color: isFound ? const Color(0xFF385E32) : AppColors.primaryBurgundy,
                                  ),
                                ),
                                TextSpan(
                                  text: '${w.mundariDevanagari} )',
                                  style: TextStyle(
                                    fontFamily: AppTypography.bodyFontFamily,
                                    fontSize: 10.0,
                                    color: isFound ? const Color(0xFF385E32) : AppColors.primaryBurgundy,
                                  ),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard(bool isTablet) {
    final allFound = _foundEnglish.length == _words.length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(color: const Color(0xFF385E32), width: 1.8),
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
          Icon(
            allFound ? Icons.emoji_events_rounded : Icons.timer_off_rounded,
            color: allFound ? const Color(0xFFD49B2A) : AppColors.primaryBurgundy,
            size: 68.0,
          ),
          const SizedBox(height: 12.0),
          Text(
            allFound ? 'Quest Completed!' : "Time's up!",
            style: TextStyle(
              fontFamily: AppTypography.headingFontFamily,
              fontSize: isTablet ? 28.0 : 24.0,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            allFound
                ? 'Great exploring! Found all ${_words.length} animals with $_score total points!'
                : 'Found ${_foundEnglish.length} of ${_words.length} animals! Total score: $_score points.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: allFound ? const Color(0xFF385E32) : AppColors.primaryBurgundy,
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: _initGame,
            icon: const Icon(Icons.replay_rounded, color: Colors.white),
            label: const Text(
              'Play Again',
              style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF385E32),
              padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 13.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
            ),
          ),
        ],
      ),
    );
  }
}
