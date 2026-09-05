import 'package:flutter/material.dart';

/// Represents an educational subject in the curriculum for a class.
class Subject {
  const Subject({
    required this.id,
    required this.name,
    this.hindiName,
    required this.icon,
    this.isAvailable = false,
    this.badgeText,
    this.description,
    this.totalChapters = 12,
  });

  /// Unique identifier (e.g. 'english', 'hindi', 'maths', 'evs').
  final String id;

  /// Display name of the subject (e.g. 'English', 'Mathematics').
  final String name;

  /// Regional/Hindi script title (e.g. 'अंग्रेज़ी', 'गणित').
  final String? hindiName;

  /// Associated subject icon.
  final IconData icon;

  /// Whether this subject is fully functional in the current MVP scope.
  final bool isAvailable;

  /// Status badge label (defaults to "Available" or "Coming Soon").
  final String? badgeText;

  /// Short subject synopsis or chapter overview.
  final String? description;

  /// Number of chapters in curriculum.
  final int totalChapters;

  /// Class 1 / First standard curriculum subjects.
  /// Only English is available in the current prototype scope.
  static const List<Subject> class1Subjects = [
    Subject(
      id: 'english',
      name: 'English',
      hindiName: 'अंग्रेज़ी',
      icon: Icons.auto_stories_rounded,
      isAvailable: true,
      badgeText: 'Available',
      description: '12 interactive lessons • Flashcards, worksheets, games & quizzes',
      totalChapters: 12,
    ),
    Subject(
      id: 'hindi',
      name: 'Hindi',
      hindiName: 'हिन्दी',
      icon: Icons.translate_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Foundational Hindi language modules in development',
      totalChapters: 12,
    ),
    Subject(
      id: 'maths',
      name: 'Mathematics',
      hindiName: 'गणित',
      icon: Icons.calculate_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Numbers, shapes, and early arithmetic concepts',
      totalChapters: 12,
    ),
    Subject(
      id: 'evs',
      name: 'Environmental Studies',
      hindiName: 'पर्यावरण',
      icon: Icons.park_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Nature, community, and living surroundings',
      totalChapters: 12,
    ),
  ];

  /// Class 2 subjects - All Coming Soon in the current MVP scope.
  static const List<Subject> class2Subjects = [
    Subject(
      id: 'english_c2',
      name: 'English',
      hindiName: 'अंग्रेज़ी',
      icon: Icons.auto_stories_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Grade 2 English reading, listening, and vocabulary',
      totalChapters: 12,
    ),
    Subject(
      id: 'hindi_c2',
      name: 'Hindi',
      hindiName: 'हिन्दी',
      icon: Icons.translate_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Grade 2 stories, poetry, and linguistic practice',
      totalChapters: 12,
    ),
    Subject(
      id: 'maths_c2',
      name: 'Mathematics',
      hindiName: 'गणित',
      icon: Icons.calculate_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Two-digit operations, patterns, and measurement',
      totalChapters: 12,
    ),
    Subject(
      id: 'evs_c2',
      name: 'Environmental Studies',
      hindiName: 'पर्यावरण',
      icon: Icons.park_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Habitats, community workers, and our planet',
      totalChapters: 12,
    ),
  ];

  /// Class 3 subjects - All Coming Soon in the current MVP scope.
  static const List<Subject> class3Subjects = [
    Subject(
      id: 'english_c3',
      name: 'English',
      hindiName: 'अंग्रेज़ी',
      icon: Icons.auto_stories_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Grade 3 comprehensive reading and grammar',
      totalChapters: 12,
    ),
    Subject(
      id: 'hindi_c3',
      name: 'Hindi',
      hindiName: 'हिन्दी',
      icon: Icons.translate_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Grade 3 literature, expression, and writing',
      totalChapters: 12,
    ),
    Subject(
      id: 'maths_c3',
      name: 'Mathematics',
      hindiName: 'गणित',
      icon: Icons.calculate_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Multiplication, division, and spatial geometry',
      totalChapters: 12,
    ),
    Subject(
      id: 'evs_c3',
      name: 'Environmental Studies',
      hindiName: 'पर्यावरण',
      icon: Icons.park_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Science, community systems, and regional biodiversity',
      totalChapters: 12,
    ),
  ];

  /// Balvatika foundation modules - All Coming Soon in the current MVP scope.
  static const List<Subject> balvatikaSubjects = [
    Subject(
      id: 'literacy_bv',
      name: 'Early Literacy & Rhymes',
      hindiName: 'आरंभिक भाषा व गीत',
      icon: Icons.record_voice_over_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Oral storytelling, picture reading & tribal rhymes',
      totalChapters: 12,
    ),
    Subject(
      id: 'numeracy_bv',
      name: 'Early Numeracy & Shapes',
      hindiName: 'आरंभिक गणित व आकृतियाँ',
      icon: Icons.format_list_numbered_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Counting 1–10, object sorting & color identification',
      totalChapters: 12,
    ),
    Subject(
      id: 'discovery_bv',
      name: 'Sensory & World Play',
      hindiName: 'पर्यावरण व खेल',
      icon: Icons.palette_rounded,
      isAvailable: false,
      badgeText: 'Coming Soon',
      description: 'Nature exploration, body senses & creative arts',
      totalChapters: 12,
    ),
  ];
}
