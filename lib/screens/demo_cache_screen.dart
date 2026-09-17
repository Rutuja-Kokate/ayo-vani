import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pipeline/demo_cache_manager.dart';
import '../services/speech_to_speech_service.dart';
import '../services/audio_player_service.dart';


class DemoCacheScreen extends StatefulWidget {
  const DemoCacheScreen({super.key});

  @override
  State<DemoCacheScreen> createState() => _DemoCacheScreenState();
}

class _DemoCacheScreenState extends State<DemoCacheScreen> {
  List<DemoCacheEntry> _entries = [];
  bool _isPlaying = false;
  int? _playingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEntries();
    });
  }

  void _loadEntries() {
    final cacheManager = context.read<DemoCacheManager>();
    setState(() {
      _entries = cacheManager.getAllEntries();
    });
  }

  Future<void> _playEntry(DemoCacheEntry entry) async {
    final audioPlayer = context.read<S2SAudioPlayerService>();

    setState(() {
      _isPlaying = true;
      _playingId = entry.id;
    });

    try {
      // Force cache hit by passing the exact Hindi string
      // In a real app, STT would return this string.
      // We simulate STT bypassing by just querying the cache manager
      
      final result = S2STranslationResult(
        hindiText: entry.hindi,
        mundariText: entry.mundariOdia,
        audioPath: 'assets/demo_audio/${entry.audioFilename}',
        source: TranslationSource.demoCache,
        latencyMs: 15,
        cacheEntryId: entry.id,
      );

      await audioPlayer.playTranslationResult(result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playingId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cacheManager = context.watch<DemoCacheManager>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Cache Tester'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Analytics section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard('Total Cached', cacheManager.totalSentences.toString()),
                _StatCard('Cache Status', cacheManager.isInitialized ? 'Active' : 'Offline'),
                _StatCard('Avg Latency', '~50ms'),
              ],
            ),
          ),
          
          Expanded(
            child: _entries.isEmpty 
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final isCurrentlyPlaying = _isPlaying && _playingId == entry.id;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.shade100,
                          child: Text('${entry.id}'),
                        ),
                        title: Text(entry.hindi, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Mundari: ${entry.mundariOdia}', style: TextStyle(color: Colors.grey.shade700)),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isCurrentlyPlaying ? Icons.stop_circle : Icons.play_circle_fill, 
                            color: Colors.teal,
                            size: 36,
                          ),
                          onPressed: isCurrentlyPlaying 
                            ? () => context.read<S2SAudioPlayerService>().stop()
                            : () => _playEntry(entry),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
