import 'package:flutter/material.dart';
import '../../../app/responsive/responsive.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dimens.dart';
import '../../../app/theme/app_typography.dart';
import '../../../widgets/ayo_bottom_nav_bar.dart';
import '../../../widgets/ayo_logo.dart';
import '../../../widgets/ayo_screen_background.dart';

/// Reusable Worksheets Screen for ANY chapter of ANY class.
class WorksheetsScreen extends StatefulWidget {
  const WorksheetsScreen({
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
  State<WorksheetsScreen> createState() => _WorksheetsScreenState();
}

class _WorksheetsScreenState extends State<WorksheetsScreen> {
  int _navIndex = 1;
  int _selectedWorksheet = 0;

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

              // Scrollable Content
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
                      maxWidth: isTablet ? 960.0 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(isTablet),
                        const SizedBox(height: 16.0),
                        _buildHeader(isTablet),
                        const SizedBox(height: 20.0),
                        _buildWorksheetTabs(isTablet),
                        const SizedBox(height: 20.0),
                        _buildWorksheetPreview(isTablet),
                        const SizedBox(height: 24.0),
                        _buildActionButtons(isTablet),
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
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFC88A22), // Warm Amber
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
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chapterName,
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: isTablet ? 19.0 : 16.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Downloadable printable handwriting and concept worksheets',
                  style: TextStyle(
                    fontFamily: AppTypography.bodyFontFamily,
                    fontSize: 12.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorksheetTabs(bool isTablet) {
    final sheets = [
      '1. Tracing & Writing',
      '2. Matching & Drawing',
      '3. Coloring Practice',
    ];

    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: List.generate(sheets.length, (index) {
        final isSelected = index == _selectedWorksheet;
        return ChoiceChip(
          label: Text(sheets[index]),
          selected: isSelected,
          onSelected: (val) => setState(() => _selectedWorksheet = index),
          selectedColor: const Color(0xFFC88A22),
          backgroundColor: const Color(0xFFFDFBF7),
          labelStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
            side: BorderSide(
              color: isSelected ? const Color(0xFFC88A22) : const Color(0xFFE5DACB),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWorksheetPreview(bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: const Color(0xFFE2D4C0),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E4A3B32),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isTablet ? 28.0 : 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sheet Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AYOVAANI Classroom Worksheet',
                style: TextStyle(
                  fontFamily: AppTypography.headingFontFamily,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryBurgundy,
                ),
              ),
              Text(
                'Name: ____________  Date: ______',
                style: TextStyle(
                  fontFamily: AppTypography.bodyFontFamily,
                  fontSize: 12.0,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Divider(height: 24.0, thickness: 1.0, color: Color(0xFFE2D4C0)),

          Text(
            'Exercise: Trace and write the words below',
            style: TextStyle(
              fontFamily: AppTypography.bodyFontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16.0),

          // Guided Tracing Lines for the Chapter
          _buildSampleTracingRow('Banana', '🍌'),
          const SizedBox(height: 16.0),
          _buildSampleTracingRow('Apple', '🍎'),
          const SizedBox(height: 16.0),
          _buildSampleTracingRow('Grapes', '🍇'),
        ],
      ),
    );
  }

  Widget _buildSampleTracingRow(String word, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFEDE4D7)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 26.0)),
          const SizedBox(width: 14.0),
          Text(
            word,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 20.0),
          Expanded(
            child: Container(
              height: 2.0,
              color: const Color(0xFFD4C7B5),
            ),
          ),
          const SizedBox(width: 12.0),
          Text(
            word,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 17.0,
              fontWeight: FontWeight.w300,
              letterSpacing: 2.0,
              color: Color(0xFFB0A294),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Downloading "${widget.chapterName} Worksheet.pdf"...'),
                backgroundColor: const Color(0xFFC88A22),
              ),
            );
          },
          icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20.0),
          label: const Text(
            'Download PDF',
            style: TextStyle(fontFamily: 'Inter', color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC88A22),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
        ),
        const SizedBox(width: 16.0),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sending worksheet to printer...'),
                backgroundColor: AppColors.textPrimary,
              ),
            );
          },
          icon: const Icon(Icons.print_rounded, color: AppColors.textPrimary, size: 20.0),
          label: const Text(
            'Print',
            style: TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 14.0),
            side: const BorderSide(color: Color(0xFFC88A22), width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          ),
        ),
      ],
    );
  }
}
