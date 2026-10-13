/// Single source of truth for English classroom loanwords mapped to Devanagari phonetics.
/// Used by TTS text front-ends and pipeline normalization.
const Map<String, String> kLoanwordPhoneticMap = {
  'notebook': 'नोटबुक',
  'chapter': 'चैप्टर',
  'page': 'पेज',
  'board': 'बोर्ड',
  'quiz': 'क्विज़',
  'team': 'टीम',
  'pencil': 'पेंसिल',
  'book': 'बुक',
  'teacher': 'टीचर',
  'warm-up': 'वार्म-अप',
  'introduction': 'परिचय',
  'practice': 'अभ्यास',
  'unit': 'यूनिट',
  'class': 'क्लास',
  'lesson': 'लेसन',
  'student': 'स्टूडेंट',
  'school': 'स्कूल',
  'section': 'सेक्शन',
};

/// Transliterates an English word into approximate phonetic Devanagari script.
/// Used as a rule-based fallback when a loanword is not in [kLoanwordPhoneticMap].
String transliterateEnglishToDevanagari(String text) {
  final clean = text.trim();
  if (clean.isEmpty) return clean;
  // If already contains Devanagari characters, return as-is
  if (RegExp(r'[\u0900-\u097F]').hasMatch(clean)) {
    return clean;
  }

  final lower = clean.toLowerCase();
  final buffer = StringBuffer();
  int i = 0;
  bool isPreviousConsonant = false;

  const digraphs = {
    'sh': 'श',
    'ch': 'च',
    'th': 'थ',
    'ph': 'फ',
    'kh': 'ख',
    'gh': 'घ',
    'jh': 'झ',
    'bh': 'भ',
    'dh': 'ध',
    'ee': 'ी',
    'oo': 'ू',
    'ai': 'ै',
    'ay': 'े',
    'au': 'ौ',
    'ou': 'ौ',
    'ck': 'क',
    'ng': 'ंग',
  };

  const consonants = {
    'b': 'ब',
    'c': 'क',
    'd': 'ड',
    'f': 'फ़',
    'g': 'ग',
    'h': 'ह',
    'j': 'ज',
    'k': 'क',
    'l': 'ल',
    'm': 'म',
    'n': 'न',
    'p': 'प',
    'q': 'क',
    'r': 'र',
    's': 'स',
    't': 'ट',
    'v': 'व',
    'w': 'व',
    'x': 'क्स',
    'y': 'य',
    'z': 'ज़',
  };

  const independentVowels = {
    'a': 'आ',
    'e': 'ए',
    'i': 'इ',
    'o': 'ओ',
    'u': 'उ',
  };

  const matras = {
    'a': 'ा',
    'e': 'े',
    'i': 'ि',
    'o': 'ो',
    'u': 'ु',
  };

  while (i < lower.length) {
    if (i + 1 < lower.length) {
      final two = lower.substring(i, i + 2);
      if (digraphs.containsKey(two)) {
        buffer.write(digraphs[two]);
        isPreviousConsonant = !two.startsWith('e') && !two.startsWith('o') && !two.startsWith('a');
        i += 2;
        continue;
      }
    }

    final char = lower[i];
    if (consonants.containsKey(char)) {
      buffer.write(consonants[char]);
      isPreviousConsonant = true;
    } else if (matras.containsKey(char)) {
      if (isPreviousConsonant) {
        if (char == 'e' && i == lower.length - 1 && lower.length > 2) {
          // Suppress silent terminal 'e'
        } else {
          buffer.write(matras[char]);
        }
      } else {
        buffer.write(independentVowels[char] ?? char);
      }
      isPreviousConsonant = false;
    } else {
      buffer.write(char);
      isPreviousConsonant = false;
    }
    i++;
  }

  return buffer.toString();
}

/// Returns the Devanagari transliteration of an English loanword [term].
/// First checks [kLoanwordPhoneticMap], then falls back to [transliterateEnglishToDevanagari].
String getLoanwordDevanagari(String term) {
  final clean = term.trim();
  if (clean.isEmpty) return clean;
  final lower = clean.toLowerCase();
  if (kLoanwordPhoneticMap.containsKey(lower)) {
    return kLoanwordPhoneticMap[lower]!;
  }
  return transliterateEnglishToDevanagari(clean);
}

/// Replaces English loanwords in [text] with their Devanagari phonetic equivalents.
String replaceLoanwords(String text) {
  if (text.isEmpty) return text;
  String result = text;
  kLoanwordPhoneticMap.forEach((englishWord, devanagariWord) {
    final pattern = RegExp('\\b${RegExp.escape(englishWord)}\\b', caseSensitive: false);
    result = result.replaceAll(pattern, devanagariWord);
  });
  return result;
}
