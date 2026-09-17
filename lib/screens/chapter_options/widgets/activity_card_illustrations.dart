import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';

/// 1. Flashcards Visual Illustration (Fanned cards with Apple front card)
class FlashcardsIllustration extends StatelessWidget {
  const FlashcardsIllustration({
    super.key,
    this.itemName = 'Apple',
    this.itemEmoji = '🍎',
    this.isCompact = false,
  });

  final String itemName;
  final String itemEmoji;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final cardWidth = isCompact ? 100.0 : 124.0;
    final cardHeight = isCompact ? 130.0 : 158.0;

    return SizedBox(
      width: cardWidth + 36.0,
      height: cardHeight + 10.0,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Background tilted card (representing Grape card or stacked card)
          Positioned(
            left: 2.0,
            top: 14.0,
            child: Transform.rotate(
              angle: -0.16,
              child: Container(
                width: cardWidth * 0.92,
                height: cardHeight * 0.92,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F6F0),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFF8E44AD).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A251E11),
                      blurRadius: 6,
                      offset: Offset(-2, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      '🍇',
                      style: TextStyle(fontSize: isCompact ? 22.0 : 28.0),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Foreground main flashcard (White rounded card with Apple)
          Positioned(
            right: 4.0,
            top: 4.0,
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(
                  color: const Color(0xFFE2D4C0),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x104A3B32),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: isCompact ? 8.0 : 12.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Fruit illustration
                    _buildAppleArtwork(size: isCompact ? 46.0 : 72.0),
                    const SizedBox(height: 6.0),
                    // Word label
                    Text(
                      itemName,
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: isCompact ? 13.5 : 16.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleArtwork({required double size}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle glow
          Container(
            width: size * 0.75,
            height: size * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.1),
            ),
          ),
          // Large polished Apple
          Text(
            itemEmoji,
            style: TextStyle(
              fontSize: size * 0.78,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. Worksheets Visual Illustration (Lined handwriting sheet with golden paperclip)
class WorksheetsIllustration extends StatelessWidget {
  const WorksheetsIllustration({
    super.key,
    this.word = 'Banana',
    this.isCompact = false,
  });

  final String word;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final sheetWidth = isCompact ? 116.0 : 144.0;
    final sheetHeight = isCompact ? 134.0 : 162.0;

    return SizedBox(
      width: sheetWidth + 14.0,
      height: sheetHeight + 12.0,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: [
          // The Notebook Paper Sheet
          Container(
            width: sheetWidth,
            height: sheetHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: const Color(0xFFE2D4C0),
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x104A3B32),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(
              isCompact ? 10.0 : 14.0,
              isCompact ? 14.0 : 18.0,
              isCompact ? 10.0 : 14.0,
              isCompact ? 10.0 : 14.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Printed Target Word
                Center(
                  child: Text(
                    word,
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: isCompact ? 14.0 : 16.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: isCompact ? 8.0 : 12.0),

                // Tracing Guidelines Set 1 with dotted letters
                _buildTracingLine(
                  word: word,
                  isCompact: isCompact,
                ),

                SizedBox(height: isCompact ? 10.0 : 14.0),

                // Empty Practice Guidelines Set 2
                _buildEmptyGuidelines(isCompact: isCompact),
              ],
            ),
          ),

          // Golden Brass Paperclip attached at top-right
          Positioned(
            top: -6.0,
            right: 18.0,
            child: _buildPaperclip(isCompact: isCompact),
          ),
        ],
      ),
    );
  }

  Widget _buildTracingLine({
    required String word,
    required bool isCompact,
  }) {
    return Column(
      children: [
        // Top boundary line
        Container(
          height: 1.0,
          color: const Color(0xFFD4C7B5),
        ),
        SizedBox(
          height: isCompact ? 22.0 : 28.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dashed midline
              Row(
                children: List.generate(
                  20,
                  (index) => Expanded(
                    child: Container(
                      height: 1.0,
                      color: index.isEven ? const Color(0xFFC7BBAA) : Colors.transparent,
                    ),
                  ),
                ),
              ),
              // Dotted Tracing Word in outline/dotted style
              Center(
                child: Text(
                  word,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isCompact ? 15.0 : 18.0,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF9E8E7E),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom baseline
        Container(
          height: 1.0,
          color: const Color(0xFFD4C7B5),
        ),
      ],
    );
  }

  Widget _buildEmptyGuidelines({required bool isCompact}) {
    return Column(
      children: [
        Container(
          height: 1.0,
          color: const Color(0xFFE5DACB),
        ),
        SizedBox(
          height: isCompact ? 16.0 : 20.0,
          child: Row(
            children: List.generate(
              20,
              (index) => Expanded(
                child: Container(
                  height: 1.0,
                  color: index.isEven ? const Color(0xFFE5DACB) : Colors.transparent,
                ),
              ),
            ),
          ),
        ),
        Container(
          height: 1.0,
          color: const Color(0xFFE5DACB),
        ),
      ],
    );
  }

  Widget _buildPaperclip({required bool isCompact}) {
    final clipWidth = isCompact ? 16.0 : 20.0;
    final clipHeight = isCompact ? 30.0 : 38.0;

    return Container(
      width: clipWidth,
      height: clipHeight,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: const Color(0xFFC88A22), // Golden Amber brass clip
          width: 2.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 3,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: clipWidth * 0.45,
          height: clipHeight * 0.6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.0),
            border: Border.all(
              color: const Color(0xFFC88A22),
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

/// 3. Games Visual Illustration (Fruit tiles row + Sorting baskets)
class GamesIllustration extends StatelessWidget {
  const GamesIllustration({
    super.key,
    this.isCompact = false,
  });

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final cardWidth = isCompact ? 128.0 : 154.0;
    final cardHeight = isCompact ? 134.0 : 162.0;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: const Color(0xFFE2D4C0),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x104A3B32),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(isCompact ? 8.0 : 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Top Row: 4 fruit matching tiles
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF7F2),
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: const Color(0xFFEDE4D7),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFruitTile('🍎', isCompact),
                _buildFruitTile('🍊', isCompact),
                _buildFruitTile('🍌', isCompact),
                _buildFruitTile('🍇', isCompact),
              ],
            ),
          ),

          // Bottom Row: Two sorting baskets (Red & Yellow)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSortingBasket(
                color: const Color(0xFFD34836), // Red basket
                accentColor: const Color(0xFFB33222),
                fruits: '🍎🍓',
                isCompact: isCompact,
              ),
              _buildSortingBasket(
                color: const Color(0xFFF39C12), // Yellow basket
                accentColor: const Color(0xFFD68910),
                fruits: '🍌🍋',
                isCompact: isCompact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFruitTile(String emoji, bool isCompact) {
    return Container(
      width: isCompact ? 22.0 : 28.0,
      height: isCompact ? 22.0 : 28.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: const Color(0xFFE5DACB),
          width: 1.0,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: isCompact ? 13.0 : 16.0),
        ),
      ),
    );
  }

  Widget _buildSortingBasket({
    required Color color,
    required Color accentColor,
    required String fruits,
    required bool isCompact,
  }) {
    final basketWidth = isCompact ? 46.0 : 56.0;
    final basketHeight = isCompact ? 38.0 : 46.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Overflowing fruits from basket
        Transform.translate(
          offset: const Offset(0, 4),
          child: Text(
            fruits,
            style: TextStyle(fontSize: isCompact ? 13.0 : 16.0),
          ),
        ),
        // Woven crate container
        Container(
          width: basketWidth,
          height: basketHeight,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: color, width: 2.0),
          ),
          child: GridView.count(
            crossAxisCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(3.0),
            children: List.generate(
              6,
              (index) => Container(
                margin: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 4. Quizzes Visual Illustration (Smartphone Mockup Screen with Radio Choices)
class QuizzesIllustration extends StatelessWidget {
  const QuizzesIllustration({
    super.key,
    this.question = 'Which is a red fruit?',
    this.options = const ['Apple', 'Banana', 'Grapes'],
    this.selectedIndex = 0,
    this.isCompact = false,
  });

  final String question;
  final List<String> options;
  final int selectedIndex;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final phoneWidth = isCompact ? 124.0 : 148.0;
    final phoneHeight = isCompact ? 152.0 : 172.0;

    return Container(
      width: phoneWidth,
      height: phoneHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFF6EDE2), // Phone casing color
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFF8B6B58), // Phone frame outline
          width: 2.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x144A3B32),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4.5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 7.0 : 10.0,
          vertical: isCompact ? 5.0 : 8.0,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: isCompact ? 110.0 : 130.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Phone Top Row: Back arrow '<'
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 16.0,
                  color: Color(0xFF8B4B3E),
                ),
                const SizedBox(height: 2.0),

                // Question Text
                Text(
                  question,
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: isCompact ? 9.5 : 11.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 5.0),

                // Radio Option Pills
                for (int i = 0; i < options.length; i++) ...[
                  _buildQuizOptionPill(
                    label: options[i],
                    isSelected: i == selectedIndex,
                    isCompact: isCompact,
                  ),
                  if (i < options.length - 1) const SizedBox(height: 3.5),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizOptionPill({
    required String label,
    required bool isSelected,
    required bool isCompact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 6.0 : 8.0,
        vertical: isCompact ? 3.0 : 4.0,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFFBEFE8) // Warm selected background
            : const Color(0xFFF7F3EC), // Neutral surface
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: isSelected ? const Color(0xFF8B4B3E) : const Color(0xFFE8DECF),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          // Radio indicator circle
          Container(
            width: isCompact ? 10.0 : 12.0,
            height: isCompact ? 10.0 : 12.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? const Color(0xFF8B4B3E) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF8B4B3E) : const Color(0xFFB8A99A),
                width: 1.2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 4.0,
                      height: 4.0,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          ),
          SizedBox(width: isCompact ? 5.0 : 7.0),
          // Option Label
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: isCompact ? 9.5 : 11.0,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF8B4B3E) : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 5. Resources Visual Illustration (Organized curriculum folder with lesson guides & audio notes)
class ResourcesIllustration extends StatelessWidget {
  const ResourcesIllustration({
    super.key,
    this.chapterNumber = 1,
    this.isCompact = false,
  });

  final int chapterNumber;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final cardWidth = isCompact ? 100.0 : 124.0;
    final cardHeight = isCompact ? 130.0 : 158.0;

    return SizedBox(
      width: cardWidth + 36.0,
      height: cardHeight + 10.0,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Background tilted folder leaf
          Positioned(
            left: 2.0,
            top: 14.0,
            child: Transform.rotate(
              angle: -0.14,
              child: Container(
                width: cardWidth * 0.92,
                height: cardHeight * 0.92,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EADC),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFF3B5A82).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A251E11),
                      blurRadius: 6,
                      offset: Offset(-2, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Icon(
                      Icons.folder_shared_rounded,
                      size: isCompact ? 20.0 : 26.0,
                      color: const Color(0xFF3B5A82),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Foreground main resources folder card
          Positioned(
            right: 4.0,
            top: 4.0,
            child: Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.0),
                border: Border.all(
                  color: const Color(0xFFE2D4C0),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x104A3B32),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: isCompact ? 8.0 : 12.0,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: SizedBox(
                  width: cardWidth - 16.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header badge pill
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B5A82).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'MATERIALS',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: isCompact ? 8.5 : 10.0,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF3B5A82),
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isCompact ? 5.0 : 8.0),

                      // Resource preview line 1: Lesson Plan
                      _buildPreviewRow(
                        icon: Icons.menu_book_rounded,
                        iconColor: const Color(0xFF671D21),
                        label: 'Lesson Plan',
                        isCompact: isCompact,
                      ),
                      SizedBox(height: isCompact ? 4.0 : 6.0),

                      // Resource preview line 2: Audio Guide
                      _buildPreviewRow(
                        icon: Icons.audiotrack_rounded,
                        iconColor: const Color(0xFFD49B2A),
                        label: 'Audio Guide',
                        isCompact: isCompact,
                      ),
                      SizedBox(height: isCompact ? 4.0 : 6.0),

                      // Resource preview line 3: Printable Chart
                      _buildPreviewRow(
                        icon: Icons.picture_as_pdf_rounded,
                        iconColor: const Color(0xFF526B4F),
                        label: 'Printables',
                        isCompact: isCompact,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Golden bookmark ribbon on top-right
          Positioned(
            top: -2.0,
            right: 18.0,
            child: Icon(
              Icons.bookmark_rounded,
              size: isCompact ? 22.0 : 26.0,
              color: const Color(0xFFC88A22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool isCompact,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 5.0 : 6.0,
        vertical: isCompact ? 3.5 : 5.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: const Color(0xFFEDE4D8), width: 1.0),
      ),
      child: Row(
        children: [
          Icon(icon, size: isCompact ? 11.0 : 13.0, color: iconColor),
          SizedBox(width: isCompact ? 4.0 : 6.0),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: isCompact ? 9.0 : 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
