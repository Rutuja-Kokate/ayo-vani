library;

/// TTS Text Front-End Contract for Mundari TTS.
///
/// EVIDENCE AND SYMBOL SET FINDINGS:
/// ─────────────────────────────────────────────────────────────────────────────
/// Inspection of assets/models/tts/mundari.onnx.json:
///   - "phoneme_type": "espeak"
///   - "espeak": { "voice": "hi" }
///   - "piper_version": "1.3.0"
///
/// Inspection of assets/models/tts/tokens.txt:
///   - Contains 161 token entries (indices 0..160).
///   - Includes standard punctuation (_ ^ $ ! ' ( ) , - . : ; ?), Latin letters (a-z),
///     and International Phonetic Alphabet (IPA) phonemes:
///     æ, ç, ð, ø, ħ, ŋ, œ, ɐ, ɑ, ɒ, ɓ, ɔ, ɕ, ɖ, ɗ, ɘ, ə, ɚ, ɛ, ɜ, ɞ, ɟ, ɠ, ɡ, ɢ, ɣ, ɤ,
///     ɥ, ɦ, ɧ, ɨ, ɪ, ɫ, ɬ, ɭ, ɮ, ɯ, ɰ, ɱ, ɲ, ɳ, ɴ, ɵ, ɶ, ɸ, ɹ, ɺ, ɻ, ɽ, ɾ, ʀ, ʁ, ʂ, ʃ,
///     ʄ, ʈ, ʉ, ʊ, ʋ, ʌ, ʍ, ʎ, ʏ, ʐ, ʑ, ʒ, ʔ, ʕ, ʘ, ʙ, ʛ, ʜ, ʝ, ʟ, ʡ, ʢ, ʲ, ˈ, ˌ, ː, ˑ,
///     ˞, β, θ, χ, ᵻ, ⱱ, plus diacritics.
///   - There are ZERO Odia characters (U+0B00-0B7F) in tokens.txt.
///
/// CONCLUSION:
/// The Mundari VITS model consumes espeak IPA phonemes via Piper phoneme ID mapping.
/// When configured in Sherpa-ONNX with `dataDir` pointing to `espeak-ng-data`, the engine
/// uses the embedded espeak-ng Hindi voice ("hi") to convert Devanagari text directly into
/// IPA phonemes on-device.
///
/// Therefore, the correct path is:
/// 1. Replace any English classroom loanwords with Devanagari equivalents (via loanwords.dart).
/// 2. Clean up redundant whitespace, normalize punctuation and Devanagari nuktas.
/// 3. Pass Devanagari straight to Sherpa-ONNX TTS with `dataDir` configured.
///
/// CRITICAL NOTE: A HUMAN LISTENING TEST IS STILL REQUIRED to verify pronunciation accuracy
/// in real classroom environments.
/// ─────────────────────────────────────────────────────────────────────────────

import 'loanwords.dart';

/// Prepares and normalizes Mundari text in Devanagari script for on-device TTS synthesis.
///
/// Replaces English loanwords with Devanagari phonetics, strips unpronounceable symbols,
/// normalizes whitespace, and returns the normalized Devanagari text ready for espeak-ng phonemization.
String prepareTtsText(String devanagariMundari) {
  if (devanagariMundari.trim().isEmpty) return '';

  // 1. Substitute English classroom loanwords with Devanagari phonetics
  String processed = replaceLoanwords(devanagariMundari);

  // 2. Normalize Devanagari punctuation and symbols
  // Replace pipe / danda with pause punctuation
  processed = processed
      .replaceAll('।', '.')
      .replaceAll('॥', '.')
      .replaceAll(';', ',')
      .replaceAll('—', ', ')
      .replaceAll('–', ', ');

  // 3. Remove characters that are neither Devanagari, Latin, digits, nor standard punctuation
  // Keeps Devanagari range U+0900-U+097F, ASCII word chars, whitespace, and basic punctuation.
  processed = processed.replaceAll(
      RegExp(r'[^\u0900-\u097Fa-zA-Z0-9\s.,!?-]'), ' ');

  // 4. Normalize multiple whitespaces and trim
  processed = processed.replaceAll(RegExp(r'\s+'), ' ').trim();

  return processed;
}
