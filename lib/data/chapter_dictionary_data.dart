/// Dictionary data model and repository for Class 1 English Chapters.
///
/// Translations generated directly using the project's MtTranslationService
/// (English -> Mundari in Devanagari script).
library;

enum DictionaryCategory {
  all,
  actions,
  bodyParts,
}

extension DictionaryCategoryExtension on DictionaryCategory {
  String get label {
    switch (this) {
      case DictionaryCategory.all:
        return 'All';
      case DictionaryCategory.actions:
        return 'Actions';
      case DictionaryCategory.bodyParts:
        return 'Body Parts';
    }
  }
}

class DictionaryEntry {
  final String english;
  final String mundari;
  final DictionaryCategory category;
  final bool isAvailable;

  const DictionaryEntry({
    required this.english,
    required this.mundari,
    required this.category,
    this.isAvailable = true,
  });
}

class ChapterDictionaryData {
  /// Exactly 30 English -> Mundari words for First Standard English Chapter 1.
  /// Translations obtained using the project's MtTranslationService.
  static const List<DictionaryEntry> chapter1Entries = [
    // --- ACTIONS (15 Words) ---
    DictionaryEntry(
      english: 'Clap',
      mundari: 'रापुड़',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Tap',
      mundari: 'ठोक',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Walk',
      mundari: 'सेनोः',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Look',
      mundari: 'नेल',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Hear',
      mundari: 'अयूम',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Smell',
      mundari: 'सुंगुम',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Eat',
      mundari: 'जोम',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Talk',
      mundari: 'काजी',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Move',
      mundari: 'सरक',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'See',
      mundari: 'नेल',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Feel',
      mundari: 'अयूब',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Wash',
      mundari: 'होरा',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Open',
      mundari: 'उकुब',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Rub',
      mundari: 'रूबुड़',
      category: DictionaryCategory.actions,
    ),
    DictionaryEntry(
      english: 'Rinse',
      mundari: 'होरा',
      category: DictionaryCategory.actions,
    ),

    // --- BODY PARTS (15 Words) ---
    DictionaryEntry(
      english: 'Hand',
      mundari: 'तिः',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Leg',
      mundari: 'कटा',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Head',
      mundari: 'बोहः',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Eye',
      mundari: 'मेडः',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Ear',
      mundari: 'लुतुर',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Nose',
      mundari: 'मुं',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Mouth',
      mundari: 'चाबे',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Shoulder',
      mundari: 'तारन',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Knee',
      mundari: 'मुकुनी',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Toe',
      mundari: 'दारो',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Tongue',
      mundari: 'आलांग',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Arm',
      mundari: 'कीड़ी',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Foot',
      mundari: 'कटा',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Cheek',
      mundari: 'जोबा',
      category: DictionaryCategory.bodyParts,
    ),
    DictionaryEntry(
      english: 'Skin',
      mundari: 'उरु',
      category: DictionaryCategory.bodyParts,
    ),
  ];

  /// Returns dictionary entries for a given chapter.
  static List<DictionaryEntry> getEntriesForChapter(int chapterNumber) {
    if (chapterNumber == 1) {
      return chapter1Entries;
    }
    return [];
  }
}
