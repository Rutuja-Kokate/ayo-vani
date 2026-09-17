/// Data models and chapter-specific resources for Class 1 English.
library;

import 'package:flutter/material.dart';

/// Categories of learning resources available for a chapter.
enum ResourceCategory {
  all,
  lessonPlan,
  audioGuide,
  printable,
  teachingAid,
}

/// Model representing a single learning resource item.
class ChapterResourceItem {
  final String id;
  final String title;
  final String description;
  final ResourceCategory category;
  final String format; // e.g. "PDF", "AUDIO", "PRINTABLE"
  final String details; // e.g. "3 Pages • Offline Ready", "4 Mins • Offline Ready"
  final IconData icon;
  final Color accentColor;
  final List<String> keyPoints;

  const ChapterResourceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.format,
    required this.details,
    required this.icon,
    this.accentColor = const Color(0xFF3B5A82),
    this.keyPoints = const [],
  });
}

/// Central data repository providing chapter-specific resources for First Standard English.
abstract final class ChapterResourcesData {
  /// Chapter 1: Two Little Hands (Parts of Body)
  static const List<ChapterResourceItem> chapter1Resources = [
    ChapterResourceItem(
      id: 'c1_lesson_plan',
      title: 'Teacher Lesson Plan & Action Guide',
      description:
          'Structured pedagogical sequence for introducing body parts, TPR (Total Physical Response) gestures, and interactive classroom routines.',
      category: ResourceCategory.lessonPlan,
      format: 'PDF Guide',
      details: '3 Pages • Offline Ready',
      icon: Icons.menu_book_rounded,
      accentColor: Color(0xFF671D21), // Primary Burgundy
      keyPoints: [
        'Introduction through mirror play and body-touch actions',
        'Bilingual English-Mundari vocabulary reinforcement pairs',
        'Formative check-ins and non-verbal comprehension prompts',
      ],
    ),
    ChapterResourceItem(
      id: 'c1_audio_pronunciation',
      title: 'Bilingual Audio Pronunciation Guide',
      description:
          'Clear native voice prompts covering 10 key body parts with English terms followed by regional dialect pronunciation.',
      category: ResourceCategory.audioGuide,
      format: 'Audio Guide',
      details: '4 Mins • Offline Ready',
      icon: Icons.audiotrack_rounded,
      accentColor: Color(0xFFD49B2A), // Warm Golden Amber
      keyPoints: [
        'Slow-paced pronunciation repetitions for early learners',
        'Call-and-response rhythm suitable for whole-class chorus',
        'Offline audio playback for remote classroom sessions',
      ],
    ),
    ChapterResourceItem(
      id: 'c1_wall_chart',
      title: 'Classroom Body Parts Wall Chart',
      description:
          'High-contrast printable visual reference poster displaying labeled body parts for classroom display and group discussions.',
      category: ResourceCategory.printable,
      format: 'Printable Poster',
      details: '1 Page A4 • Offline Ready',
      icon: Icons.picture_as_pdf_rounded,
      accentColor: Color(0xFF3B5A82), // Slate Blue
      keyPoints: [
        'Clear bold typography suited for low-light classrooms',
        'Numbered indicator arrows pointing to hands, feet, eyes, and ears',
        'Reusable black & white printer-friendly format',
      ],
    ),
    ChapterResourceItem(
      id: 'c1_action_rhyme',
      title: 'Action Rhymes & Movement Prompts',
      description:
          'Classic action rhymes ("Two Little Hands", "Head, Shoulders, Knees") accompanied by physical movement suggestions for kinesthetic learning.',
      category: ResourceCategory.teachingAid,
      format: 'Teaching Aid',
      details: '2 Pages • Offline Ready',
      icon: Icons.accessibility_new_rounded,
      accentColor: Color(0xFF526B4F), // Olive Green
      keyPoints: [
        'Synchronized clapping, tapping, and nodding activities',
        'Bilingual verses bridging mother tongue and English',
        'Circle time energizer routines for morning assembly',
      ],
    ),
  ];

  /// Chapter 2: Life Around Us (Animals & Nature)
  static const List<ChapterResourceItem> chapter2Resources = [
    ChapterResourceItem(
      id: 'c2_nature_walk',
      title: 'Teacher Nature Walk Observation Guide',
      description:
          'Step-by-step facilitation prompts for leading an outdoor schoolyard nature walk to spot and name domestic animals and birds.',
      category: ResourceCategory.lessonPlan,
      format: 'PDF Guide',
      details: '3 Pages • Offline Ready',
      icon: Icons.nature_people_rounded,
      accentColor: Color(0xFF526B4F), // Olive Green
      keyPoints: [
        'Pre-walk safety and observational briefing prompts',
        'Inquiry questions: "What sound does it make? How does it move?"',
        'Post-walk reflection and blackboard drawing session',
      ],
    ),
    ChapterResourceItem(
      id: 'c2_animal_sounds',
      title: 'Animal Sounds & Audio Flash Guide',
      description:
          'Auditory reference featuring authentic sounds for cow, dog, bird, frog, and monkey paired with English animal names.',
      category: ResourceCategory.audioGuide,
      format: 'Audio Guide',
      details: '5 Mins • Offline Ready',
      icon: Icons.audiotrack_rounded,
      accentColor: Color(0xFFD49B2A), // Golden Amber
      keyPoints: [
        'Sound-to-word matching practice audio clips',
        'Interactive guessing game audio prompts for students',
        'Pronunciation support for animal names in English',
      ],
    ),
    ChapterResourceItem(
      id: 'c2_flashcard_grid',
      title: 'Printable Animal Picture Cards',
      description:
          'Grid of 8 printable animal cards designed for cutting out, desk sorting, and partner question-and-answer activities.',
      category: ResourceCategory.printable,
      format: 'Printable Cards',
      details: '2 Pages A4 • Offline Ready',
      icon: Icons.picture_as_pdf_rounded,
      accentColor: Color(0xFF3B5A82), // Slate Blue
      keyPoints: [
        'High-contrast animal line art ready for student coloring',
        'English names on front with phonetic helpers on back',
        'Compact pocket size for group rotation in small classrooms',
      ],
    ),
    ChapterResourceItem(
      id: 'c2_habitat_chart',
      title: 'Animals in Our Village Chart',
      description:
          'Contextual reference sheet classifying animals into village friends, farm helpers, and wild neighbors in local language context.',
      category: ResourceCategory.teachingAid,
      format: 'Teaching Aid',
      details: '2 Pages • Offline Ready',
      icon: Icons.pets_rounded,
      accentColor: Color(0xFFA85B4F), // Terracotta
      keyPoints: [
        'Cultural connections to tribal folklore and oral stories',
        'Sorting categories: "Lives near home" vs "Lives in trees"',
        'Vocabulary extensions for baby animal names',
      ],
    ),
  ];

  /// Chapter 3: The Food We Eat (Food & Nutrition)
  static const List<ChapterResourceItem> chapter3Resources = [
    ChapterResourceItem(
      id: 'c3_nutrition_manual',
      title: 'Teacher Nutrition & Food Discussion Manual',
      description:
          'Pedagogical framework for discussing everyday foods, local pulses, fruits, and mid-day meal vocabulary in English.',
      category: ResourceCategory.lessonPlan,
      format: 'PDF Guide',
      details: '3 Pages • Offline Ready',
      icon: Icons.restaurant_rounded,
      accentColor: Color(0xFF671D21), // Primary Burgundy
      keyPoints: [
        'Connecting mid-day meal ingredients to English vocabulary',
        'Simple questions: "What is your favorite fruit? What color is it?"',
        'Hygiene and handwashing reminders integrated into lesson',
      ],
    ),
    ChapterResourceItem(
      id: 'c3_meal_chants',
      title: 'Mealtime Rhymes & Rhythm Audio',
      description:
          'Audio collection of short cheerful eating songs and nursery chants celebrating healthy vegetables and daily meals.',
      category: ResourceCategory.audioGuide,
      format: 'Audio Guide',
      details: '4 Mins • Offline Ready',
      icon: Icons.audiotrack_rounded,
      accentColor: Color(0xFFD49B2A), // Golden Amber
      keyPoints: [
        'Catchy repetition rhymes easy for Class 1 learners to memorize',
        'Bilingual chorus segments reinforcing regional words',
        'Designed for pre-lunch singing and circle gatherings',
      ],
    ),
    ChapterResourceItem(
      id: 'c3_food_groups_chart',
      title: 'Healthy Plate Classroom Poster',
      description:
          'Printable balanced meal poster dividing food into grains (roti/rice), greens (saag), and fruits (mango/banana).',
      category: ResourceCategory.printable,
      format: 'Printable Poster',
      details: '1 Page A4 • Offline Ready',
      icon: Icons.picture_as_pdf_rounded,
      accentColor: Color(0xFF526B4F), // Olive Green
      keyPoints: [
        'Culturally authentic illustrations of local rural meals',
        'Color-coded categories matching nutrition guidelines',
        'Word labels in clear print font for emergent readers',
      ],
    ),
    ChapterResourceItem(
      id: 'c3_taste_vocab_sheet',
      title: 'Tastes & Textures Sensory Cards',
      description:
          'Tactile word cards exploring sweet, sour, salty, crunchy, and soft with everyday food examples from children\'s lives.',
      category: ResourceCategory.teachingAid,
      format: 'Teaching Aid',
      details: '2 Pages • Offline Ready',
      icon: Icons.fastfood_rounded,
      accentColor: Color(0xFF3B5A82), // Slate Blue
      keyPoints: [
        'Sensory exploration prompts: "Lemon is sour, Jaggery is sweet"',
        'Interactive classroom tasting activity guidelines',
        'Sentence frames: "I like to eat ____ because it is ____"',
      ],
    ),
  ];

  /// Returns the specific resources list for a given chapter number.
  static List<ChapterResourceItem> getResourcesForChapter(
    int chapterNumber,
    String chapterName,
  ) {
    switch (chapterNumber) {
      case 1:
        return chapter1Resources;
      case 2:
        return chapter2Resources;
      case 3:
        return chapter3Resources;
      default:
        // Contextual fallback for any other chapter
        return [
          ChapterResourceItem(
            id: 'c${chapterNumber}_guide',
            title: '$chapterName Teacher Reference Guide',
            description:
                'Comprehensive classroom guide with lesson objectives, conversation starters, and activities for $chapterName.',
            category: ResourceCategory.lessonPlan,
            format: 'PDF Guide',
            details: '3 Pages • Offline Ready',
            icon: Icons.menu_book_rounded,
            accentColor: const Color(0xFF671D21),
            keyPoints: [
              'Key pedagogical outcomes for $chapterName',
              'Classroom conversation prompts and vocabulary drills',
              'Student engagement ideas for rural classrooms',
            ],
          ),
          ChapterResourceItem(
            id: 'c${chapterNumber}_printable',
            title: '$chapterName Printable Worksheet Master',
            description:
                'Printable practice sheets and visual charts supporting foundational learning for $chapterName.',
            category: ResourceCategory.printable,
            format: 'Printable PDF',
            details: '2 Pages • Offline Ready',
            icon: Icons.picture_as_pdf_rounded,
            accentColor: const Color(0xFF3B5A82),
            keyPoints: [
              'Tracing and identification exercises',
              'Visual word association cards',
              'Take-home practice prompt sheet',
            ],
          ),
        ];
    }
  }
}
