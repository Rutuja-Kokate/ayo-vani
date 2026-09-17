import 'package:flutter_test/flutter_test.dart';
import 'package:ayo_vani/services/tts_service.dart';

void main() {
  group('TtsService Devanagari to Phonemes Transliteration', () {
    test('transliterates Mundari Devanagari words correctly to Latin phonemes', () {
      expect(TtsService.devanagariToPhonemes('जोमोनू'), equals('jomonu'));
      expect(TtsService.devanagariToPhonemes('नमस्ते'), equals('namaste'));
      expect(TtsService.devanagariToPhonemes('हिजुःमे'), equals('hijuhme'));
      expect(TtsService.devanagariToPhonemes('जोहाड़'), equals('johar'));
      expect(TtsService.devanagariToPhonemes('दुब मे'), equals('dub me'));
      expect(TtsService.devanagariToPhonemes('कजिलेम'), equals('kajilem'));
      expect(TtsService.devanagariToPhonemes('नेरे ओलेमे'), equals('nere oleme'));
    });

    test('preserves English/Latin words without alteration', () {
      expect(TtsService.devanagariToPhonemes('jomonu'), equals('jomonu'));
      expect(TtsService.devanagariToPhonemes('Hello world'), equals('hello world'));
    });
  });
}
