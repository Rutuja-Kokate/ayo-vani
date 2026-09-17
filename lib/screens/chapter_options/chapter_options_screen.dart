import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../app/responsive/responsive.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimens.dart';
import '../../app/theme/app_typography.dart';
import '../../widgets/ayo_bottom_nav_bar.dart';
import '../../widgets/ayo_logo.dart';
import '../../widgets/ayo_screen_background.dart';
import '../activities/flashcards/flashcards_screen.dart';
import '../activities/games/games_screen.dart';
import '../activities/quizzes/quizzes_screen.dart';
import '../activities/worksheets/worksheets_screen.dart';
import 'widgets/activity_card_illustrations.dart';
import 'widgets/learning_option_card.dart';
import '../../services/content_generation_service.dart';

/// Screen: Reusable Chapter Options Screen for AYOVAANI.
///
/// Strictly reproduces the visual design, structure, and spacing of the reference image:
/// - One reusable template for ANY chapter of ANY class (Balvatika, First, Second, Third)
/// - Top Bar: Back button on top-left, centered official AyoVaani logo, Warli corner ornaments
/// - Chapter Header: Left chapter badge & title, Right Chapter Information Card with Warli art
/// - Four Learning Options: Flashcards, Worksheets, Games, Quizzes
/// - Tablet: 2 × 2 Grid (Flashcards | Worksheets, Games | Quizzes)
/// - Mobile: Single-column scrollable layout
/// - Existing bottom navigation bar
class ChapterOptionsScreen extends StatefulWidget {
  const ChapterOptionsScreen({
    super.key,
    required this.className,
    required this.chapterNumber,
    required this.chapterName,
    this.subject = 'Hindi',
    this.chapterDescription = "Let's learn and practice.",
    this.topic = "Fruits & colors.",
    this.lesson = "Basic vocabulary.",
    this.chapterImage,
    this.chapterEmoji,
    this.onBack,
    this.onNavigateTab,
  });

  /// The class name: "Balvatika", "First", "Second", "Third"
  final String className;

  /// The chapter number: 1, 2, 3, etc.
  final int chapterNumber;

  /// The chapter name: "Fruits and Colors", "Numbers Around Us", etc.
  final String chapterName;

  /// The subject: "English", "Hindi", "Math", etc.
  final String subject;

  /// Subtitle or encouraging description
  final String chapterDescription;

  /// Main syllabus topic
  final String topic;

  /// Educational lesson focus
  final String lesson;

  /// Optional chapter image asset path
  final String? chapterImage;

  /// Optional chapter emoji (e.g. "🍎🍇")
  final String? chapterEmoji;

  /// Custom back callback
  final VoidCallback? onBack;

  /// Bottom tab navigation callback
  final ValueChanged<int>? onNavigateTab;

  @override
  State<ChapterOptionsScreen> createState() => _ChapterOptionsScreenState();
}

class _ChapterOptionsScreenState extends State<ChapterOptionsScreen> {
  int _navIndex = 1; // Highlight 'Learn' tab by default
  final ContentGenerationService _contentGenerationService = ContentGenerationService();
  bool _isGenerating = false;
  
  bool _hasFlashcardsCached = false;
  bool _hasQuizzesCached = false;
  bool _hasWorksheetsCached = false;

  @override
  void initState() {
    super.initState();
    _checkCacheStatus();
  }

  Future<void> _checkCacheStatus() async {
    final fc = await _contentGenerationService.isCached(widget.chapterName, GenerationArtifactType.flashcard);
    final qz = await _contentGenerationService.isCached(widget.chapterName, GenerationArtifactType.quiz);
    final ws = await _contentGenerationService.isCached(widget.chapterName, GenerationArtifactType.worksheet);
    if (mounted) {
      setState(() {
        _hasFlashcardsCached = fc;
        _hasQuizzesCached = qz;
        _hasWorksheetsCached = ws;
      });
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
      // Return to Home root
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(index);
    } else {
      setState(() {
        _navIndex = index;
      });
    }
  }

  void _navigateToFlashcards() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FlashcardsScreen(
          className: widget.className,
          subject: widget.subject,
          chapterNumber: widget.chapterNumber,
          chapterName: widget.chapterName,
          onNavigateTab: widget.onNavigateTab,
        ),
      ),
    );
  }

  void _navigateToWorksheets() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => WorksheetsScreen(
          className: widget.className,
          chapterNumber: widget.chapterNumber,
          chapterName: widget.chapterName,
          onNavigateTab: widget.onNavigateTab,
        ),
      ),
    );
  }

  void _navigateToGames() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => GamesScreen(
          className: widget.className,
          chapterNumber: widget.chapterNumber,
          chapterName: widget.chapterName,
          onNavigateTab: widget.onNavigateTab,
        ),
      ),
    );
  }

  void _navigateToQuizzes() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => QuizzesScreen(
          className: widget.className,
          chapterNumber: widget.chapterNumber,
          chapterName: widget.chapterName,
          onNavigateTab: widget.onNavigateTab,
        ),
      ),
    );
  }

  Future<void> _showGenerateBottomSheet() async {
    final result = await showModalBottomSheet<GenerationArtifactType>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Generate AI Content',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.style, color: AppColors.primaryBurgundy),
                title: const Text('Flashcards'),
                onTap: () => Navigator.pop(context, GenerationArtifactType.flashcard),
              ),
              ListTile(
                leading: const Icon(Icons.edit_document, color: AppColors.primaryBurgundy),
                title: const Text('Worksheets'),
                onTap: () => Navigator.pop(context, GenerationArtifactType.worksheet),
              ),
              ListTile(
                leading: const Icon(Icons.quiz, color: AppColors.primaryBurgundy),
                title: const Text('Quizzes'),
                onTap: () => Navigator.pop(context, GenerationArtifactType.quiz),
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        _isGenerating = true;
      });

      try {
        if (result == GenerationArtifactType.flashcard) {
          await _contentGenerationService.generateFlashcards(widget.chapterName, widget.className, forceRefresh: true, subject: widget.subject);
        } else if (result == GenerationArtifactType.worksheet) {
          await _contentGenerationService.generateWorksheet(widget.chapterName, widget.className, forceRefresh: true);
        } else if (result == GenerationArtifactType.quiz) {
          await _contentGenerationService.generateQuiz(widget.chapterName, widget.className, forceRefresh: true);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Content generated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error generating content: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isGenerating = false;
          });
          _checkCacheStatus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);
    final cornerSize = isTablet ? 135.0 : 95.0;

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              // Top-left Warli Corner Ornament
              Positioned(
                top: 0,
                left: 0,
                child: IgnorePointer(
                  child: _buildCornerDecoration(isRight: false, size: cornerSize),
                ),
              ),

              // Top-right Warli Corner Ornament (Horizontally Mirrored)
              Positioned(
                top: 0,
                right: 0,
                child: IgnorePointer(
                  child: _buildCornerDecoration(isRight: true, size: cornerSize),
                ),
              ),

              // Bottom-left Warli Corner Ornament
              Positioned(
                bottom: 0,
                left: 0,
                child: IgnorePointer(
                  child: Transform.flip(
                    flipY: true,
                    child: _buildCornerDecoration(
                      isRight: false,
                      size: cornerSize * 0.85,
                    ),
                  ),
                ),
              ),

              // Bottom-right Warli Corner Ornament
              Positioned(
                bottom: 0,
                right: 0,
                child: IgnorePointer(
                  child: Transform.flip(
                    flipX: true,
                    flipY: true,
                    child: _buildCornerDecoration(
                      isRight: true,
                      size: cornerSize * 0.85,
                    ),
                  ),
                ),
              ),

              // Main Scrollable Content
              LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = isTablet ? 48.0 : AppSpacing.lg;
                  final contentMaxWidth = isTablet ? 1060.0 : double.infinity;

                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: isTablet ? 14.0 : 12.0,
                      bottom: 24.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: contentMaxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Top Bar: Back Button + Centered AyoVaani Logo
                            _buildTopBar(isTablet),

                            SizedBox(height: isTablet ? 14.0 : 12.0),

                            // 2. Chapter Header: Title & Info Card
                            _buildChapterHeader(isTablet),

                            SizedBox(height: isTablet ? 22.0 : 18.0),

                            // 3. Main Content: Four Option Cards
                            if (isTablet)
                              _buildTabletOptionsGrid()
                            else
                              _buildMobileOptionsList(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
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

  /// Top decorative Warli corner ornament
  Widget _buildCornerDecoration({
    required bool isRight,
    required double size,
  }) {
    final imageWidget = Image.asset(
      'assets/images/corner-design.png',
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/corner-desing.png',
          width: size,
          fit: BoxFit.contain,
        );
      },
    );

    return isRight
        ? Transform.flip(
            flipX: true,
            child: imageWidget,
          )
        : imageWidget;
  }

  /// 1. Top Bar: Back Button on top-left, Centered AyoVaani Logo
  Widget _buildTopBar(bool isTablet) {
    final logoHeight = isTablet ? 100.0 : 80.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Back Button on the top left
        Align(
          alignment: Alignment.centerLeft,
          child: Material(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(20.0),
            child: InkWell(
              onTap: _handleBack,
              borderRadius: BorderRadius.circular(20.0),
              splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.12),
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: const Color(0xFFE8DECF),
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x084A3B32),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
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

        // Centered Official AyoVaani Logo
        Center(
          child: AyoLogo(
            height: logoHeight,
            assetPath: 'assets/images/ayovaani_logo.png',
          ),
        ),
      ],
    );
  }

  /// 2. Chapter Header: Chapter Title & Badge on left, Information Card on right
  Widget _buildChapterHeader(bool isTablet) {
    final emojiText = widget.chapterEmoji ?? '🍎🍇';

    final titleBlock = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Cultural Illustration / Badge container
        Container(
          width: isTablet ? 68.0 : 58.0,
          height: isTablet ? 68.0 : 58.0,
          decoration: BoxDecoration(
            color: const Color(0xFFF7ECE1),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFFE8DECF),
              width: 1.0,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/warli_background.png',
                fit: BoxFit.cover,
                alignment: const Alignment(-0.35, 0.45),
              ),
              Container(
                color: const Color(0x10671D21),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14.0),

        // Chapter Number, Title, and Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chapter',
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: isTablet ? 24.0 : 20.0,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 3.0),

              // Row with Maroon Circular Chapter Number Badge + Chapter Name + Emoji
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: isTablet ? 24.0 : 22.0,
                    height: isTablet ? 24.0 : 22.0,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBurgundy,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.chapterNumber}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Flexible(
                    child: Text(
                      widget.chapterName,
                      style: TextStyle(
                        fontFamily: AppTypography.headingFontFamily,
                        fontSize: isTablet ? 22.0 : 18.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  if (emojiText.isNotEmpty) ...[
                    const SizedBox(width: 6.0),
                    Text(
                      emojiText,
                      style: TextStyle(
                        fontSize: isTablet ? 18.0 : 16.0,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 3.0),

              Text(
                widget.chapterDescription,
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: isTablet ? 13.5 : 12.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    // Chapter Information Card on Upper Right
    final infoCard = Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFE8DECF),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x064A3B32),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      child: Row(
        mainAxisSize: isTablet ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Warli thumbnail illustration
          Container(
            width: isTablet ? 115.0 : 85.0,
            height: isTablet ? 64.0 : 54.0,
            decoration: BoxDecoration(
              color: const Color(0xFFF2E6D5),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: const Color(0xFFE2D4C0),
                width: 1.0,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/warli_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(width: 12.0),

          // Details: Topics & Lesson
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Topics:',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF765E49),
                  ),
                ),
                Text(
                  widget.topic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 13.5 : 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Lesson:',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF765E49),
                  ),
                ),
                Text(
                  widget.lesson,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isTablet ? 13.5 : 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final generateButton = Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: ElevatedButton.icon(
        onPressed: _isGenerating ? null : _showGenerateBottomSheet,
        icon: _isGenerating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_isGenerating ? 'Generating...' : '✨ Generate Content'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBurgundy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          minimumSize: const Size(double.infinity, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );

    if (isTablet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 3, child: titleBlock),
          const SizedBox(width: 18.0),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [infoCard, generateButton],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleBlock,
          const SizedBox(height: 12.0),
          infoCard,
          generateButton,
        ],
      );
    }
  }

  /// Tablet 2 × 2 Grid: Flashcards | Worksheets on Row 1, Games | Quizzes on Row 2
  Widget _buildTabletOptionsGrid() {
    return Column(
      children: [
        // Row 1: Flashcards & Worksheets
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildFlashcardsCard(isTablet: true),
            ),
            const SizedBox(width: 18.0),
            Expanded(
              child: _buildWorksheetsCard(isTablet: true),
            ),
          ],
        ),
        const SizedBox(height: 18.0),

        // Row 2: Games & Quizzes
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildGamesCard(isTablet: true),
            ),
            const SizedBox(width: 18.0),
            Expanded(
              child: _buildQuizzesCard(isTablet: true),
            ),
          ],
        ),
      ],
    );
  }

  /// Mobile Single-column List: Flashcards ↓ Worksheets ↓ Games ↓ Quizzes
  Widget _buildMobileOptionsList() {
    return Column(
      children: [
        _buildFlashcardsCard(isTablet: false),
        const SizedBox(height: 14.0),
        _buildWorksheetsCard(isTablet: false),
        const SizedBox(height: 14.0),
        _buildGamesCard(isTablet: false),
        const SizedBox(height: 14.0),
        _buildQuizzesCard(isTablet: false),
      ],
    );
  }

  /// 1. Flashcards Card
  Widget _buildFlashcardsCard({required bool isTablet}) {
    final l10n = AppLocalizations.of(context);
    return LearningOptionCard(
      title: l10n?.tabFlashcards ?? 'Flashcards',
      subtitle: l10n?.chapterFlashcardsSub ?? 'Interactive visual aids',
      borderColor: const Color(0xFF671D21), // Deep Burgundy / Maroon outline
      isTablet: isTablet,
      iconWidget: _buildFlashcardIcon(isTablet),
      illustration: FlashcardsIllustration(
        itemName: widget.chapterName.toLowerCase().contains('fruit')
            ? 'Apple'
            : (l10n?.unitLabel != null ? '${l10n!.unitLabel} 1' : 'Unit 1'),
        itemEmoji: widget.chapterName.toLowerCase().contains('fruit') ? '🍎' : '📖',
        isCompact: !isTablet,
      ),
      onTap: _navigateToFlashcards,
    );
  }

  /// 2. Worksheets Card
  Widget _buildWorksheetsCard({required bool isTablet}) {
    final l10n = AppLocalizations.of(context);
    return LearningOptionCard(
      title: l10n?.tabWorksheets ?? 'Worksheets',
      subtitle: l10n?.chapterWorksheetsSub ?? 'Downloadable exercises',
      borderColor: const Color(0xFFD49B2A), // Warm Golden Amber outline
      isTablet: isTablet,
      iconWidget: _buildWorksheetIcon(isTablet),
      illustration: WorksheetsIllustration(
        word: widget.chapterName.toLowerCase().contains('fruit')
            ? 'Banana'
            : (l10n?.practiceLabel ?? 'Practice'),
        isCompact: !isTablet,
      ),
      onTap: _navigateToWorksheets,
    );
  }

  /// 3. Games Card
  Widget _buildGamesCard({required bool isTablet}) {
    final l10n = AppLocalizations.of(context);
    return LearningOptionCard(
      title: l10n?.tabGames ?? 'Games',
      subtitle: l10n?.chapterGamesSub ?? 'Fun matching & sorting activities',
      borderColor: const Color(0xFFA85B4F), // Terracotta / Coral brick outline
      isTablet: isTablet,
      iconWidget: _buildGamesIcon(isTablet),
      illustration: GamesIllustration(
        isCompact: !isTablet,
      ),
      onTap: _navigateToGames,
    );
  }

  /// 4. Quizzes Card
  Widget _buildQuizzesCard({required bool isTablet}) {
    final l10n = AppLocalizations.of(context);
    return LearningOptionCard(
      title: l10n?.tabQuizzes ?? 'Quizzes',
      subtitle: l10n?.chapterQuizzesSub ?? 'Test your knowledge',
      borderColor: const Color(0xFF526B4F), // Muted Olive Green outline
      isTablet: isTablet,
      iconWidget: _buildQuizzesIcon(isTablet),
      illustration: QuizzesIllustration(
        question: widget.chapterName.toLowerCase().contains('fruit')
            ? (l10n?.quizPreviewFruitQuestion ?? 'Which is a red fruit?')
            : (l10n?.quizPreviewQuestion ?? 'Key chapter question?'),
        options: widget.chapterName.toLowerCase().contains('fruit')
            ? const ['Apple', 'Banana', 'Grapes']
            : [
                l10n?.optionA ?? 'Option A',
                l10n?.optionB ?? 'Option B',
                l10n?.optionC ?? 'Option C',
              ],
        isCompact: !isTablet,
      ),
      onTap: _navigateToQuizzes,
    );
  }

  // --- Left Action Icons strictly styled like the reference ---

  Widget _buildFlashcardIcon(bool isTablet) {
    final size = isTablet ? 56.0 : 48.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Tilted background card
          Positioned(
            right: 0,
            top: 2,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: size * 0.65,
                height: size * 0.78,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF2E6),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFB33222), width: 1.5),
                ),
              ),
            ),
          ),
          // Foreground card with picture frame
          Positioned(
            left: 0,
            top: 6,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: size * 0.68,
                height: size * 0.8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: const Color(0xFFB33222), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Color(0x12000000), blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.image_rounded,
                    size: isTablet ? 22.0 : 18.0,
                    color: const Color(0xFF4C6B46),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorksheetIcon(bool isTablet) {
    final size = isTablet ? 56.0 : 48.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Clipboard paper
          Positioned(
            left: 2,
            top: 2,
            child: Container(
              width: size * 0.72,
              height: size * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: const Color(0xFFC88A22), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Color(0x12000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 2.0, width: size * 0.35, color: const Color(0xFFC88A22)),
                  const SizedBox(height: 4.0),
                  Container(height: 2.0, width: size * 0.5, color: const Color(0xFFD8C6AC)),
                  const SizedBox(height: 4.0),
                  Container(height: 2.0, width: size * 0.4, color: const Color(0xFFD8C6AC)),
                ],
              ),
            ),
          ),
          // Pencil angled
          Positioned(
            right: 0,
            bottom: 0,
            child: Transform.rotate(
              angle: -0.7,
              child: Icon(
                Icons.edit_rounded,
                size: isTablet ? 30.0 : 26.0,
                color: const Color(0xFFC88A22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesIcon(bool isTablet) {
    final size = isTablet ? 56.0 : 48.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Floating puzzle piece on top right
          Positioned(
            right: 4,
            top: 0,
            child: Icon(
              Icons.extension_rounded,
              size: isTablet ? 20.0 : 17.0,
              color: const Color(0xFFD49B2A),
            ),
          ),
          // Gamepad controller below
          Positioned(
            left: 2,
            bottom: 2,
            child: Icon(
              Icons.sports_esports_rounded,
              size: isTablet ? 42.0 : 36.0,
              color: const Color(0xFFA85B4F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizzesIcon(bool isTablet) {
    final size = isTablet ? 56.0 : 48.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Checklist clipboard
          Positioned(
            left: 2,
            top: 2,
            child: Container(
              width: size * 0.72,
              height: size * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: const Color(0xFF526B4F), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Color(0x12000000), blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 5.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, size: 10.0, color: Color(0xFF526B4F)),
                        const SizedBox(width: 2.0),
                        Container(height: 2.0, width: size * 0.26, color: const Color(0xFF526B4F)),
                      ],
                    ),
                    const SizedBox(height: 3.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, size: 10.0, color: Color(0xFF526B4F)),
                        const SizedBox(width: 2.0),
                        Container(height: 2.0, width: size * 0.22, color: const Color(0xFF526B4F)),
                      ],
                    ),
                    const SizedBox(height: 3.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded, size: 10.0, color: Color(0xFF526B4F)),
                        const SizedBox(width: 2.0),
                        Container(height: 2.0, width: size * 0.26, color: const Color(0xFF526B4F)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Glowing lightbulb on right
          Positioned(
            right: 0,
            bottom: 2,
            child: Icon(
              Icons.lightbulb_rounded,
              size: isTablet ? 26.0 : 22.0,
              color: const Color(0xFFD49B2A),
            ),
          ),
        ],
      ),
    );
  }
}
