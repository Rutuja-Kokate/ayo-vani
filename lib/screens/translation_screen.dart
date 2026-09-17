import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/speech_to_speech_service.dart';
import '../services/audio_player_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  String _hindiText = "Press translate to start...";
  String _mundariText = "";
  bool _cacheHit = false;
  int _latencyMs = 0;
  bool _isTranslating = false;

  Future<void> _performTranslation(String audioFilePath) async {
    final s2stService = context.read<SpeechToSpeechService>();
    final audioPlayer = context.read<S2SAudioPlayerService>();
    
    setState(() {
      _isTranslating = true;
    });

    try {
      // Get translation (with cache check built-in)
      final result = await s2stService.translateSpeech(
        audioFilePath: audioFilePath,
      );
      
      // Play audio (handles both asset and byte sources)
      await audioPlayer.playTranslationResult(result);
      
      if (mounted) {
        setState(() {
          _hindiText = result.hindiText;
          _mundariText = result.mundariText;
          _cacheHit = result.isCacheHit;
          _latencyMs = result.latencyMs;
        });
        
        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isCacheHit 
                ? '✓ Cache hit! (${result.latencyMs}ms)'
                : '⚠ Real-time (${result.latencyMs}ms)',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hindi → Mundari Translation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display Hindi text
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hindi:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(_hindiText, style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Display Mundari text
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Mundari:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        if (_cacheHit)
                          Chip(
                            label: const Text('Cache Hit', style: TextStyle(color: Colors.green)),
                            backgroundColor: Colors.green.shade50,
                            padding: EdgeInsets.zero,
                          )
                        else if (_mundariText.isNotEmpty)
                          Chip(
                            label: Text('Real-time (${_latencyMs}ms)', style: const TextStyle(color: Colors.orange)),
                            backgroundColor: Colors.orange.shade50,
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_mundariText, style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            
            // Translate / Audio playback button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: _isTranslating ? null : () => _performTranslation("dummy_path.wav"),
              icon: _isTranslating 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.mic),
              label: Text(_isTranslating ? 'Translating...' : 'Translate & Play'),
            ),
          ],
        ),
      ),
    );
  }
}
