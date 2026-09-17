import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Single visual/interactive item for Balvatika pre-school activities
class BalvatikaItem {
  final String id;
  final String nameEnglish;
  final String nameHindi;
  final String? nameTribalRoman;
  final String? nameTribalNative;
  final String emoji;
  final String? audioPathPlaceholder;
  final String? imagePathPlaceholder;
  final String? category;
  final String? extraDetail;

  const BalvatikaItem({
    required this.id,
    required this.nameEnglish,
    required this.nameHindi,
    this.nameTribalRoman,
    this.nameTribalNative,
    required this.emoji,
    this.audioPathPlaceholder,
    this.imagePathPlaceholder,
    this.category,
    this.extraDetail,
  });

  String getLocalizedName(BuildContext context) {
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    return isHindi ? nameHindi : nameEnglish;
  }

  String get tribalDisplay {
    if (nameTribalRoman != null && nameTribalNative != null) {
      return '( $nameTribalRoman / $nameTribalNative )';
    } else if (nameTribalRoman != null) {
      return '( $nameTribalRoman )';
    } else if (nameTribalNative != null) {
      return '( $nameTribalNative )';
    }
    return '';
  }
}

/// Representation of a story or nursery rhyme for audio playback
class BalvatikaRhymeStory {
  final String id;
  final String titleEnglish;
  final String titleHindi;
  final String? titleTribal;
  final String textEnglish;
  final String textHindi;
  final String? textTribal;
  final String moral;
  final String emoji;
  final String? audioPathPlaceholder;

  const BalvatikaRhymeStory({
    required this.id,
    required this.titleEnglish,
    required this.titleHindi,
    this.titleTribal,
    required this.textEnglish,
    required this.textHindi,
    this.textTribal,
    required this.moral,
    required this.emoji,
    this.audioPathPlaceholder,
  });

  String getLocalizedTitle(BuildContext context) {
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    return isHindi ? titleHindi : titleEnglish;
  }

  String getLocalizedText(BuildContext context) {
    final isHindi = Localizations.localeOf(context).languageCode == 'hi';
    return isHindi ? textHindi : textEnglish;
  }
}

/// Data structure for a topic/unit inside a Balvatika module
class BalvatikaTopicData {
  final String id;
  final String moduleId;
  final int topicNumber;
  final String titleKey;
  final String titleFallback;
  final String descKey;
  final String descFallback;
  final IconData icon;
  final String emoji;
  final List<BalvatikaItem> items;
  final List<BalvatikaRhymeStory> stories;

  const BalvatikaTopicData({
    required this.id,
    required this.moduleId,
    required this.topicNumber,
    required this.titleKey,
    required this.titleFallback,
    required this.descKey,
    required this.descFallback,
    required this.icon,
    required this.emoji,
    required this.items,
    this.stories = const [],
  });

  String getLocalizedTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return titleFallback;

    switch (titleKey) {
      case 'balvatikaTopicRhymesTitle':
        return l10n.balvatikaTopicRhymesTitle;
      case 'balvatikaTopicSoundsTitle':
        return l10n.balvatikaTopicSoundsTitle;
      case 'balvatikaTopicPictureWordsTitle':
        return l10n.balvatikaTopicPictureWordsTitle;
      case 'balvatikaTopicStoriesTitle':
        return l10n.balvatikaTopicStoriesTitle;
      case 'balvatikaTopicListenRepeatTitle':
        return l10n.balvatikaTopicListenRepeatTitle;
      case 'balvatikaTopicRhymingWordsTitle':
        return l10n.balvatikaTopicRhymingWordsTitle;

      case 'balvatikaTopicCountingTitle':
        return l10n.balvatikaTopicCountingTitle;
      case 'balvatikaTopicShapesTitle':
        return l10n.balvatikaTopicShapesTitle;
      case 'balvatikaTopicComparisonsTitle':
        return l10n.balvatikaTopicComparisonsTitle;
      case 'balvatikaTopicColorsTitle':
        return l10n.balvatikaTopicColorsTitle;
      case 'balvatikaTopicSortingTitle':
        return l10n.balvatikaTopicSortingTitle;
      case 'balvatikaTopicNumberRhymesTitle':
        return l10n.balvatikaTopicNumberRhymesTitle;

      case 'balvatikaTopicFiveSensesTitle':
        return l10n.balvatikaTopicFiveSensesTitle;
      case 'balvatikaTopicBodyPartsTitle':
        return l10n.balvatikaTopicBodyPartsTitle;
      case 'balvatikaTopicFamilyTitle':
        return l10n.balvatikaTopicFamilyTitle;
      case 'balvatikaTopicAnimalsTitle':
        return l10n.balvatikaTopicAnimalsTitle;
      case 'balvatikaTopicWeatherTitle':
        return l10n.balvatikaTopicWeatherTitle;
      case 'balvatikaTopicRolePlayTitle':
        return l10n.balvatikaTopicRolePlayTitle;

      default:
        return titleFallback;
    }
  }

  String getLocalizedDesc(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return descFallback;

    switch (descKey) {
      case 'balvatikaTopicRhymesDesc':
        return l10n.balvatikaTopicRhymesDesc;
      case 'balvatikaTopicSoundsDesc':
        return l10n.balvatikaTopicSoundsDesc;
      case 'balvatikaTopicPictureWordsDesc':
        return l10n.balvatikaTopicPictureWordsDesc;
      case 'balvatikaTopicStoriesDesc':
        return l10n.balvatikaTopicStoriesDesc;
      case 'balvatikaTopicListenRepeatDesc':
        return l10n.balvatikaTopicListenRepeatDesc;
      case 'balvatikaTopicRhymingWordsDesc':
        return l10n.balvatikaTopicRhymingWordsDesc;

      case 'balvatikaTopicCountingDesc':
        return l10n.balvatikaTopicCountingDesc;
      case 'balvatikaTopicShapesDesc':
        return l10n.balvatikaTopicShapesDesc;
      case 'balvatikaTopicComparisonsDesc':
        return l10n.balvatikaTopicComparisonsDesc;
      case 'balvatikaTopicColorsDesc':
        return l10n.balvatikaTopicColorsDesc;
      case 'balvatikaTopicSortingDesc':
        return l10n.balvatikaTopicSortingDesc;
      case 'balvatikaTopicNumberRhymesDesc':
        return l10n.balvatikaTopicNumberRhymesDesc;

      case 'balvatikaTopicFiveSensesDesc':
        return l10n.balvatikaTopicFiveSensesDesc;
      case 'balvatikaTopicBodyPartsDesc':
        return l10n.balvatikaTopicBodyPartsDesc;
      case 'balvatikaTopicFamilyDesc':
        return l10n.balvatikaTopicFamilyDesc;
      case 'balvatikaTopicAnimalsDesc':
        return l10n.balvatikaTopicAnimalsDesc;
      case 'balvatikaTopicWeatherDesc':
        return l10n.balvatikaTopicWeatherDesc;
      case 'balvatikaTopicRolePlayDesc':
        return l10n.balvatikaTopicRolePlayDesc;

      default:
        return descFallback;
    }
  }
}

/// Central repository for Balvatika pre-school module topics and items
class BalvatikaContentRepository {
  /// Module 1: Early Literacy & Rhymes topics
  static const List<BalvatikaTopicData> module1Topics = [
    BalvatikaTopicData(
      id: 'm1_rhymes',
      moduleId: 'literacy_bv',
      topicNumber: 1,
      titleKey: 'balvatikaTopicRhymesTitle',
      titleFallback: 'Nursery Rhymes & Lullabies',
      descKey: 'balvatikaTopicRhymesDesc',
      descFallback: 'Listen to rhymes in Hindi and regional languages with audio narration',
      icon: Icons.music_note_rounded,
      emoji: '🎵',
      items: [
        BalvatikaItem(
          id: 'rhyme_1',
          nameEnglish: 'Chanda Mama Door Ke',
          nameHindi: 'चंदा मामा दूर के',
          nameTribalRoman: 'Chandu Chanda',
          nameTribalNative: 'ଚାନ୍ଦୁ ଚାନ୍ଦା',
          emoji: '🌙',
          extraDetail: 'Traditional Moon Rhyme',
          audioPathPlaceholder: 'assets/demo_audio/rhyme_chanda.wav',
        ),
        BalvatikaItem(
          id: 'rhyme_2',
          nameEnglish: 'Machhli Jal Ki Rani Hai',
          nameHindi: 'मछली जल की रानी है',
          nameTribalRoman: 'Hai Dah Ren Rani',
          nameTribalNative: 'ହାଇ ଦାଃ ରେନ୍ ରାଣୀ',
          emoji: '🐟',
          extraDetail: 'Fish & Water Rhyme',
          audioPathPlaceholder: 'assets/demo_audio/rhyme_fish.wav',
        ),
      ],
      stories: [
        BalvatikaRhymeStory(
          id: 'story_1',
          titleEnglish: 'The Clever Rabbit and the Lion',
          titleHindi: 'चतुर खरगोश और शेर',
          titleTribal: 'Catur Kulai ado Kula',
          textEnglish: 'Once upon a time in a dense forest, a clever little rabbit outsmarted a fierce lion by showing him his own reflection in a deep well.',
          textHindi: 'एक घने जंगल में एक चतुर छोटे खरगोश ने एक गहरे कुएं में अपनी ही परछाई दिखाकर एक भयंकर शेर को हरा दिया।',
          moral: 'Wisdom is stronger than physical strength.',
          emoji: '🐰🦁',
          audioPathPlaceholder: 'assets/demo_audio/story_rabbit.wav',
        ),
      ],
    ),
    BalvatikaTopicData(
      id: 'm1_sounds',
      moduleId: 'literacy_bv',
      topicNumber: 2,
      titleKey: 'balvatikaTopicSoundsTitle',
      titleFallback: 'Animal & Nature Sounds',
      descKey: 'balvatikaTopicSoundsDesc',
      descFallback: 'Match pictures with animal and nature sounds (cow, dog, rain, wind)',
      icon: Icons.volume_up_rounded,
      emoji: '🔊',
      items: [
        BalvatikaItem(
          id: 'sound_cow',
          nameEnglish: 'Cow (Moo)',
          nameHindi: 'गाय (बां-बां)',
          nameTribalRoman: 'Gai (Moo)',
          nameTribalNative: 'ଗାଇ (ମୂ)',
          emoji: '🐄',
          extraDetail: 'Sound: Moo Moo',
        ),
        BalvatikaItem(
          id: 'sound_dog',
          nameEnglish: 'Dog (Woof)',
          nameHindi: 'कुत्ता (भौ-भौ)',
          nameTribalRoman: 'Setah (Woof)',
          nameTribalNative: 'ସେତାଃ (ୱୁଫ୍)',
          emoji: '🐕',
          extraDetail: 'Sound: Woof Woof',
        ),
        BalvatikaItem(
          id: 'sound_bird',
          nameEnglish: 'Bird (Chirp)',
          nameHindi: 'चिड़िया (चीं-चीं)',
          nameTribalRoman: 'Cere (Chirp)',
          nameTribalNative: 'ଚେରେ (ଚିर्ପ୍)',
          emoji: '🐦',
          extraDetail: 'Sound: Chirp Chirp',
        ),
        BalvatikaItem(
          id: 'sound_rain',
          nameEnglish: 'Rain (Pitter-Patter)',
          nameHindi: 'बारिश (छम-छम)',
          nameTribalRoman: 'Dah (Tip-Tip)',
          nameTribalNative: 'ଦାଃ (ଟିପ୍-ଟିପ୍)',
          emoji: '🌧️',
          extraDetail: 'Sound: Pitter Patter',
        ),
        BalvatikaItem(
          id: 'sound_wind',
          nameEnglish: 'Wind (Whoosh)',
          nameHindi: 'हवा (सायं-सायं)',
          nameTribalRoman: 'Hoyoi (Whoosh)',
          nameTribalNative: 'ହୋୟୋଈ (ୱୂଶ୍)',
          emoji: '🌬️',
          extraDetail: 'Sound: Whoosh',
        ),
      ],
    ),
    BalvatikaTopicData(
      id: 'm1_picture_words',
      moduleId: 'literacy_bv',
      topicNumber: 3,
      titleKey: 'balvatikaTopicPictureWordsTitle',
      titleFallback: 'Picture-Word Association',
      descKey: 'balvatikaTopicPictureWordsDesc',
      descFallback: 'Associate everyday objects with words in both Hindi and tribal languages',
      icon: Icons.image_search_rounded,
      emoji: '🖼️',
      items: [
        BalvatikaItem(
          id: 'word_mango',
          nameEnglish: 'Mango',
          nameHindi: 'आम',
          nameTribalRoman: 'Uli',
          nameTribalNative: 'ଉଲି',
          emoji: '🥭',
        ),
        BalvatikaItem(
          id: 'word_cow',
          nameEnglish: 'Cow',
          nameHindi: 'गाय',
          nameTribalRoman: 'Gai',
          nameTribalNative: 'ଗାଇ',
          emoji: '🐄',
        ),
        BalvatikaItem(
          id: 'word_sun',
          nameEnglish: 'Sun',
          nameHindi: 'सूरज',
          nameTribalRoman: 'Singi',
          nameTribalNative: 'ସିଂଗୀ',
          emoji: '☀️',
        ),
        BalvatikaItem(
          id: 'word_hut',
          nameEnglish: 'Hut',
          nameHindi: 'झोपड़ी',
          nameTribalRoman: 'Ora',
          nameTribalNative: 'ଓଡ଼ା',
          emoji: '🛖',
        ),
      ],
    ),
    BalvatikaTopicData(
      id: 'm1_stories',
      moduleId: 'literacy_bv',
      topicNumber: 4,
      titleKey: 'balvatikaTopicStoriesTitle',
      titleFallback: 'Oral Storytelling & Folklore',
      descKey: 'balvatikaTopicStoriesDesc',
      descFallback: 'Short 1-2 minute stories with repetition and simple moral lessons',
      icon: Icons.auto_stories_rounded,
      emoji: '📖',
      items: [],
      stories: [
        BalvatikaRhymeStory(
          id: 'story_crow',
          titleEnglish: 'The Thirsty Crow',
          titleHindi: 'प्यासा कौआ',
          titleTribal: 'Tetah Kan Kawa',
          textEnglish: 'A thirsty crow found a pitcher with very little water. He dropped small pebbles into the pitcher one by one until the water rose to the top and he drank happily.',
          textHindi: 'एक प्यासे कौवे को एक घड़ा मिला जिसमें बहुत कम पानी था। उसने एक-एक करके छोटे कंकड़ डाले जब तक पानी ऊपर नहीं आ गया।',
          moral: 'Where there is a will, there is a way.',
          emoji: '🦅🏺',
        ),
      ],
    ),
    BalvatikaTopicData(
      id: 'm1_listen_repeat',
      moduleId: 'literacy_bv',
      topicNumber: 5,
      titleKey: 'balvatikaTopicListenRepeatTitle',
      titleFallback: 'Listen & Repeat Practice',
      descKey: 'balvatikaTopicListenRepeatDesc',
      descFallback: 'Audio prompt exercises for children to repeat and practice pronunciation',
      icon: Icons.mic_rounded,
      emoji: '🗣️',
      items: [
        BalvatikaItem(
          id: 'lr_1',
          nameEnglish: 'Namaste',
          nameHindi: 'नमस्ते',
          nameTribalRoman: 'Johar',
          nameTribalNative: 'ଜୋହାର୍',
          emoji: '🙏',
        ),
        BalvatikaItem(
          id: 'lr_2',
          nameEnglish: 'Water',
          nameHindi: 'पानी',
          nameTribalRoman: 'Dah',
          nameTribalNative: 'ଦାଃ',
          emoji: '💧',
        ),
        BalvatikaItem(
          id: 'lr_3',
          nameEnglish: 'Tree',
          nameHindi: 'पेड़',
          nameTribalRoman: 'Daru',
          nameTribalNative: 'ଦାରୁ',
          emoji: '🌳',
        ),
      ],
    ),
    BalvatikaTopicData(
      id: 'm1_rhyming_words',
      moduleId: 'literacy_bv',
      topicNumber: 6,
      titleKey: 'balvatikaTopicRhymingWordsTitle',
      titleFallback: 'Simple Rhyming Words',
      descKey: 'balvatikaTopicRhymingWordsDesc',
      descFallback: 'Fun rhyming word pairs in Hindi and regional tribal languages',
      icon: Icons.phonelink_ring_rounded,
      emoji: '🔤',
      items: [
        BalvatikaItem(
          id: 'rhyme_pair_1',
          nameEnglish: 'Lock & Garland',
          nameHindi: 'ताला - माला',
          nameTribalRoman: 'Taala - Maala',
          nameTribalNative: 'ତାଲା - ମାଲା',
          emoji: '🔒💐',
        ),
        BalvatikaItem(
          id: 'rhyme_pair_2',
          nameEnglish: 'King & Musical Band',
          nameHindi: 'राजा - बाजा',
          nameTribalRoman: 'Raja - Baaja',
          nameTribalNative: 'ରାଜା - ବାଜା',
          emoji: '👑🥁',
        ),
      ],
    ),
  ];

  /// Module 2: Early Numeracy & Shapes topics
  static const List<BalvatikaTopicData> module2Topics = [
    BalvatikaTopicData(
      id: 'm2_counting',
      moduleId: 'numeracy_bv',
      topicNumber: 1,
      titleKey: 'balvatikaTopicCountingTitle',
      titleFallback: 'Counting 1 to 10',
      descKey: 'balvatikaTopicCountingDesc',
      descFallback: 'Count 1–10 using fingers, fruits, stones, and local objects',
      icon: Icons.filter_1_rounded,
      emoji: '🔢',
      items: [
        BalvatikaItem(id: 'c1', nameEnglish: 'One', nameHindi: 'एक', nameTribalRoman: 'Miyad', nameTribalNative: 'ମିଆଦ୍', emoji: '☝️', extraDetail: '1 Finger'),
        BalvatikaItem(id: 'c2', nameEnglish: 'Two', nameHindi: 'दो', nameTribalRoman: 'Baria', nameTribalNative: 'ବାରିଆ', emoji: '✌️', extraDetail: '2 Apples'),
        BalvatikaItem(id: 'c3', nameEnglish: 'Three', nameHindi: 'तीन', nameTribalRoman: 'Apia', nameTribalNative: 'ଆପିଆ', emoji: '☘️', extraDetail: '3 Leaves'),
        BalvatikaItem(id: 'c4', nameEnglish: 'Four', nameHindi: 'चार', nameTribalRoman: 'Upunia', nameTribalNative: 'ଉପୁନିଆ', emoji: '🍀', extraDetail: '4 Stones'),
        BalvatikaItem(id: 'c5', nameEnglish: 'Five', nameHindi: 'पाँच', nameTribalRoman: 'Moyad', nameTribalNative: 'ମୋୟାଦ୍', emoji: '🖐️', extraDetail: '5 Fingers'),
      ],
    ),
    BalvatikaTopicData(
      id: 'm2_shapes',
      moduleId: 'numeracy_bv',
      topicNumber: 2,
      titleKey: 'balvatikaTopicShapesTitle',
      titleFallback: 'Shapes in Everyday Objects',
      descKey: 'balvatikaTopicShapesDesc',
      descFallback: 'Recognize circle (roti), square (window), and triangle (roof)',
      icon: Icons.category_rounded,
      emoji: '⚪',
      items: [
        BalvatikaItem(id: 'sh_circle', nameEnglish: 'Circle (Roti)', nameHindi: 'गोल (रोटी)', nameTribalRoman: 'Gol (Lad)', nameTribalNative: 'ଗୋଲ୍ (ଲାଦ)', emoji: '🫓', extraDetail: 'Roti is round/circle'),
        BalvatikaItem(id: 'sh_square', nameEnglish: 'Square (Window)', nameHindi: 'चौकोर (खिड़की)', nameTribalRoman: 'Chaukor (Khirki)', nameTribalNative: 'ଚୌକୋର (ଖିଡ଼କି)', emoji: '🪟', extraDetail: 'Window is square'),
        BalvatikaItem(id: 'sh_triangle', nameEnglish: 'Triangle (Roof)', nameHindi: 'त्रिकोण (छत)', nameTribalRoman: 'Trikon (Chhat)', nameTribalNative: 'ତ୍ରିକୋଣ (ଛତ)', emoji: '🏠', extraDetail: 'Roof is triangle'),
      ],
    ),
    BalvatikaTopicData(
      id: 'm2_comparisons',
      moduleId: 'numeracy_bv',
      topicNumber: 3,
      titleKey: 'balvatikaTopicComparisonsTitle',
      titleFallback: 'Big/Small & More/Less',
      descKey: 'balvatikaTopicComparisonsDesc',
      descFallback: 'Compare sizes and quantities using visual object cards',
      icon: Icons.aspect_ratio_rounded,
      emoji: '🐘🐭',
      items: [
        BalvatikaItem(id: 'comp_big_small', nameEnglish: 'Elephant (Big) vs Rabbit (Small)', nameHindi: 'हाथी (बड़ा) बनाम खरगोश (छोटा)', nameTribalRoman: 'Hati (Marang) - Kulai (Huding)', nameTribalNative: 'ହାତୀ (ମାରାଂ) - କୁଲାଇ (ହୁଡିଂ)', emoji: '🐘🐰'),
        BalvatikaItem(id: 'comp_more_less', nameEnglish: 'Basket of Fruits (More vs Less)', nameHindi: 'फलों की टोकरी (अधिक बनाम कम)', nameTribalRoman: 'Jo Baska (Pura vs Huding)', nameTribalNative: 'ଜୋ ବାସ୍କା (ପୁରା vs ହୁଡିଂ)', emoji: '🧺🍎'),
      ],
    ),
    BalvatikaTopicData(
      id: 'm2_colors',
      moduleId: 'numeracy_bv',
      topicNumber: 4,
      titleKey: 'balvatikaTopicColorsTitle',
      titleFallback: 'Primary Colors & Nature',
      descKey: 'balvatikaTopicColorsDesc',
      descFallback: 'Recognize red, yellow, blue, and green through fruits and flowers',
      icon: Icons.palette_rounded,
      emoji: '🎨',
      items: [
        BalvatikaItem(id: 'col_red', nameEnglish: 'Red (Apple)', nameHindi: 'लाल (सेब)', nameTribalRoman: 'Ara (Seb)', nameTribalNative: 'ଆରା (ସେବ)', emoji: '🍎'),
        BalvatikaItem(id: 'col_yellow', nameEnglish: 'Yellow (Sunflower)', nameHindi: 'पीला (सूरजमुखी)', nameTribalRoman: 'Sasang (Baha)', nameTribalNative: 'ଶାସାଂ (ବାହା)', emoji: '🌻'),
        BalvatikaItem(id: 'col_green', nameEnglish: 'Green (Leaf)', nameHindi: 'हरा (पत्ता)', nameTribalRoman: 'Hariyar (Sakam)', nameTribalNative: 'ହାରିୟାର୍ (ସାକାମ୍)', emoji: '🍃'),
        BalvatikaItem(id: 'col_blue', nameEnglish: 'Blue (Sky)', nameHindi: 'नीला (आकाश)', nameTribalRoman: 'Lil (Sirma)', nameTribalNative: 'ଲୀଲ୍ (ସିର୍ମା)', emoji: '🌤️'),
      ],
    ),
    BalvatikaTopicData(
      id: 'm2_sorting',
      moduleId: 'numeracy_bv',
      topicNumber: 5,
      titleKey: 'balvatikaTopicSortingTitle',
      titleFallback: 'Sorting & Grouping',
      descKey: 'balvatikaTopicSortingDesc',
      descFallback: 'Group objects by shape, size, or color',
      icon: Icons.dashboard_customize_rounded,
      emoji: '📦',
      items: [
        BalvatikaItem(id: 'sort_fruits', nameEnglish: 'Sort Red & Yellow Fruits', nameHindi: 'लाल और पीले फलों को छांटें', nameTribalRoman: 'Ara ado Sasang Jo', nameTribalNative: 'ଆରା ଆଡ଼ୋ ଶାସାଂ ଜୋ', emoji: '🍎🍌'),
      ],
    ),
    BalvatikaTopicData(
      id: 'm2_number_rhymes',
      moduleId: 'numeracy_bv',
      topicNumber: 6,
      titleKey: 'balvatikaTopicNumberRhymesTitle',
      titleFallback: 'Number Rhymes & Songs',
      descKey: 'balvatikaTopicNumberRhymesDesc',
      descFallback: 'Catchy counting songs and number rhymes in regional languages',
      icon: Icons.audiotrack_rounded,
      emoji: '🎶',
      items: [
        BalvatikaItem(id: 'num_song_1', nameEnglish: 'One Two, Buckle My Shoe', nameHindi: 'एक दो कभी न रो', nameTribalRoman: 'Miyad Baria Johar', nameTribalNative: 'ମିଆଦ୍ ବାରିଆ ଜୋହାର୍', emoji: '🔢🎵'),
      ],
    ),
  ];

  /// Module 3: Sensory & World Play topics
  static const List<BalvatikaTopicData> module3Topics = [
    BalvatikaTopicData(
      id: 'm3_senses',
      moduleId: 'discovery_bv',
      topicNumber: 1,
      titleKey: 'balvatikaTopicFiveSensesTitle',
      titleFallback: 'Five Senses Exploration',
      descKey: 'balvatikaTopicFiveSensesDesc',
      descFallback: 'Explore touch, smell, taste, sound, and sight with everyday items',
      icon: Icons.touch_app_rounded,
      emoji: '🖐️',
      items: [
        BalvatikaItem(id: 'sense_touch', nameEnglish: 'Touch (Rough vs Smooth)', nameHindi: 'स्पर्श (खुरदरा बनाम चिकना)', nameTribalRoman: 'Uru (Harta)', nameTribalNative: 'ଉରୁ (ହର୍ତା)', emoji: '🖐️🪨'),
        BalvatikaItem(id: 'sense_smell', nameEnglish: 'Smell (Sweet Flower)', nameHindi: 'सूंघना (मीठा फूल)', nameTribalRoman: 'Muhu (Sibil Baha)', nameTribalNative: 'ମୁହୁ (ସିବିଲ୍ ବାହା)', emoji: '👃🌸'),
        BalvatikaItem(id: 'sense_taste', nameEnglish: 'Taste (Sweet Mango)', nameHindi: 'स्वाद (मीठा आम)', nameTribalRoman: 'Alang (Sibil Uli)', nameTribalNative: 'ଆଲାଙ୍ଗ (ସିବିଲ୍ ଉଲି)', emoji: '👅🥭'),
        BalvatikaItem(id: 'sense_sound', nameEnglish: 'Sound (Drum Beat)', nameHindi: 'सुनना (ढोलक की थाप)', nameTribalRoman: 'Lutur (Dholak)', nameTribalNative: 'ଲୁତୁର (ଢୋଲକ)', emoji: '👂🥁'),
        BalvatikaItem(id: 'sense_sight', nameEnglish: 'Sight (Bright Sun)', nameHindi: 'देखना (चमकता सूरज)', nameTribalRoman: 'Med (Singi)', nameTribalNative: 'ମେଦ୍ (ସିଂଗୀ)', emoji: '👁️☀️'),
      ],
    ),
    BalvatikaTopicData(
      id: 'm3_body',
      moduleId: 'discovery_bv',
      topicNumber: 2,
      titleKey: 'balvatikaTopicBodyPartsTitle',
      titleFallback: 'My Body Parts',
      descKey: 'balvatikaTopicBodyPartsDesc',
      descFallback: 'Name and identify body parts through songs, visuals, and audio games',
      icon: Icons.accessibility_new_rounded,
      emoji: '🙋‍♂️',
      items: [
        BalvatikaItem(id: 'body_head', nameEnglish: 'Head', nameHindi: 'सिर', nameTribalRoman: 'Boo', nameTribalNative: 'ବୋ', emoji: '🗣️'),
        BalvatikaItem(id: 'body_hand', nameEnglish: 'Hand', nameHindi: 'हाथ', nameTribalRoman: 'Tii', nameTribalNative: 'ତୀ', emoji: '✋'),
        BalvatikaItem(id: 'body_leg', nameEnglish: 'Leg', nameHindi: 'पैर', nameTribalRoman: 'Kata', nameTribalNative: 'କଟା', emoji: '🦵'),
        BalvatikaItem(id: 'body_eye', nameEnglish: 'Eye', nameHindi: 'आंख', nameTribalRoman: 'Med', nameTribalNative: 'ମେଦ୍', emoji: '👁️'),
      ],
    ),
    BalvatikaTopicData(
      id: 'm3_family',
      moduleId: 'discovery_bv',
      topicNumber: 3,
      titleKey: 'balvatikaTopicFamilyTitle',
      titleFallback: 'Family & Relationships',
      descKey: 'balvatikaTopicFamilyDesc',
      descFallback: 'Learn names for Mother, Father, Brother, Sister in both languages',
      icon: Icons.family_restroom_rounded,
      emoji: '👨‍👩‍👧‍👦',
      items: [
        BalvatikaItem(id: 'fam_mother', nameEnglish: 'Mother', nameHindi: 'माँ', nameTribalRoman: 'Ayo / Enga', nameTribalNative: 'ଆୟୋ / ଏଙ୍ଗା', emoji: '👩'),
        BalvatikaItem(id: 'fam_father', nameEnglish: 'Father', nameHindi: 'पिता', nameTribalRoman: 'Aba / Appa', nameTribalNative: 'ଆବା / ଆପ୍ପା', emoji: '👨'),
        BalvatikaItem(id: 'fam_brother', nameEnglish: 'Brother', nameHindi: 'भाई', nameTribalRoman: 'Babu', nameTribalNative: 'ବାବୁ', emoji: '👦'),
        BalvatikaItem(id: 'fam_sister', nameEnglish: 'Sister', nameHindi: 'बहन', nameTribalRoman: 'Dai', nameTribalNative: 'ଦାଈ', emoji: '👧'),
      ],
    ),
    BalvatikaTopicData(
      id: 'm3_animals',
      moduleId: 'discovery_bv',
      topicNumber: 4,
      titleKey: 'balvatikaTopicAnimalsTitle',
      titleFallback: 'Animals Around Us',
      descKey: 'balvatikaTopicAnimalsDesc',
      descFallback: 'Farm and forest animals, their names, habitats, and sounds',
      icon: Icons.pets_rounded,
      emoji: '🐾',
      items: [
        BalvatikaItem(id: 'anim_cow', nameEnglish: 'Cow', nameHindi: 'गाय', nameTribalRoman: 'Gai', nameTribalNative: 'ଗାଇ', emoji: '🐄'),
        BalvatikaItem(id: 'anim_goat', nameEnglish: 'Goat', nameHindi: 'बकरी', nameTribalRoman: 'Merom', nameTribalNative: 'ମେରୋମ୍', emoji: '🐐'),
        BalvatikaItem(id: 'anim_lion', nameEnglish: 'Lion', nameHindi: 'शेर', nameTribalRoman: 'Kula', nameTribalNative: 'କୁଲା', emoji: '🦁'),
        BalvatikaItem(id: 'anim_monkey', nameEnglish: 'Monkey', nameHindi: 'बंदर', nameTribalRoman: 'Gadhi', nameTribalNative: 'ଗାଢ଼ି', emoji: '🐒'),
      ],
    ),
    BalvatikaTopicData(
      id: 'm3_weather',
      moduleId: 'discovery_bv',
      topicNumber: 5,
      titleKey: 'balvatikaTopicWeatherTitle',
      titleFallback: 'Weather & Seasons',
      descKey: 'balvatikaTopicWeatherDesc',
      descFallback: 'Daily weather observations (sunny, rainy, cold) and nature play',
      icon: Icons.wb_sunny_rounded,
      emoji: '🌤️',
      items: [
        BalvatikaItem(id: 'weath_sunny', nameEnglish: 'Sunny / Heat', nameHindi: 'धूप / गर्मी', nameTribalRoman: 'Singi / Garm', nameTribalNative: 'ସିଂଗୀ / ଗର୍ମ୍', emoji: '☀️'),
        BalvatikaItem(id: 'weath_rainy', nameEnglish: 'Rainy', nameHindi: 'बारिश', nameTribalRoman: 'Dah Jaram', nameTribalNative: 'ଦାଃ ଜାରାମ୍', emoji: '🌧️'),
        BalvatikaItem(id: 'weath_cold', nameEnglish: 'Cold / Winter', nameHindi: 'सर्दी / ठंड', nameTribalRoman: 'Rabang', nameTribalNative: 'ରାବାଂ', emoji: '❄️'),
      ],
    ),
    BalvatikaTopicData(
      id: 'm3_roleplay',
      moduleId: 'discovery_bv',
      topicNumber: 6,
      titleKey: 'balvatikaTopicRolePlayTitle',
      titleFallback: 'Role Play & Daily Life',
      descKey: 'balvatikaTopicRolePlayDesc',
      descFallback: 'Simple scenarios: cooking, farming, and visiting the local market',
      icon: Icons.theater_comedy_rounded,
      emoji: '🎭',
      items: [
        BalvatikaItem(id: 'rp_cooking', nameEnglish: 'Cooking Food', nameHindi: 'खाना पकाना', nameTribalRoman: 'Mandi Isin', nameTribalNative: 'ମାଣ୍ଡି ଇସିନ୍', emoji: '🍲'),
        BalvatikaItem(id: 'rp_farming', nameEnglish: 'Farming in Fields', nameHindi: 'खेतों में खेती', nameTribalRoman: 'Chas Kam', nameTribalNative: 'ଚାସ୍ କାମ୍', emoji: '👨‍🌾'),
        BalvatikaItem(id: 'rp_market', nameEnglish: 'Local Village Market', nameHindi: 'स्थानीय गाँव का हाट', nameTribalRoman: 'Pitha / Hat', nameTribalNative: 'ପିଠା / ହାଟ୍', emoji: '🏪'),
      ],
    ),
  ];

  /// Returns topic list for a given module ID
  static List<BalvatikaTopicData> getTopicsForModule(String moduleId) {
    switch (moduleId) {
      case 'literacy_bv':
        return module1Topics;
      case 'numeracy_bv':
        return module2Topics;
      case 'discovery_bv':
        return module3Topics;
      default:
        return module1Topics;
    }
  }
}
