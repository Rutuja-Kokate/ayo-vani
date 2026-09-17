import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';

class DemoCacheEntry {
  final int id;
  final String hindi;
  final String mundariDevanagari;
  final String mundariOdia;
  final String audioFilename;
  final String? english;
  // Pre-tokenized set for O(1) fuzzy matching
  late final Set<String> hindiTokens;

  String get mundariText => mundariDevanagari;

  DemoCacheEntry({
    required this.id,
    required this.hindi,
    required this.mundariDevanagari,
    required this.mundariOdia,
    required this.audioFilename,
    this.english,
  }) {
    hindiTokens = _tokenize(hindi);
  }

  factory DemoCacheEntry.fromJson(Map<String, dynamic> json) {
    final devText = (json['mundari_devanagari'] as String?) ?? (json['mundari_odia'] as String? ?? '');
    return DemoCacheEntry(
      id: json['id'] as int,
      hindi: json['hindi'] as String,
      mundariDevanagari: devText,
      mundariOdia: devText,
      audioFilename: json['audio_file'] as String? ?? 'mundari_demo_${json['id'].toString().padLeft(3, '0')}.wav',
      english: json['english'] as String?,
    );
  }

  static Set<String> _tokenize(String text) {
    String normalized = text.toLowerCase();
    for (final char in ['!', '?', '.', ',', '।', ':', ';', '"', "'"]) {
      normalized = normalized.replaceAll(char, '');
    }
    return normalized.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toSet();
  }
}

class DemoCacheManager {
  // Singleton
  static final DemoCacheManager _instance = DemoCacheManager._internal();
  factory DemoCacheManager() => _instance;
  DemoCacheManager._internal();
  
  bool _isInitialized = false;
  final List<DemoCacheEntry> _entries = [];
  final Map<String, DemoCacheEntry> _hindiIndex = {};
  final Map<int, DemoCacheEntry> _idIndex = {};

  bool get isInitialized => _isInitialized;
  int get totalSentences => _entries.length;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final jsonString = await rootBundle.loadString('assets/demo_corpus_100_sentences.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final corpus = jsonData['demo_corpus'] as List<dynamic>? ?? [];

      for (var item in corpus) {
        final entry = DemoCacheEntry.fromJson(item as Map<String, dynamic>);
        _entries.add(entry);
        
        // Exact match by Hindi text, trimmed
        _hindiIndex[entry.hindi.trim().toLowerCase()] = entry;
        _idIndex[entry.id] = entry;
      }
      
      _isInitialized = true;
      debugPrint('[DemoCache] ✓ Demo cache loaded: ${_entries.length} sentences');
    } catch (e) {
      debugPrint('[DemoCache] Error loading demo corpus: $e');
    }
  }

  DemoCacheEntry? findByHindiText(String hindiText) {
    if (!_isInitialized) return null;
    return _hindiIndex[hindiText.trim().toLowerCase()];
  }

  DemoCacheEntry? findById(int id) {
    if (!_isInitialized) return null;
    return _idIndex[id];
  }

  List<DemoCacheEntry> getAllEntries() {
    return List.unmodifiable(_entries);
  }

  List<DemoCacheEntry> getFirst(int count) {
    if (!_isInitialized || _entries.isEmpty) return [];
    return _entries.take(count).toList();
  }

  List<DemoCacheEntry> searchByHindiPrefix(String prefix) {
    if (!_isInitialized || prefix.isEmpty) return [];
    final lowerPrefix = prefix.trim().toLowerCase();
    return _entries.where((e) => e.hindi.toLowerCase().startsWith(lowerPrefix)).toList();
  }

  String getAudioAssetPath(DemoCacheEntry entry) {
    return 'assets/demo_audio/${entry.audioFilename}';
  }

  Future<bool> audioFileExists(DemoCacheEntry entry) async {
    try {
      await rootBundle.load(getAudioAssetPath(entry));
      return true;
    } catch (_) {
      return false;
    }
  }
}

