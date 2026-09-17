/// Hardcoded English-Mundari vocabulary and quiz data for Class 1 English prototype.
/// Devanagari script for Mundari language.
library;

const Map<String, String> worksheetLabels = {
  'AYOVAANI Classroom Worksheet': 'आयोवाणी श्रेणी कार्यपत्र',
  'Name:': 'नुतुम:',
  'Date:': 'तिति:',
  'Exercise: Trace and write the words below': 'अभ्यास: निचेत शब्द को त्रेस ओड़ोः ओला मे',
  'Exercise 1: Draw lines to match each picture to its sentence': 'अभ्यास १: छवि ओड़ोः जगर मिला लागि रेखा ताण मे',
  'Exercise 2: Fun with Words - Read the syllables': 'अभ्यास २: शब्द रा रसिका - वर्णांश पढ़ मे',
  'Exercise: Read the riddles and write the answers below': 'अभ्यास: दाये पढ़ ओड़ोः जाबाब ओला मे',
  'Answer:': 'जाबाब:',
  'Exercise: Circle the odd one out in each row below': 'अभ्यास: धाड़ि रे अलग गोल कर मे',
};

class EnglishMundariWord {
  final String english;
  final String mundariRoman;
  final String mundariDevanagari;
  final String meaning;
  final String pronunciation;
  final String emoji;
  final List<String> syllables;

  const EnglishMundariWord({
    required this.english,
    required this.mundariRoman,
    required this.mundariDevanagari,
    required this.meaning,
    required this.pronunciation,
    required this.emoji,
    required this.syllables,
  });

  /// Alias for backward compatibility
  String get mundariOdia => mundariDevanagari;

  /// Combined formatted display string e.g. "( Tii / ती )"
  String get mundariDisplay => '( $mundariRoman / $mundariDevanagari )';
}

class EnglishQuizQuestion {
  final String question;
  final String questionDevanagari;
  final List<String> options;
  final List<String> optionsDevanagari;
  final int correctIndex;
  final String explanation;

  const EnglishQuizQuestion({
    required this.question,
    required this.questionDevanagari,
    required this.options,
    required this.optionsDevanagari,
    required this.correctIndex,
    required this.explanation,
  });

  /// Aliases for backward compatibility
  String get questionOdia => questionDevanagari;
  List<String> get optionsOdia => optionsDevanagari;
}

class BilingualSentence {
  final String englishSentence;
  final String mundariRoman;
  final String mundariDevanagari;
  final String relatedWord;

  const BilingualSentence({
    required this.englishSentence,
    required this.mundariRoman,
    required this.mundariDevanagari,
    required this.relatedWord,
  });

  /// Alias for backward compatibility
  String get mundariOdia => mundariDevanagari;
}

class BilingualRiddle {
  final String englishRiddle;
  final String mundariRoman;
  final String mundariDevanagari;
  final String answerEnglish;
  final String answerMundariRoman;
  final String answerMundariDevanagari;

  const BilingualRiddle({
    required this.englishRiddle,
    required this.mundariRoman,
    required this.mundariDevanagari,
    required this.answerEnglish,
    required this.answerMundariRoman,
    required this.answerMundariDevanagari,
  });

  /// Aliases for backward compatibility
  String get mundariOdia => mundariDevanagari;
  String get answerMundariOdia => answerMundariDevanagari;
}

class EnglishActivitiesData {
  /// Map of English chapter title to vocabulary list
  static const Map<String, List<EnglishMundariWord>> chapterWords = {
    'Two Little Hands': [
      EnglishMundariWord(
        english: 'Hand',
        mundariRoman: 'Tii',
        mundariDevanagari: 'ती',
        meaning: 'Used to hold, write, and clap.',
        pronunciation: 'hand',
        emoji: '✋',
        syllables: ['Hand'],
      ),
      EnglishMundariWord(
        english: 'Leg',
        mundariRoman: 'Kata',
        mundariDevanagari: 'कटा',
        meaning: 'Used to walk and run.',
        pronunciation: 'leg',
        emoji: '🦵',
        syllables: ['Leg'],
      ),
      EnglishMundariWord(
        english: 'Head',
        mundariRoman: 'Boo',
        mundariDevanagari: 'बो',
        meaning: 'Top part of body with hair and brain.',
        pronunciation: 'hed',
        emoji: '🗣️',
        syllables: ['Head'],
      ),
      EnglishMundariWord(
        english: 'Eye',
        mundariRoman: 'Med',
        mundariDevanagari: 'मेद',
        meaning: 'Used to see colors and shapes.',
        pronunciation: 'ai',
        emoji: '👁️',
        syllables: ['Eye'],
      ),
      EnglishMundariWord(
        english: 'Ear',
        mundariRoman: 'Lutur',
        mundariDevanagari: 'लुतुर',
        meaning: 'Used to hear sounds and music.',
        pronunciation: 'eer',
        emoji: '👂',
        syllables: ['Ear'],
      ),
      EnglishMundariWord(
        english: 'Nose',
        mundariRoman: 'Muhu',
        mundariDevanagari: 'मुहु',
        meaning: 'Used to smell flowers and food.',
        pronunciation: 'nohz',
        emoji: '👃',
        syllables: ['Nose'],
      ),
      EnglishMundariWord(
        english: 'Mouth',
        mundariRoman: 'Moca',
        mundariDevanagari: 'मोचा',
        meaning: 'Used to speak and eat food.',
        pronunciation: 'mowth',
        emoji: '👄',
        syllables: ['Mouth'],
      ),
      EnglishMundariWord(
        english: 'Skin',
        mundariRoman: 'Uru',
        mundariDevanagari: 'उरु',
        meaning: 'Covers body and feels touch.',
        pronunciation: 'skin',
        emoji: '🖐️',
        syllables: ['Skin'],
      ),
      EnglishMundariWord(
        english: 'Arm',
        mundariRoman: 'Kidi',
        mundariDevanagari: 'कीड़ी',
        meaning: 'Upper limb between shoulder and hand.',
        pronunciation: 'aarm',
        emoji: '💪',
        syllables: ['Arm'],
      ),
      EnglishMundariWord(
        english: 'Foot',
        mundariRoman: 'Kata',
        mundariDevanagari: 'कटा',
        meaning: 'Bottom part of leg used for standing.',
        pronunciation: 'fut',
        emoji: '🦶',
        syllables: ['Foot'],
      ),
      EnglishMundariWord(
        english: 'Shoulder',
        mundariRoman: 'Taran',
        mundariDevanagari: 'तारन',
        meaning: 'Joint connecting arm to body.',
        pronunciation: 'shohl-der',
        emoji: '👕',
        syllables: ['Shoul', 'der'],
      ),
      EnglishMundariWord(
        english: 'Knee',
        mundariRoman: 'Mukuni',
        mundariDevanagari: 'मुकुनी',
        meaning: 'Middle joint of the leg.',
        pronunciation: 'nee',
        emoji: '🦵',
        syllables: ['Knee'],
      ),
      EnglishMundariWord(
        english: 'Toe',
        mundariRoman: 'Daro',
        mundariDevanagari: 'दारो',
        meaning: 'One of five small digits on foot.',
        pronunciation: 'toh',
        emoji: '🦶',
        syllables: ['Toe'],
      ),
      EnglishMundariWord(
        english: 'Cheek',
        mundariRoman: 'Jowa',
        mundariDevanagari: 'जोबा',
        meaning: 'Side of face below the eye.',
        pronunciation: 'cheek',
        emoji: '😊',
        syllables: ['Cheek'],
      ),
      EnglishMundariWord(
        english: 'Tongue',
        mundariRoman: 'Alang',
        mundariDevanagari: 'आलांग',
        meaning: 'Used inside mouth to taste food.',
        pronunciation: 'tung',
        emoji: '👅',
        syllables: ['Tongue'],
      ),
    ],

    'Life Around Us': [
      EnglishMundariWord(
        english: 'Lion',
        mundariRoman: 'Kula',
        mundariDevanagari: 'कुला',
        meaning: 'King of the jungle that roars loud.',
        pronunciation: 'lai-un',
        emoji: '🦁',
        syllables: ['Li', 'on'],
      ),
      EnglishMundariWord(
        english: 'Monkey',
        mundariRoman: 'Gari',
        mundariDevanagari: 'गड़ि',
        meaning: 'Playful animal that jumps on trees.',
        pronunciation: 'mung-kee',
        emoji: '🐒',
        syllables: ['Mon', 'key'],
      ),
      EnglishMundariWord(
        english: 'Fish',
        mundariRoman: 'Hai',
        mundariDevanagari: 'हाइ',
        meaning: 'Swims in water using fins.',
        pronunciation: 'fish',
        emoji: '🐟',
        syllables: ['Fish'],
      ),
      EnglishMundariWord(
        english: 'Elephant',
        mundariRoman: 'Hati',
        mundariDevanagari: 'हाति',
        meaning: 'Huge animal with long trunk and big ears.',
        pronunciation: 'el-uh-funt',
        emoji: '🐘',
        syllables: ['El', 'e', 'phant'],
      ),
      EnglishMundariWord(
        english: 'Frog',
        mundariRoman: 'Choke',
        mundariDevanagari: 'चोके',
        meaning: 'Green animal that hops near ponds.',
        pronunciation: 'frog',
        emoji: '🐸',
        syllables: ['Frog'],
      ),
      EnglishMundariWord(
        english: 'Rabbit',
        mundariRoman: 'Kulai',
        mundariDevanagari: 'कुलइ',
        meaning: 'Small fluffy animal with long ears.',
        pronunciation: 'rab-it',
        emoji: '🐰',
        syllables: ['Rab', 'bit'],
      ),
    ],

    'The Food We Eat': [
      EnglishMundariWord(
        english: 'Roti',
        mundariRoman: 'Lad',
        mundariDevanagari: 'लाद',
        meaning: 'Round flatbread made from wheat flour.',
        pronunciation: 'roh-tee',
        emoji: '🫓',
        syllables: ['Ro', 'ti'],
      ),
      EnglishMundariWord(
        english: 'Poori',
        mundariRoman: 'Puri',
        mundariDevanagari: 'पुरी',
        meaning: 'Deep-fried puffy Indian bread.',
        pronunciation: 'poo-ree',
        emoji: '🍞',
        syllables: ['Poo', 'ri'],
      ),
      EnglishMundariWord(
        english: 'Idli',
        mundariRoman: 'Idli',
        mundariDevanagari: 'इड़लि',
        meaning: 'Soft steamed rice cake.',
        pronunciation: 'id-lee',
        emoji: '🍚',
        syllables: ['Id', 'li'],
      ),
      EnglishMundariWord(
        english: 'Chutney',
        mundariRoman: 'Catni',
        mundariDevanagari: 'चाटनी',
        meaning: 'Tasty sauce made from herbs or coconut.',
        pronunciation: 'chut-nee',
        emoji: '🥣',
        syllables: ['Chut', 'ney'],
      ),
      EnglishMundariWord(
        english: 'Paratha',
        mundariRoman: 'Paratha',
        mundariDevanagari: 'पराठा',
        meaning: 'Layered flatbread cooked with ghee.',
        pronunciation: 'puh-rah-thuh',
        emoji: '🥞',
        syllables: ['Pa', 'ra', 'tha'],
      ),
      EnglishMundariWord(
        english: 'Chilla',
        mundariRoman: 'Cila',
        mundariDevanagari: 'चिला',
        meaning: 'Savory pancake made from gram flour.',
        pronunciation: 'chil-lah',
        emoji: '🥞',
        syllables: ['Chil', 'la'],
      ),
      EnglishMundariWord(
        english: 'Fruits',
        mundariRoman: 'Jo',
        mundariDevanagari: 'जो',
        meaning: 'Sweet and juicy natural food like apples.',
        pronunciation: 'froots',
        emoji: '🍎',
        syllables: ['Fruits'],
      ),
      EnglishMundariWord(
        english: 'Milk',
        mundariRoman: 'Toa',
        mundariDevanagari: 'तोआ',
        meaning: 'White healthy drink given by cows.',
        pronunciation: 'milk',
        emoji: '🥛',
        syllables: ['Milk'],
      ),
      EnglishMundariWord(
        english: 'Honey',
        mundariRoman: 'Nili Da',
        mundariDevanagari: 'निलि दः',
        meaning: 'Sweet liquid made by honeybees.',
        pronunciation: 'hun-ee',
        emoji: '🍯',
        syllables: ['Hon', 'ey'],
      ),
      EnglishMundariWord(
        english: 'Cow',
        mundariRoman: 'Gai',
        mundariDevanagari: 'गाइ',
        meaning: 'Domestic animal that gives fresh milk.',
        pronunciation: 'kow',
        emoji: '🐄',
        syllables: ['Cow'],
      ),
      EnglishMundariWord(
        english: 'Curd',
        mundariRoman: 'Dahi',
        mundariDevanagari: 'दहि',
        meaning: 'Creamy food made from fermented milk.',
        pronunciation: 'kurd',
        emoji: '🥛',
        syllables: ['Curd'],
      ),
      EnglishMundariWord(
        english: 'Butter',
        mundariRoman: 'Gotom',
        mundariDevanagari: 'गोतोम',
        meaning: 'Yellow dairy spread made from milk cream.',
        pronunciation: 'but-er',
        emoji: '🧈',
        syllables: ['But', 'ter'],
      ),
      EnglishMundariWord(
        english: 'Farmer',
        mundariRoman: 'Casi horo',
        mundariDevanagari: 'चाषी होड़ो',
        meaning: 'Person who grows crops and food on farms.',
        pronunciation: 'farm-er',
        emoji: '👨‍🌾',
        syllables: ['Far', 'mer'],
      ),
      EnglishMundariWord(
        english: 'Carrot',
        mundariRoman: 'Gajra',
        mundariDevanagari: 'गाजरा',
        meaning: 'Crunchy orange root vegetable.',
        pronunciation: 'kair-ut',
        emoji: '🥕',
        syllables: ['Car', 'rot'],
      ),
      EnglishMundariWord(
        english: 'Market',
        mundariRoman: 'Pitha',
        mundariDevanagari: 'पिठा',
        meaning: 'Place where fresh food and goods are sold.',
        pronunciation: 'mar-kit',
        emoji: '🏪',
        syllables: ['Mar', 'ket'],
      ),
      EnglishMundariWord(
        english: 'Brinjal',
        mundariRoman: 'Janum Toko',
        mundariDevanagari: 'जनुम टोको',
        meaning: 'Purple vegetable also called eggplant.',
        pronunciation: 'brin-jahl',
        emoji: '🍆',
        syllables: ['Brin', 'jal'],
      ),
      EnglishMundariWord(
        english: 'Mango',
        mundariRoman: 'Uli',
        mundariDevanagari: 'उलि',
        meaning: 'Sweet yellow king of fruits.',
        pronunciation: 'mang-goh',
        emoji: '🥭',
        syllables: ['Man', 'go'],
      ),
      EnglishMundariWord(
        english: 'Breakfast',
        mundariRoman: 'Setahak mandi',
        mundariDevanagari: 'सेताःआः माण्डि',
        meaning: 'First meal of the day eaten in morning.',
        pronunciation: 'brek-fust',
        emoji: '🍳',
        syllables: ['Break', 'fast'],
      ),
      EnglishMundariWord(
        english: 'Dinner',
        mundariRoman: 'Ayubak mandi',
        mundariDevanagari: 'आय्युबाः माण्डि',
        meaning: 'Night meal eaten before sleep.',
        pronunciation: 'din-er',
        emoji: '🍲',
        syllables: ['Din', 'ner'],
      ),
    ],
  };

  /// Map of English chapter title to bilingual sentence list
  static const Map<String, List<BilingualSentence>> chapterSentences = {
    'Two Little Hands': [
      BilingualSentence(
        englishSentence: 'I have two Hands.',
        mundariRoman: 'Aingya baria ti menah-a.',
        mundariDevanagari: 'आईंयाः बारिआ ति मेनाः-आ ।',
        relatedWord: 'Hand',
      ),
      BilingualSentence(
        englishSentence: 'I walk with my Legs.',
        mundariRoman: "Aing kata te'iñ senoh-a.",
        mundariDevanagari: 'आईं काटा तेईं सेनोः-आ ।',
        relatedWord: 'Leg',
      ),
      BilingualSentence(
        englishSentence: 'I see with my Eyes.',
        mundariRoman: "Aing med te'iñ nel tana.",
        mundariDevanagari: 'आईं मेद तेईं नेल् ताना ।',
        relatedWord: 'Eye',
      ),
      BilingualSentence(
        englishSentence: 'I hear with my Ears.',
        mundariRoman: "Aing lutur te'iñ ayum tana.",
        mundariDevanagari: 'आईं लुतुर तेईं आयुम् ताना ।',
        relatedWord: 'Ear',
      ),
      BilingualSentence(
        englishSentence: 'I smell with my Nose.',
        mundariRoman: "Aing muh te'iñ si tana.",
        mundariDevanagari: 'आईं मुः तेईं सि ताना ।',
        relatedWord: 'Nose',
      ),
    ],

    'Life Around Us': [
      BilingualSentence(
        englishSentence: 'This is a roaring Lion.',
        mundariRoman: 'Neah garajau tan kula ge.',
        mundariDevanagari: 'नेआः गरजाउ तान कुला गे ।',
        relatedWord: 'Lion',
      ),
      BilingualSentence(
        englishSentence: 'The Monkey jumps on trees.',
        mundariRoman: 'Gadhi subung daru kore hechoh-a.',
        mundariDevanagari: 'गाढ़ि सुबुं दारु कोरे हेचोः-आ ।',
        relatedWord: 'Monkey',
      ),
      BilingualSentence(
        englishSentence: 'The Fish swims in water.',
        mundariRoman: "Hai ko dah re ko pai'ñ-a.",
        mundariDevanagari: 'हाइ को दाः रे को पाईं-आ ।',
        relatedWord: 'Fish',
      ),
      BilingualSentence(
        englishSentence: 'The Elephant has a long trunk.',
        mundariRoman: 'Hati ah jiling shund menah-a.',
        mundariDevanagari: 'हाती आः जिलिंग शुण्ड मेनाः-आ ।',
        relatedWord: 'Elephant',
      ),
      BilingualSentence(
        englishSentence: 'The Frog hops near the pond.',
        mundariRoman: "Choche bandha adere don tanai'ñ.",
        mundariDevanagari: 'चोचे बान्धा आड़ेरे डोन तानाईं ।',
        relatedWord: 'Frog',
      ),
    ],

    'The Food We Eat': [
      BilingualSentence(
        englishSentence: 'We eat hot Roti for lunch.',
        mundariRoman: 'Abu tikin jom re lolo roti bu joma.',
        mundariDevanagari: 'आबु टिकिन जोम् रे लोलो रोटी बु जोमा ।',
        relatedWord: 'Roti',
      ),
      BilingualSentence(
        englishSentence: 'I drink fresh Milk every day.',
        mundariRoman: "Aing din ge toa'iñ nuia.",
        mundariDevanagari: 'आईं दिन गे तोआंईं नुइआ ।',
        relatedWord: 'Milk',
      ),
      BilingualSentence(
        englishSentence: 'Mango is a sweet yellow fruit.',
        mundariRoman: 'Uli med sukul sasang jo ge.',
        mundariDevanagari: 'उलि मेद् सुकुल शास्रां जो गे ।',
        relatedWord: 'Mango',
      ),
      BilingualSentence(
        englishSentence: 'The Farmer grows good food.',
        mundariRoman: "Chasi hodo bugin jom jinish omeai'ñ.",
        mundariDevanagari: 'चाषी होड़ो बुगिन जोम् जिनिष ओमेआईं ।',
        relatedWord: 'Farmer',
      ),
      BilingualSentence(
        englishSentence: 'Carrot is a healthy vegetable.',
        mundariRoman: 'Gajar bugin jilu-utu (sabji) ge.',
        mundariDevanagari: 'गाजर बुगिन जिलु-उतु (सबजि) गे ।',
        relatedWord: 'Carrot',
      ),
    ],
  };

  /// Map of English chapter title to bilingual riddle list
  static const Map<String, List<BilingualRiddle>> chapterRiddles = {
    'Two Little Hands': [
      BilingualRiddle(
        englishRiddle: 'I am on your face. I help you smell sweet flowers. What am I?',
        mundariRoman: "Aing amah muhang re menai'ñ. Baha cheke re aing so meai'ñ. Aing chili ge?",
        mundariDevanagari: 'आईं आमाः मुहँ रे मेनाईं । बाहा चेके रे आईं सो मेआईं । आईं चिलि गे?',
        answerEnglish: 'Nose',
        answerMundariRoman: 'Muh',
        answerMundariDevanagari: 'मुः',
      ),
      BilingualRiddle(
        englishRiddle: 'I am open during the day and closed when you sleep. I help you see. What am I?',
        mundariRoman: "Aing singi bela neloh-a, durum bela sing ai'ñ. Aing nel re menai'ñ. Aing chili ge?",
        mundariDevanagari: 'आईं सिंगी बेळा नेलोः-आ, दुरुम् बेळा सिंग् आईं । आईं नेल् रे मेनाईं । आईं चिलि गे?',
        answerEnglish: 'Eye',
        answerMundariRoman: 'Med',
        answerMundariDevanagari: 'मेद्',
      ),
      BilingualRiddle(
        englishRiddle: 'I am on the side of your head. I help you listen to music. What am I?',
        mundariRoman: "Aing amah boh dhare re menai'ñ. Durang ayum re aing godo meai'ñ. Aing chili ge?",
        mundariDevanagari: 'आईं आमाः बोः धारे रे मेनाईं । दुरंग आयुम् रे आईं गोड़ो मेआईं । आईं चिलि गे?',
        answerEnglish: 'Ear',
        answerMundariRoman: 'Lutur',
        answerMundariDevanagari: 'लुतुर',
      ),
      BilingualRiddle(
        englishRiddle: 'I am at the bottom of your body. I help you walk and run. What am I?',
        mundariRoman: "Aing amah latar re menai'ñ. Senoh ado nir re menai'ñ. Aing chili ge?",
        mundariDevanagari: 'आईं आमाः लातार् रे मेनाईं । सेनोः आड़ो निर् रे मेनाईं । आईं चिलि गे?',
        answerEnglish: 'Leg',
        answerMundariRoman: 'Kata',
        answerMundariDevanagari: 'काटा',
      ),
    ],

    'Life Around Us': [
      BilingualRiddle(
        englishRiddle: 'I have a big mane and I am called the King of the Jungle. Who am I?',
        mundariRoman: 'Aingyah marang ub menah-a, ado aing bir ren raja ge. Aing chili ge?',
        mundariDevanagari: 'आईंयाः मारां उब् मेनाः-आ, आड़ो आईं बिर् रेन् राजा गे । आईं चिलि गे?',
        answerEnglish: 'Lion',
        answerMundariRoman: 'Kula',
        answerMundariDevanagari: 'कुला',
      ),
      BilingualRiddle(
        englishRiddle: 'I love swinging on tree branches and eating bananas. Who am I?',
        mundariRoman: "Aing daru kota re hechoh sukui'ñ-a, ado kera'iñ joma. Aing chili ge?",
        mundariDevanagari: 'आईं दारु कोटा रे हेचोः सुकुईं-आ, आड़ो केरांईं जोमा । आईं चिलि गे?',
        answerEnglish: 'Monkey',
        answerMundariRoman: 'Gadhi',
        answerMundariDevanagari: 'गाढ़ि',
      ),
      BilingualRiddle(
        englishRiddle: 'I live in water and swim using my fins. Who am I?',
        mundariRoman: "Aing dah re'iñ taen-a, ado pai'ñ geai'ñ. Aing chili ge?",
        mundariDevanagari: 'आईं दाः रेईं ताएन्-आ, आड़ो पाईं गेआईं । आईं चिलि गे?',
        answerEnglish: 'Fish',
        answerMundariRoman: 'Hai',
        answerMundariDevanagari: 'हाइ',
      ),
      BilingualRiddle(
        englishRiddle: 'I am a huge animal with a long trunk and big ears. Who am I?',
        mundariRoman: 'Aing marang jib ge, aingyah jiling shund ado marang lutur menah-a. Aing chili ge?',
        mundariDevanagari: 'आईं मारां जीव गे, आईंयाः जिलिंग शुण्ड आड़ो मारां लुतुर मेनाः-आ । आईं चिलि गे?',
        answerEnglish: 'Elephant',
        answerMundariRoman: 'Hati',
        answerMundariDevanagari: 'हाती',
      ),
    ],

    'The Food We Eat': [
      BilingualRiddle(
        englishRiddle: 'I am a healthy white drink given by cows. What am I?',
        mundariRoman: "Aing pundi nui jinish ge, gai omeai'ñ. Aing chili ge?",
        mundariDevanagari: 'आईं पुण्डि नुइ जिनिष गे, गाइ ओमेआईं । आईं चिलि गे?',
        answerEnglish: 'Milk',
        answerMundariRoman: 'Toa',
        answerMundariDevanagari: 'तोआं',
      ),
      BilingualRiddle(
        englishRiddle: 'I am sweet, yellow, and known as the King of Fruits. What am I?',
        mundariRoman: 'Aing sibil sasang jo ge, jo koah raja ge aing. Aing chili ge?',
        mundariDevanagari: 'आईं सिबिल् शास्रां जो गे, जो कोआः राजा गे आईं । आईं चिलि गे?',
        answerEnglish: 'Mango',
        answerMundariRoman: 'Uli',
        answerMundariDevanagari: 'उलि',
      ),
      BilingualRiddle(
        englishRiddle: 'I am a round flatbread made from wheat flour. What am I?',
        mundariRoman: 'Aing gol roti ge, gaham holong te baiyoh-a. Aing chili ge?',
        mundariDevanagari: 'आईं गोल् रोटी गे, गहम होलों ते बाईयोः-आ । आईं चिलि गे?',
        answerEnglish: 'Roti',
        answerMundariRoman: 'Roti',
        answerMundariDevanagari: 'रोटी',
      ),
      BilingualRiddle(
        englishRiddle: 'I am a crunchy orange vegetable that rabbits love. What am I?',
        mundariRoman: 'Aing kulai sukuan sasang-ora sabji ge. Aing chili ge?',
        mundariDevanagari: 'आईं कुलइ सुकुआन शास्रां-ओरा सबजि गे । आईं चिलि गे?',
        answerEnglish: 'Carrot',
        answerMundariRoman: 'Gajar',
        answerMundariDevanagari: 'गाजर',
      ),
    ],
  };

  /// Map of English chapter title to quiz questions list
  static const Map<String, List<EnglishQuizQuestion>> chapterQuizzes = {
    'Two Little Hands': [
      EnglishQuizQuestion(
        question: 'What do we smell pleasant flowers with?',
        questionDevanagari: 'आबु सोआन बाहा को चेनाः तेबु सोआनेआ?',
        options: ['Nose', 'Ear', 'Hand', 'Foot'],
        optionsDevanagari: ['मुआं', 'लुतुर', 'ति', 'काटा'],
        correctIndex: 0,
        explanation: 'We use our Nose to smell things around us.',
      ),
      EnglishQuizQuestion(
        question: 'Which body part do we use to see colors and pictures?',
        questionDevanagari: 'रंग ओड़ोः छवि को नेल लागि आबु चेन हड़मो हिसा इस्तेमाल एआबु?',
        options: ['Ear', 'Eye', 'Leg', 'Cheek'],
        optionsDevanagari: ['लुतुर', 'मेद', 'काटा', 'जोआ'],
        correctIndex: 1,
        explanation: 'We see the world around us using our Eyes.',
      ),
      EnglishQuizQuestion(
        question: 'What do we use to walk and run in the park?',
        questionDevanagari: 'पार्क रे सेन ओड़ोः निर लागि आबु चेनाः इस्तेमाल एआबु?',
        options: ['Head', 'Nose', 'Leg', 'Tongue'],
        optionsDevanagari: ['बोः', 'मुआं', 'काटा', 'आलांग'],
        correctIndex: 2,
        explanation: 'Our Legs help us walk, run, and jump.',
      ),
      EnglishQuizQuestion(
        question: 'What body part inside our mouth helps us taste sweet food?',
        questionDevanagari: 'मोचा भितर रे चेन हड़मो हिसा आबुके सिबिल जोम रे साहाय्य एआबु?',
        options: ['Skin', 'Tongue', 'Knee', 'Arm'],
        optionsDevanagari: ['हर्ता', 'आलांग', 'मुकुड़ि', 'गोसो'],
        correctIndex: 1,
        explanation: 'Our Tongue tastes sweet, salty, and sour flavors.',
      ),
      EnglishQuizQuestion(
        question: 'What do we use to clap when we hear good music?',
        questionDevanagari: 'बुगिन दुरंग आयुम केते थापड़ि लागि आबु चेनाः इस्तेमाल एआबु?',
        options: ['Foot', 'Hand', 'Ear', 'Nose'],
        optionsDevanagari: ['काटा', 'ति', 'लुतुर', 'मुआं'],
        correctIndex: 1,
        explanation: 'We clap together using both our Hands.',
      ),
    ],

    'Life Around Us': [
      EnglishQuizQuestion(
        question: 'Which grand animal has a big mane and is called King of the Jungle?',
        questionDevanagari: 'चेन मारांग जीवु गाड़ा जंगल रा राजा मेन्ते काजिओआ?',
        options: ['Lion', 'Rabbit', 'Frog', 'Fish'],
        optionsDevanagari: ['कुला', 'कुलु', 'चोके', 'हाइ'],
        correctIndex: 0,
        explanation: 'The Lion is known as the King of the Jungle.',
      ),
      EnglishQuizQuestion(
        question: 'Which playful animal loves jumping from tree to tree?',
        questionDevanagari: 'चेन इनुंग जीवु मिआद दारु एते एटाः दारु ते कुदाउ खुसिओआ?',
        options: ['Fish', 'Monkey', 'Elephant', 'Frog'],
        optionsDevanagari: ['हाइ', 'गाड़ि', 'हाती', 'चोके'],
        correctIndex: 1,
        explanation: 'Monkeys swing and jump playful across tree branches.',
      ),
      EnglishQuizQuestion(
        question: 'Which animal lives in water and swims using fins?',
        questionDevanagari: 'चेन जीवु दाः रे ताहेन आय ओड़ोः पाखना ते उयुंग एआ?',
        options: ['Rabbit', 'Lion', 'Fish', 'Elephant'],
        optionsDevanagari: ['कुलु', 'कुला', 'हाइ', 'हाती'],
        correctIndex: 2,
        explanation: 'Fish live in water and swim using their fins.',
      ),
      EnglishQuizQuestion(
        question: 'Which huge animal has a long trunk and big fan ears?',
        questionDevanagari: 'चेन मारांग जीवु रा जेलेंग सुण्ढ ओड़ोः बिंचणा लेकान लुतुर मेनाः?',
        options: ['Elephant', 'Frog', 'Monkey', 'Lion'],
        optionsDevanagari: ['हाती', 'चोके', 'गाड़ि', 'कुला'],
        correctIndex: 0,
        explanation: 'Elephants are huge animals with long trunks.',
      ),
      EnglishQuizQuestion(
        question: 'Which green animal hops around ponds and makes "croak" sounds?',
        questionDevanagari: 'चेन हरियार जीवु बान्धा चारिपाखे रे कुदाउआ ओड़ोः \'क्रोक\' शब्द एआ?',
        options: ['Rabbit', 'Frog', 'Lion', 'Elephant'],
        optionsDevanagari: ['कुलु', 'चोके', 'कुला', 'हाती'],
        correctIndex: 1,
        explanation: 'Frogs hop around ponds and croak.',
      ),
      EnglishQuizQuestion(
        question: 'Which small fluffy animal has long ears and soft fur?',
        questionDevanagari: 'चेन हुडिंग लुमाम जीवु रा जेलेंग लुतुर ओड़ोः लुमाम उब मेनाः?',
        options: ['Elephant', 'Fish', 'Monkey', 'Rabbit'],
        optionsDevanagari: ['हाती', 'हाइ', 'गाड़ि', 'कुलु'],
        correctIndex: 3,
        explanation: 'Rabbits are soft, fluffy animals with long ears.',
      ),
    ],

    'The Food We Eat': [
      EnglishQuizQuestion(
        question: 'What healthy white drink do cows give us?',
        questionDevanagari: 'गाइ को आबुके चेन बुगिन पुण्डि नु दाः को एमाबुआ?',
        options: ['Milk', 'Honey', 'Chutney', 'Juice'],
        optionsDevanagari: ['तोआ', 'महु', 'चटणि', 'रस'],
        correctIndex: 0,
        explanation: 'Cows give us fresh and healthy Milk.',
      ),
      EnglishQuizQuestion(
        question: 'Which sweet yellow fruit is known as the king of fruits?',
        questionDevanagari: 'चेन सिबिल सासांग जो जो को रा राजा मेन्ते सेबासेड़ाओआ?',
        options: ['Carrot', 'Mango', 'Brinjal', 'Roti'],
        optionsDevanagari: ['गाजर', 'उलि', 'बाइगण', 'रुटि'],
        correctIndex: 1,
        explanation: 'Mango is a delicious yellow fruit known as the king of fruits.',
      ),
      EnglishQuizQuestion(
        question: 'Who grows crops and food for everyone on the farm?',
        questionDevanagari: 'फार्म रे सबेन को लागि चाष ओड़ोः जोमआ चिमिन ओलाआ?',
        options: ['Doctor', 'Teacher', 'Farmer', 'Pilot'],
        optionsDevanagari: ['डाक्टर', 'मास्टर', 'चाषी', 'पाइलट'],
        correctIndex: 2,
        explanation: 'Farmers grow food crops and vegetables on farms.',
      ),
      EnglishQuizQuestion(
        question: 'What sweet food do honeybees make in beehives?',
        questionDevanagari: 'शुद्ध जोमआ नेल शुटि को शुटि गुड़ा रे चिमिन बेनाओआ?',
        options: ['Curd', 'Butter', 'Honey', 'Idli'],
        optionsDevanagari: ['दहि', 'गोतोम', 'महु', 'इड्लि'],
        correctIndex: 2,
        explanation: 'Honeybees make sweet natural Honey.',
      ),
      EnglishQuizQuestion(
        question: 'What meal do we eat in the morning when we wake up?',
        questionDevanagari: 'सेताः रे आबु एभेन केते चेन जोमआ बु जोमेआ?',
        options: ['Dinner', 'Breakfast', 'Snack', 'Lunch'],
        optionsDevanagari: ['आय्युब जोम', 'सेताः जोम', 'जलखिआ', 'टिकिन जोम'],
        correctIndex: 1,
        explanation: 'Breakfast is the first meal of the day eaten in the morning.',
      ),
    ],
  };

  /// Returns word list for given chapter name or null
  static List<EnglishMundariWord>? getWords(String chapterName) {
    return chapterWords[chapterName];
  }

  /// Returns quiz questions for given chapter name or null
  static List<EnglishQuizQuestion>? getQuizQuestions(String chapterName) {
    return chapterQuizzes[chapterName];
  }

  /// Returns bilingual sentences for given chapter name or null
  static List<BilingualSentence>? getSentences(String chapterName) {
    return chapterSentences[chapterName];
  }

  /// Returns bilingual riddles for given chapter name or null
  static List<BilingualRiddle>? getRiddles(String chapterName) {
    return chapterRiddles[chapterName];
  }
}
