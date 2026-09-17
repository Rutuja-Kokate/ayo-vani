import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import '../../../app/responsive/responsive.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../widgets/ayo_bottom_nav_bar.dart';
import '../../../widgets/ayo_logo.dart';
import '../../../widgets/ayo_screen_background.dart';

/// Screen: In-app offline PDF viewer for Chapter 1 Reading Material.
class ChapterPdfViewerScreen extends StatefulWidget {
  const ChapterPdfViewerScreen({
    super.key,
    required this.className,
    required this.chapterNumber,
    required this.chapterName,
    this.subject = 'English',
  });

  final String className;
  final int chapterNumber;
  final String chapterName;
  final String subject;

  @override
  State<ChapterPdfViewerScreen> createState() => _ChapterPdfViewerScreenState();
}

class _ChapterPdfViewerScreenState extends State<ChapterPdfViewerScreen> {
  int _navIndex = 1;

  static const List<String> _pdfAssetCandidates = [
    'assets/resources/first_standard/english/chapter_1/two-little-hands.pdf',
    'assets/resources/first standard/english/chapter 1/two-little-hands.pdf',
  ];

  Future<Uint8List> _loadPdfBytes() async {
    for (final assetPath in _pdfAssetCandidates) {
      try {
        final byteData = await rootBundle.load(assetPath);
        return byteData.buffer.asUint8List();
      } catch (e) {
        debugPrint('[PdfViewer] Candidate $assetPath failed: $e');
      }
    }
    throw Exception('Could not find offline PDF asset.');
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTabletOrLarger(context);
    final horizontalPadding = isTablet ? 40.0 : 16.0;

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isTablet ? 12.0 : 8.0,
                ),
                child: _buildTopBar(isTablet),
              ),

              // Header Title Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildTitleBar(isTablet),
              ),

              const SizedBox(height: 12.0),

              // PDF Preview Area
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFBF7),
                        borderRadius: BorderRadius.circular(18.0),
                        border: Border.all(
                          color: const Color(0xFFE8DECF),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A4A3B32),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: PdfPreview(
                        build: (format) => _loadPdfBytes(),
                        canChangeOrientation: false,
                        canChangePageFormat: false,
                        canDebug: false,
                        dynamicLayout: false,
                        maxPageWidth: isTablet ? 760.0 : 540.0,
                        pdfFileName:
                            '${widget.chapterName.replaceAll(' ', '_')}_Reading_Material.pdf',
                        scrollViewDecoration: const BoxDecoration(
                          color: Color(0xFFF4ECE1),
                        ),
                        loadingWidget: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF671D21)),
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'Loading reading material...',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF765E49),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onError: (context, error) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: Color(0xFF671D21),
                                    size: 44.0,
                                  ),
                                  const SizedBox(height: 12.0),
                                  Text(
                                    'Error loading PDF: $error',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13.5,
                                      color: Color(0xFF251E11),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12.0),
            ],
          ),
        ),
        bottomNavigationBar: AyoBottomNavBar(
          selectedIndex: _navIndex,
          onItemSelected: (index) {
            if (index == 0) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else {
              setState(() => _navIndex = index);
            }
          },
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
              onTap: () => Navigator.of(context).maybePop(),
              borderRadius: BorderRadius.circular(20.0),
              splashColor: AppColors.primaryBurgundy.withValues(alpha: 0.12),
              child: Container(
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: const Color(0xFFE8DECF), width: 1.0),
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
        Center(
          child: AyoLogo(
            height: isTablet ? 90.0 : 70.0,
            assetPath: 'assets/images/ayovaani_logo.png',
          ),
        ),
      ],
    );
  }

  Widget _buildTitleBar(bool isTablet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBF7),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE8DECF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x064A3B32),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 18.0 : 14.0,
        vertical: isTablet ? 12.0 : 10.0,
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 42.0 : 36.0,
            height: isTablet ? 42.0 : 36.0,
            decoration: BoxDecoration(
              color: const Color(0xFF671D21),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Center(
              child: Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.white,
                size: 22.0,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.chapterName} - Reading Material',
                  style: TextStyle(
                    fontFamily: AppTypography.headingFontFamily,
                    fontSize: isTablet ? 18.0 : 15.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Chapter ${widget.chapterNumber} • Class ${widget.className} English',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF765E49),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE2EADF),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: const Color(0xFF526B4F), width: 1.0),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.offline_pin_rounded, size: 13.0, color: Color(0xFF526B4F)),
                SizedBox(width: 4.0),
                Text(
                  'Offline PDF',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF526B4F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
