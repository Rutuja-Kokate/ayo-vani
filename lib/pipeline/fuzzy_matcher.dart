import 'demo_cache_manager.dart';

class FuzzyMatchResult {
  final DemoCacheEntry? entry;
  final double score; // 0.0 to 1.0

  FuzzyMatchResult(this.entry, this.score);
}

class FuzzyMatcher {
  /// Finds the best matching entry from the corpus for a given Hindi speech text.
  /// Uses pre-tokenized Jaccard similarity for O(n) instead of O(n*m) matching.
  static FuzzyMatchResult findBestMatch(String spokenText, DemoCacheManager cacheManager, {double threshold = 0.4}) {
    if (!cacheManager.isInitialized || spokenText.trim().isEmpty) {
      return FuzzyMatchResult(null, 0.0);
    }

    final normalizedSpoken = _normalizeText(spokenText);
    if (normalizedSpoken.isEmpty) {
       return FuzzyMatchResult(null, 0.0);
    }
    final spokenTokens = normalizedSpoken.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toSet();

    DemoCacheEntry? bestMatch;
    double highestScore = 0.0;

    for (final entry in cacheManager.getAllEntries()) {
      // Use pre-tokenized tokens — avoids re-splitting every query
      final entryTokens = entry.hindiTokens;
      
      final intersection = spokenTokens.intersection(entryTokens).length;
      final union = spokenTokens.union(entryTokens).length;
      
      final score = union == 0 ? 0.0 : intersection / union;

      if (score > highestScore) {
        highestScore = score;
        bestMatch = entry;
      }
    }

    if (highestScore >= threshold) {
      return FuzzyMatchResult(bestMatch, highestScore);
    }

    return FuzzyMatchResult(null, highestScore);
  }

  static String _normalizeText(String text) {
    String normalized = text.toLowerCase();
    final charsToRemove = ['!', '?', '.', ',', '।', ':', ';', '"', "'"];
    for (final char in charsToRemove) {
      normalized = normalized.replaceAll(char, '');
    }
    return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
