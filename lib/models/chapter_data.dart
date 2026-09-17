import 'package:flutter/material.dart';

/// Data model representing dynamic chapter content across all classes
/// (Balvatika, First, Second, Third) in AYOVAANI.
class ChapterData {
  const ChapterData({
    required this.className,
    required this.chapterNumber,
    required this.chapterName,
    required this.chapterDescription,
    required this.topic,
    required this.lesson,
    this.icon = Icons.menu_book_rounded,
    this.chapterEmoji,
    this.chapterImage,
  });

  /// The class/grade name (e.g. "Balvatika", "First", "Second", "Third").
  final String className;

  /// The chapter sequence number (e.g. 1, 2, 3, 5, 8).
  final int chapterNumber;

  /// The chapter title (e.g. "Fruits and Colors", "Numbers Around Us").
  final String chapterName;

  /// Short description / encouragement phrase.
  final String chapterDescription;

  /// Main syllabus topic (e.g. "Fruits & colors.").
  final String topic;

  /// Learning lesson objective (e.g. "Basic vocabulary.").
  final String lesson;

  /// Associated educational icon.
  final IconData icon;

  /// Optional contextual emoji (e.g. "🍎🍇" for fruits).
  final String? chapterEmoji;

  /// Optional asset image path.
  final String? chapterImage;
}

/// Central repository providing curriculum metadata for any chapter across all classes.
abstract final class ChapterRepository {
  /// Returns localized contextual topic string for a given class and chapter.
  static String getLocalizedTopic(BuildContext context, String className, int chapterNumber, String title) {
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('fruit') || lowerTitle.contains('color')) {
      return isHindi ? 'फल एवं रंग।' : 'Fruits & colors.';
    }
    if (lowerTitle.contains('hand') || lowerTitle.contains('body') || lowerTitle.contains('myself')) {
      return isHindi ? 'शरीर के अंग व परिचय।' : 'Body parts & self.';
    }
    if (lowerTitle.contains('animal') || lowerTitle.contains('life') || lowerTitle.contains('pet')) {
      return isHindi ? 'हमारे आसपास के जीव जन्तु।' : 'Animals & nature around us.';
    }
    if (lowerTitle.contains('food') || lowerTitle.contains('eat')) {
      return isHindi ? 'हमारा खान-पान व पोषण।' : 'Food & nutrition.';
    }
    if (lowerTitle.contains('number') || lowerTitle.contains('count')) {
      return isHindi ? 'संख्याएं व गिनती।' : 'Numerals & counting.';
    }
    return isHindi ? '$title विषय' : '$title concepts.';
  }

  /// Returns localized contextual lesson string for a given class and chapter.
  static String getLocalizedLesson(BuildContext context, String className, int chapterNumber, String title) {
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('fruit') || lowerTitle.contains('color')) {
      return isHindi ? 'बुनियादी शब्दावली।' : 'Basic vocabulary.';
    }
    if (lowerTitle.contains('hand') || lowerTitle.contains('body')) {
      return isHindi ? 'मौखिक संवाद व पहचान।' : 'Expressive dialogue.';
    }
    if (lowerTitle.contains('animal') || lowerTitle.contains('life')) {
      return isHindi ? 'जानवरों के नाम व आवाज़ें।' : 'Animal sounds & terms.';
    }
    if (lowerTitle.contains('food')) {
      return isHindi ? 'दैनिक खान-पान के शब्द।' : 'Daily dietary words.';
    }
    return isHindi ? 'बुनियादी कौशल।' : 'Core foundational skills.';
  }

  /// Returns contextual topic string for a given class and chapter.
  static String getTopic(String className, int chapterNumber, String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('fruit') || lowerTitle.contains('color')) {
      return 'Fruits & colors.';
    }
    if (lowerTitle.contains('myself') || lowerTitle.contains('world') || lowerTitle.contains('community')) {
      return 'Self & identity.';
    }
    if (lowerTitle.contains('family')) {
      return 'Family & relationships.';
    }
    if (lowerTitle.contains('number') || lowerTitle.contains('count')) {
      return 'Numerals & counting.';
    }
    if (lowerTitle.contains('add') || lowerTitle.contains('sub')) {
      return 'Basic arithmetic operations.';
    }
    if (lowerTitle.contains('animal') || lowerTitle.contains('pet') || lowerTitle.contains('bird')) {
      return 'Fauna & domestic animals.';
    }
    if (lowerTitle.contains('plant') || lowerTitle.contains('tree') || lowerTitle.contains('nature') || lowerTitle.contains('forest')) {
      return 'Flora & surrounding nature.';
    }
    if (lowerTitle.contains('shape') || lowerTitle.contains('pattern') || lowerTitle.contains('size')) {
      return 'Geometry & visual patterns.';
    }
    if (lowerTitle.contains('food') || lowerTitle.contains('health')) {
      return 'Nutrition & healthy foods.';
    }
    if (lowerTitle.contains('cloth')) {
      return 'Attire & seasonal clothing.';
    }
    if (lowerTitle.contains('school')) {
      return 'Classroom objects & school.';
    }
    if (lowerTitle.contains('body')) {
      return 'Human anatomy & senses.';
    }
    if (lowerTitle.contains('water') || lowerTitle.contains('air') || lowerTitle.contains('weather') || lowerTitle.contains('season')) {
      return 'Climate, seasons & environment.';
    }
    if (lowerTitle.contains('story') || lowerTitle.contains('song') || lowerTitle.contains('rhyme') || lowerTitle.contains('tales')) {
      return 'Folklore, rhymes & oral heritage.';
    }
    if (lowerTitle.contains('helper') || lowerTitle.contains('travel') || lowerTitle.contains('transport')) {
      return 'Community & vehicles.';
    }

    return '$title concepts.';
  }

  /// Returns contextual lesson string for a given class and chapter.
  static String getLesson(String className, int chapterNumber, String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('fruit') || lowerTitle.contains('color')) {
      return 'Basic vocabulary.';
    }
    if (lowerTitle.contains('myself') || lowerTitle.contains('body')) {
      return 'Expressive dialogue.';
    }
    if (lowerTitle.contains('family') || lowerTitle.contains('school')) {
      return 'Social vocabulary.';
    }
    if (lowerTitle.contains('number') || lowerTitle.contains('count')) {
      return 'Oral counting & quantity.';
    }
    if (lowerTitle.contains('add') || lowerTitle.contains('sub')) {
      return 'Everyday problem solving.';
    }
    if (lowerTitle.contains('animal') || lowerTitle.contains('bird')) {
      return 'Animal sounds & terms.';
    }
    if (lowerTitle.contains('plant') || lowerTitle.contains('nature')) {
      return 'Environmental observation.';
    }
    if (lowerTitle.contains('shape') || lowerTitle.contains('pattern')) {
      return 'Spatial recognition.';
    }
    if (lowerTitle.contains('food')) {
      return 'Daily dietary words.';
    }
    if (lowerTitle.contains('story') || lowerTitle.contains('song')) {
      return 'Listening comprehension.';
    }

    return 'Core foundational skills.';
  }

  /// Returns contextual emoji indicator for a given chapter title.
  static String? getEmoji(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('fruit') || lowerTitle.contains('color')) {
      return '🍎🍇';
    }
    if (lowerTitle.contains('number') || lowerTitle.contains('count') || lowerTitle.contains('add')) {
      return '🔢';
    }
    if (lowerTitle.contains('animal') || lowerTitle.contains('pet') || lowerTitle.contains('bird')) {
      return '🐾';
    }
    if (lowerTitle.contains('nature') || lowerTitle.contains('plant') || lowerTitle.contains('tree')) {
      return '🌿';
    }
    if (lowerTitle.contains('family') || lowerTitle.contains('myself')) {
      return '👨‍👩‍👧';
    }
    if (lowerTitle.contains('school')) {
      return '🏫';
    }
    if (lowerTitle.contains('food')) {
      return '🍲';
    }
    if (lowerTitle.contains('story') || lowerTitle.contains('song')) {
      return '📖';
    }
    if (lowerTitle.contains('shape')) {
      return '🔷';
    }
    return null;
  }
}
