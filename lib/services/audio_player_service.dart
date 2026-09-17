import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'speech_to_speech_service.dart';

class S2SAudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _currentSpeed = 1.0;

  S2SAudioPlayerService() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      debugPrint('[AudioPlayer] state: $state');
    });
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _currentSpeed = speed;
    await _audioPlayer.setPlaybackRate(speed);
  }

  /// Plays the translation result and completes the Future when playback finishes.
  Future<void> playTranslationResult(S2STranslationResult result) async {
    try {
      await stop(); // Ensure previous is stopped
      await _audioPlayer.setPlaybackRate(_currentSpeed);

      final completer = Completer<void>();

      // Listen for completion
      StreamSubscription? stateSub;
      stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          if (!completer.isCompleted) completer.complete();
          stateSub?.cancel();
        }
      });

      if (result.isCacheHit && result.audioPath != null) {
        String path = result.audioPath!;
        if (path.startsWith('assets/')) {
          path = path.substring(7);
        }
        debugPrint('[AudioPlayer] Playing asset: $path');
        await _audioPlayer.play(AssetSource(path));
      } else if (result.isRealTime && result.audioBytes != null) {
        debugPrint('[AudioPlayer] Playing from bytes (${result.audioBytes!.length} bytes)');
        await _audioPlayer.play(BytesSource(result.audioBytes!));
      } else {
        debugPrint('[AudioPlayer] No audio found in result');
        if (!completer.isCompleted) completer.complete();
      }

      // Wait for playback to actually finish
      await completer.future;

    } catch (e) {
      debugPrint('[AudioPlayer] Error playing audio: $e');
    }
  }

  Future<void> stop() => _audioPlayer.stop();
  Future<void> pause() => _audioPlayer.pause();
  Future<void> resume() => _audioPlayer.resume();

  void dispose() {
    _audioPlayer.dispose();
  }
}
