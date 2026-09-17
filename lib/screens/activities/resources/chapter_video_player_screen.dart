import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../app/responsive/responsive.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_typography.dart';
import '../../../widgets/ayo_bottom_nav_bar.dart';
import '../../../widgets/ayo_logo.dart';
import '../../../widgets/ayo_screen_background.dart';

/// Screen: In-app offline video player for Chapter 1 Resources.
class ChapterVideoPlayerScreen extends StatefulWidget {
  const ChapterVideoPlayerScreen({
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
  State<ChapterVideoPlayerScreen> createState() =>
      _ChapterVideoPlayerScreenState();
}

class _ChapterVideoPlayerScreenState extends State<ChapterVideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  int _navIndex = 1;

  static const String _primaryVideoAsset =
      'assets/resources/first_standard/english/chapter_1/2lh-video.mp4';

  static const List<String> _videoAssetCandidates = [
    _primaryVideoAsset,
    'assets/resources/first standard/english/chapter 1/2lh video.mp4',
    'assets/resources/first standard/english/chapter 1/2lh-video.mp4',
    'assets/resources/first_standard/english/chapter_1/2lh video.mp4',
  ];

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _isInitialized = false;
    });

    Object? lastError;
    for (final assetPath in _videoAssetCandidates) {
      try {
        debugPrint('[VideoPlayer] Attempting to load: $assetPath');
        final controller = VideoPlayerController.asset(assetPath);
        await controller.initialize();
        if (!mounted) {
          controller.dispose();
          return;
        }
        setState(() {
          _controller = controller;
          _isInitialized = true;
        });
        controller.addListener(_videoListener);
        controller.play();
        debugPrint('[VideoPlayer] Successfully initialized: $assetPath');
        return;
      } catch (e, stackTrace) {
        lastError = e;
        debugPrint('[VideoPlayer] Candidate $assetPath failed: $e\n$stackTrace');
      }
    }

    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Could not load bundled video asset offline.';
      });
      debugPrint('[VideoPlayer] All candidates failed. Last error: $lastError');
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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

              // Title & Info Bar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildTitleBar(isTablet),
              ),

              const SizedBox(height: 12.0),

              // Video Player Area
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 840.0 : double.infinity,
                      ),
                      child: _buildVideoContent(isTablet),
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
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 24.0,
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
                  '${widget.chapterName} - Video',
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
                  'Offline Asset',
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

  Widget _buildVideoContent(bool isTablet) {
    if (_hasError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFBF7),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: const Color(0xFFE8DECF), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFF671D21),
              size: 48.0,
            ),
            const SizedBox(height: 12.0),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.0,
                color: Color(0xFF251E11),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _initializeVideoPlayer,
              icon: const Icon(Icons.refresh_rounded, size: 18.0),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF671D21),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFDFBF7),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: const Color(0xFFE8DECF), width: 1.5),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF671D21)),
            ),
            SizedBox(height: 16.0),
            Text(
              'Loading video...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF765E49),
              ),
            ),
          ],
        ),
      );
    }

    final controller = _controller!;
    final position = controller.value.position;
    final duration = controller.value.duration;
    final isPlaying = controller.value.isPlaying;
    final isEnded = position >= duration && duration > Duration.zero;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF251E11),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Video View
          Flexible(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio > 0
                  ? controller.value.aspectRatio
                  : 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(controller),
                  if (!isPlaying && !isEnded)
                    GestureDetector(
                      onTap: () => controller.play(),
                      child: Container(
                        width: 64.0,
                        height: 64.0,
                        decoration: BoxDecoration(
                          color: const Color(0x99000000),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 2.0),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 40.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Control Bar
          Container(
            color: const Color(0xFF1E1710),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress Indicator
                VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Color(0xFFC95A2B),
                    bufferedColor: Color(0x66D8C6AC),
                    backgroundColor: Color(0x33FFFFFF),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                ),

                const SizedBox(height: 6.0),

                // Controls Row
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isEnded
                            ? Icons.replay_rounded
                            : (isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded),
                        color: Colors.white,
                        size: 26.0,
                      ),
                      onPressed: () {
                        if (isEnded) {
                          controller.seekTo(Duration.zero);
                          controller.play();
                        } else if (isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      },
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      '${_formatDuration(position)} / ${_formatDuration(duration)}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.0,
                        color: Color(0xFFE8DECF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.replay_10_rounded,
                        color: Colors.white70,
                        size: 22.0,
                      ),
                      onPressed: () {
                        final newPos = position - const Duration(seconds: 10);
                        controller.seekTo(
                            newPos < Duration.zero ? Duration.zero : newPos);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.forward_10_rounded,
                        color: Colors.white70,
                        size: 22.0,
                      ),
                      onPressed: () {
                        final newPos = position + const Duration(seconds: 10);
                        controller.seekTo(
                            newPos > duration ? duration : newPos);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
