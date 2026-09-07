/// Hardcoded English-Mundari vocabulary and quiz data for Class 1 English prototype.
/// NCERT Textbook verified content for hackathon demo (no RAG/external dependencies).
library;

const Map<String, String> worksheetLabels = {
  'AYOVAANI Classroom Worksheet': 'ଆୟୋୱାଣି ଶ୍ରେଣୀ କାର୍ଯ୍ୟଫର',
  'Name:': 'ନୁତୁମ:',
  'Date:': 'ତିତି:',
  'Exercise: Trace and write the words below': 'ଅଭ୍ୟାସ: ନିଚେତ ଶବ୍ଦ କୋ ତ୍ରେସ୍ ଓଡ଼ୋଃ ଓଲା ମେ',
  'Exercise 1: Draw lines to match each picture to its sentence': 'ଅଭ୍ୟାସ ୧: ଛବି ଓଡ଼ୋଃ ଜଗର ମିଲା ଲାଗି ରେଖା ଟାଣ ମେ',
  'Exercise 2: Fun with Words - Read the syllables': 'ଅଭ୍ୟାସ ୨: ଶବ୍ଦ ରା ରସିକା - ବର୍ଣ୍ଣାଂଶ ପଢ଼ ମେ',
  'Exercise: Read the riddles and write the answers below': 'ଅଭ୍ୟାସ: ଦାୟେ ପଢ଼ ଓଡ଼ୋଃ ଜାବାବ ଓଲା ମେ',
  'Answer:': 'ଜାବାବ:',
  'Exercise: Circle the odd one out in each row below': 'ଅଭ୍ୟାସ: ଧାଡ଼ି ରେ ଅଲଗା ଗୋଲ କର ମେ',
};

class EnglishMundariWord {
  final String english;
  final String mundariRoman;
  final String mundariOdia;
  final String meaning;
  final String pronunciation;
  final String emoji;
  final List<String> syllables;

  const EnglishMundariWord({
    required this.english,
    required this.mundariRoman,
    required this.mundariOdia,
    required this.meaning,
    required this.pronunciation,
    required this.emoji,
    required this.syllables,
  });

  /// Combined formatted display string e.g. "( Tii / ତୀ )"
  String get mundariDisplay => '( $mundariRoman / $mundariOdia )';
}

class EnglishQuizQuestion {
  final String question;
  final String questionOdia;
  final List<String> options;
  final List<String> optionsOdia;
  final int correctIndex;
  final String explanation;

  const EnglishQuizQuestion({
    required this.question,
    required this.questionOdia,
    required this.options,
    required this.optionsOdia,
    required this.correctIndex,
    required this.explanation,
  });
}

class BilingualSentence {
  final String englishSentence;
  final String mundariRoman;
  final String mundariOdia;
  final String relatedWord;

  const BilingualSentence({
    required this.englishSentence,
    required this.mundariRoman,
    required this.mundariOdia,
    required this.relatedWord,
  });
}

class BilingualRiddle {
  final String englishRiddle;
  final String mundariRoman;
  final String mundariOdia;
  final String answerEnglish;
  final String answerMundariRoman;
  final String answerMundariOdia;

  const BilingualRiddle({
    required this.englishRiddle,
    required this.mundariRoman,
    required this.mundariOdia,
    required this.answerEnglish,
    required this.answerMundariRoman,
    required this.answerMundariOdia,
  });
}

class EnglishActivitiesData {
  /// Map of English chapter title to vocabulary list
  static const Map<String, List<EnglishMundariWord>> chapterWords = {
    'Two Little Hands': [
      EnglishMundariWord(
        english: 'Hand',
        mundariRoman: 'Tii',
        mundariOdia: 'ତୀ',
        meaning: 'Used to hold, write, and clap.',
        pronunciation: 'hand',
        emoji: '✋',
        syllables: ['Hand'],
      ),
      EnglishMundariWord(
        english: 'Leg',
        mundariRoman: 'Kata',
        mundariOdia: 'କଟା',
        meaning: 'Used to walk and run.',
        pronunciation: 'leg',
        emoji: '🦵',
        syllables: ['Leg'],
      ),
      EnglishMundariWord(
        english: 'Head',
        mundariRoman: 'Boo',
        mundariOdia: 'ବୋ',
        meaning: 'Top part of body with hair and brain.',
        pronunciation: 'hed',
        emoji: '🗣️',
        syllables: ['Head'],
      ),
      EnglishMundariWord(
        english: 'Eye',
        mundariRoman: 'Med',
        mundariOdia: 'ମେଦ',
        meaning: 'Used to see colors and shapes.',
        pronunciation: 'ai',
        emoji: '👁️',
        syllables: ['Eye'],
      ),
      EnglishMundariWord(
        english: 'Ear',
        mundariRoman: 'Lutur',
        mundariOdia: 'ଲୁତୁର',
        meaning: 'Used to hear sounds and music.',
        pronunciation: 'eer',
        emoji: '👂',
        syllables: ['Ear'],
      ),
      EnglishMundariWord(
        english: 'Nose',
        mundariRoman: 'Muhu',
        mundariOdia: 'ମୁହୁ',
        meaning: 'Used to smell flowers and food.',
        pronunciation: 'nohz',
        emoji: '👃',
        syllables: ['Nose'],
      ),
      EnglishMundariWord(
        english: 'Mouth',
        mundariRoman: 'Moca',
        mundariOdia: 'ମୋଚା',
        meaning: 'Used to speak and eat food.',
        pronunciation: 'mowth',
        emoji: '👄',
        syllables: ['Mouth'],
      ),
      EnglishMundariWord(
        english: 'Skin',
        mundariRoman: 'Uru',
        mundariOdia: 'ଉରୁ',
        meaning: 'Covers body and feels touch.',
        pronunciation: 'skin',
        emoji: '🖐️',
        syllables: ['Skin'],
      ),
      EnglishMundariWord(
        english: 'Arm',
        mundariRoman: 'Kidi',
        mundariOdia: 'କୀଡ଼ୀ',
        meaning: 'Upper limb between shoulder and hand.',
        pronunciation: 'aarm',
        emoji: '💪',
        syllables: ['Arm'],
      ),
      EnglishMundariWord(
        english: 'Foot',
        mundariRoman: 'Kata',
        mundariOdia: 'କଟା',
        meaning: 'Bottom part of leg used for standing.',
        pronunciation: 'fut',
        emoji: '🦶',
        syllables: ['Foot'],
      ),
      EnglishMundariWord(
        english: 'Shoulder',
        mundariRoman: 'Taran',
        mundariOdia: 'ତାରନ',
        meaning: 'Joint connecting arm to body.',
        pronunciation: 'shohl-der',
        emoji: '👕',
        syllables: ['Shoul', 'der'],
      ),
      EnglishMundariWord(
        english: 'Knee',
        mundariRoman: 'Mukuni',
        mundariOdia: 'ମୁକୁନୀ',
        meaning: 'Middle joint of the leg.',
        pronunciation: 'nee',
        emoji: '🦵',
        syllables: ['Knee'],
      ),
      EnglishMundariWord(
        english: 'Toe',
        mundariRoman: 'Daro',
        mundariOdia: 'ଦାରୋ',
        meaning: 'One of five small digits on foot.',
        pronunciation: 'toh',
        emoji: '🦶',
        syllables: ['Toe'],
      ),
      EnglishMundariWord(
        english: 'Cheek',
        mundariRoman: 'Jowa',
        mundariOdia: 'ଜୋବା',
        meaning: 'Side of face below the eye.',
        pronunciation: 'cheek',
        emoji: '😊',
        syllables: ['Cheek'],
      ),
      EnglishMundariWord(
        english: 'Tongue',
        mundariRoman: 'Alang',
        mundariOdia: 'ଆଲାଙ୍ଗ',
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
        mundariOdia: 'କୁଲା',
        meaning: 'King of the jungle that roars loud.',
        pronunciation: 'lai-un',
        emoji: '🦁',
        syllables: ['Li', 'on'],
      ),
      EnglishMundariWord(
        english: 'Monkey',
        mundariRoman: 'Gari',
        mundariOdia: 'ଗଡ଼ି',
        meaning: 'Playful animal that jumps on trees.',
        pronunciation: 'mung-kee',
        emoji: '🐒',
        syllables: ['Mon', 'key'],
      ),
      EnglishMundariWord(
        english: 'Fish',
        mundariRoman: 'Hai',
        mundariOdia: 'ହାଇ',
        meaning: 'Swims in water using fins.',
        pronunciation: 'fish',
        emoji: '🐟',
        syllables: ['Fish'],
      ),
      EnglishMundariWord(
        english: 'Elephant',
        mundariRoman: 'Hati',
        mundariOdia: 'ହାତି',
        meaning: 'Huge animal with long trunk and big ears.',
        pronunciation: 'el-uh-funt',
        emoji: '🐘',
        syllables: ['El', 'e', 'phant'],
      ),
      EnglishMundariWord(
        english: 'Frog',
        mundariRoman: 'Choke',
        mundariOdia: 'ଚୋକେ',
        meaning: 'Green animal that hops near ponds.',
        pronunciation: 'frog',
        emoji: '🐸',
        syllables: ['Frog'],
      ),
      EnglishMundariWord(
        english: 'Rabbit',
        mundariRoman: 'Kulai',
        mundariOdia: 'କୁଲାଇ',
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
        mundariOdia: 'ଲାଦ',
        meaning: 'Round flatbread made from wheat flour.',
        pronunciation: 'roh-tee',
        emoji: '🫓',
        syllables: ['Ro', 'ti'],
      ),
      EnglishMundariWord(
        english: 'Poori',
        mundariRoman: 'Puri',
        mundariOdia: 'ପୁରୀ',
        meaning: 'Deep-fried puffy Indian bread.',
        pronunciation: 'poo-ree',
        emoji: '🍞',
        syllables: ['Poo', 'ri'],
      ),
      EnglishMundariWord(
        english: 'Idli',
        mundariRoman: 'Idli',
        mundariOdia: 'ଇଡ଼ଲି',
        meaning: 'Soft steamed rice cake.',
        pronunciation: 'id-lee',
        emoji: '🍚',
        syllables: ['Id', 'li'],
      ),
      EnglishMundariWord(
        english: 'Chutney',
        mundariRoman: 'Catni',
        mundariOdia: 'ଚାଟନୀ',
        meaning: 'Tasty sauce made from herbs or coconut.',
        pronunciation: 'chut-nee',
        emoji: '🥣',
        syllables: ['Chut', 'ney'],
      ),
      EnglishMundariWord(
        english: 'Paratha',
        mundariRoman: 'Paratha',
        mundariOdia: 'ପରାଠା',
        meaning: 'Layered flatbread cooked with ghee.',
        pronunciation: 'puh-rah-thuh',
        emoji: '🥞',
        syllables: ['Pa', 'ra', 'tha'],
      ),
      EnglishMundariWord(
        english: 'Chilla',
        mundariRoman: 'Cila',
        mundariOdia: 'ଚିଲା',
        meaning: 'Savory pancake made from gram flour.',
        pronunciation: 'chil-lah',
        emoji: '🥞',
        syllables: ['Chil', 'la'],
      ),
      EnglishMundariWord(
        english: 'Fruits',
        mundariRoman: 'Jo',
        mundariOdia: 'ଜୋ',
        meaning: 'Sweet and juicy natural food like apples.',
        pronunciation: 'froots',
        emoji: '🍎',
        syllables: ['Fruits'],
      ),
      EnglishMundariWord(
        english: 'Milk',
        mundariRoman: 'Toa',
        mundariOdia: 'ତୋଆ',
        meaning: 'White healthy drink given by cows.',
        pronunciation: 'milk',
        emoji: '🥛',
        syllables: ['Milk'],
      ),
      EnglishMundariWord(
        english: 'Honey',
        mundariRoman: 'Nili Da',
        mundariOdia: 'ନିଲି ଦଃ',
        meaning: 'Sweet liquid made by honeybees.',
        pronunciation: 'hun-ee',
        emoji: '🍯',
        syllables: ['Hon', 'ey'],
      ),
      EnglishMundariWord(
        english: 'Cow',
        mundariRoman: 'Gai',
        mundariOdia: 'ଗାଇ',
        meaning: 'Domestic animal that gives fresh milk.',
        pronunciation: 'kow',
        emoji: '🐄',
        syllables: ['Cow'],
      ),
      EnglishMundariWord(
        english: 'Curd',
        mundariRoman: 'Dahi',
        mundariOdia: 'ଦହି',
        meaning: 'Creamy food made from fermented milk.',
        pronunciation: 'kurd',
        emoji: '🥛',
        syllables: ['Curd'],
      ),
      EnglishMundariWord(
        english: 'Butter',
        mundariRoman: 'Gotom',
        mundariOdia: 'ଗୋତୋମ',
        meaning: 'Yellow dairy spread made from milk cream.',
        pronunciation: 'but-er',
        emoji: '🧈',
        syllables: ['But', 'ter'],
      ),
      EnglishMundariWord(
        english: 'Farmer',
        mundariRoman: 'Casi horo',
        mundariOdia: 'ଚାଷୀ ହୋଡ଼ୋ',
        meaning: 'Person who grows crops and food on farms.',
        pronunciation: 'farm-er',
        emoji: '👨‍🌾',
        syllables: ['Far', 'mer'],
      ),
      EnglishMundariWord(
        english: 'Carrot',
        mundariRoman: 'Gajra',
        mundariOdia: 'ଗାଜରା',
        meaning: 'Crunchy orange root vegetable.',
        pronunciation: 'kair-ut',
        emoji: '🥕',
        syllables: ['Car', 'rot'],
      ),
      EnglishMundariWord(
        english: 'Market',
        mundariRoman: 'Pitha',
        mundariOdia: 'ପିଠା',
        meaning: 'Place where fresh food and goods are sold.',
        pronunciation: 'mar-kit',
        emoji: '🏪',
        syllables: ['Mar', 'ket'],
      ),
      EnglishMundariWord(
        english: 'Brinjal',
        mundariRoman: 'Janum Toko',
        mundariOdia: 'ଜନୁମ ଟୋକୋ',
        meaning: 'Purple vegetable also called eggplant.',
        pronunciation: 'brin-jahl',
        emoji: '🍆',
        syllables: ['Brin', 'jal'],
      ),
      EnglishMundariWord(
        english: 'Mango',
        mundariRoman: 'Uli',
        mundariOdia: 'ଉଲି',
        meaning: 'Sweet yellow king of fruits.',
        pronunciation: 'mang-goh',
        emoji: '🥭',
        syllables: ['Man', 'go'],
      ),
      EnglishMundariWord(
        english: 'Breakfast',
        mundariRoman: 'Setahak mandi',
        mundariOdia: 'ସେତାଃଆଃ ମାଣ୍ଡି',
        meaning: 'First meal of the day eaten in morning.',
        pronunciation: 'brek-fust',
        emoji: '🍳',
        syllables: ['Break', 'fast'],
      ),
      EnglishMundariWord(
        english: 'Dinner',
        mundariRoman: 'Ayubak mandi',
        mundariOdia: 'ଆୟୁବାଃ ମାଣ୍ଡି',
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
        mundariOdia: 'ଆଇଁୟାଃ ବାରିଆ ତି ମେନାଃ-ଆ ।',
        relatedWord: 'Hand',
      ),
      BilingualSentence(
        englishSentence: 'I walk with my Legs.',
        mundariRoman: "Aing kata te'iñ senoh-a.",
        mundariOdia: 'ଆଇଁ କାଟା ତେଇଁ ସେନୋଃ-ଆ ।',
        relatedWord: 'Leg',
      ),
      BilingualSentence(
        englishSentence: 'I see with my Eyes.',
        mundariRoman: "Aing med te'iñ nel tana.",
        mundariOdia: 'ଆଇଁ ମେଦ ତେଇଁ ନେଲ୍ ତାନା ।',
        relatedWord: 'Eye',
      ),
      BilingualSentence(
        englishSentence: 'I hear with my Ears.',
        mundariRoman: "Aing lutur te'iñ ayum tana.",
        mundariOdia: 'ଆଇଁ ଲୁତୁର ତେଇଁ ଆୟୁମ୍ ତାନା ।',
        relatedWord: 'Ear',
      ),
      BilingualSentence(
        englishSentence: 'I smell with my Nose.',
        mundariRoman: "Aing muh te'iñ si tana.",
        mundariOdia: 'ଆଇଁ ମୁଃ ତେଇଁ ସି ତାନା ।',
        relatedWord: 'Nose',
      ),
    ],

    'Life Around Us': [
      BilingualSentence(
        englishSentence: 'This is a roaring Lion.',
        mundariRoman: 'Neah garajau tan kula ge.',
        mundariOdia: 'ନେଆଃ ଗରଜାଉ ତାନ କୁଲା ଗେ ।',
        relatedWord: 'Lion',
      ),
      BilingualSentence(
        englishSentence: 'The Monkey jumps on trees.',
        mundariRoman: 'Gadhi subung daru kore hechoh-a.',
        mundariOdia: 'ଗାଢ଼ି ସୁବୁଂ ଦାରୁ କୋରେ ହେଚୋଃ-ଆ ।',
        relatedWord: 'Monkey',
      ),
      BilingualSentence(
        englishSentence: 'The Fish swims in water.',
        mundariRoman: "Hai ko dah re ko pai'ñ-a.",
        mundariOdia: 'ହାଇ କୋ ଦାଃ ରେ କୋ ପାଈଁ-ଆ ।',
        relatedWord: 'Fish',
      ),
      BilingualSentence(
        englishSentence: 'The Elephant has a long trunk.',
        mundariRoman: 'Hati ah jiling shund menah-a.',
        mundariOdia: 'ହାତୀ ଆଃ ଜିଲିଂ ଶୁଣ୍ଡ ମେନାଃ-ଆ ।',
        relatedWord: 'Elephant',
      ),
      BilingualSentence(
        englishSentence: 'The Frog hops near the pond.',
        mundariRoman: "Choche bandha adere don tanai'ñ.",
        mundariOdia: 'ଚୋଚେ ବାନ୍ଧା ଆଡ଼େରେ ଡୋନ୍ ତାନାଈଁ ।',
        relatedWord: 'Frog',
      ),
    ],

    'The Food We Eat': [
      BilingualSentence(
        englishSentence: 'We eat hot Roti for lunch.',
        mundariRoman: 'Abu tikin jom re lolo roti bu joma.',
        mundariOdia: 'ଆବୁ ଟିକିନ୍ ଜୋମ୍ ରେ ଲୋଲୋ ରୋଟି ବୁ ଜୋମା ।',
        relatedWord: 'Roti',
      ),
      BilingualSentence(
        englishSentence: 'I drink fresh Milk every day.',
        mundariRoman: "Aing din ge toa'iñ nuia.",
        mundariOdia: 'ଆଇଁ ଦିନ୍ ଗେ ତୋଆଁଈଁ ନୁଇଆ ।',
        relatedWord: 'Milk',
      ),
      BilingualSentence(
        englishSentence: 'Mango is a sweet yellow fruit.',
        mundariRoman: 'Uli med sukul sasang jo ge.',
        mundariOdia: 'ଉଲି ମେଦ୍ ସୁକୁଲ୍ ଶାସାଂ ଜୋ ଗେ ।',
        relatedWord: 'Mango',
      ),
      BilingualSentence(
        englishSentence: 'The Farmer grows good food.',
        mundariRoman: "Chasi hodo bugin jom jinish omeai'ñ.",
        mundariOdia: 'ଚାଷୀ ହୋଡ଼ୋ ବୁଗିନ୍ ଜୋମ୍ ଜିନିଷ ଓମେଆଈଁ ।',
        relatedWord: 'Farmer',
      ),
      BilingualSentence(
        englishSentence: 'Carrot is a healthy vegetable.',
        mundariRoman: 'Gajar bugin jilu-utu (sabji) ge.',
        mundariOdia: 'ଗାଜର ବୁଗିନ୍ ଜିଲୁ-ଉତୁ (ସବଜି) ଗେ ।',
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
        mundariOdia: 'ଆଇଁ ଆମାଃ ମୁହଁ ରେ ମେନାଈଁ । ବାହା ଚେକେ ରେ ଆଇଁ ସୋ ମେଆଈଁ । ଆଇଁ ଚିଲି ଗେ?',
        answerEnglish: 'Nose',
        answerMundariRoman: 'Muh',
        answerMundariOdia: 'ମୁଃ',
      ),
      BilingualRiddle(
        englishRiddle: 'I am open during the day and closed when you sleep. I help you see. What am I?',
        mundariRoman: "Aing singi bela neloh-a, durum bela sing ai'ñ. Aing nel re menai'ñ. Aing chili ge?",
        mundariOdia: 'ଆଇଁ ସିଂଗୀ ବେଳା ନେଲୋଃ-ଆ, ଦୁରୁମ୍ ବେଳା ସିଂଗ୍ ଆଈଁ । ଆଇଁ ନେଲ୍ ରେ ମେନାଈଁ । ଆଇଁ ଚିଲି ଗେ?',
        answerEnglish: 'Eye',
        answerMundariRoman: 'Med',
        answerMundariOdia: 'ମେଦ୍',
      ),
      BilingualRiddle(
        englishRiddle: 'I am on the side of your head. I help you listen to music. What am I?',
        mundariRoman: "Aing amah boh dhare re menai'ñ. Durang ayum re aing godo meai'ñ. Aing chili ge?",
        mundariOdia: 'ଆଇଁ ଆମାଃ ବୋଃ ଧାରେ ରେ ମେନାଈଁ । ଦୁରଂ ଆୟୁମ୍ ରେ ଆଇଁ ଗୋଡ଼ୋ ମେଆଈଁ । ଆଇଁ ଚିଲି ଗେ?',
        answerEnglish: 'Ear',
        answerMundariRoman: 'Lutur',
        answerMundariOdia: 'ଲୁତୁର',
      ),
      BilingualRiddle(
        englishRiddle: 'I am at the bottom of your body. I help you walk and run. What am I?',
        mundariRoman: "Aing amah latar re menai'ñ. Senoh ado nir re menai'ñ. Aing chili ge?",
        mundariOdia: 'ଆଇଁ ଆମାଃ ଲାତାର୍ ରେ ମେନାଈଁ । ସେନୋଃ ଆଡ଼ୋ ନିର୍ ରେ ମେନାଈଁ । ଆଇଁ ଚିଲି ଗେ?',
        answerEnglish: 'Leg',
        answerMundariRoman: 'Kata',
        answerMundariOdia: 'କାଟା',
      ),
    ],

    'Life Around Us': [
      BilingualRiddle(
        englishRiddle: 'I have a big mane and I am called the King of the Jungle. Who am I?',
        mundariRoman: 'Aingyah marang ub menah-a, ado aing bir ren raja ge. Aing chili ge?',
        mundariOdia: 'ଆଇଁୟାଃ ମାରାଂ ଉବ୍ ମେନାଃ-ଆ, ଆଡ଼ୋ ଆଇଁ ବିର୍ ରେନ୍ ରାଜା ଗେ । ଆଇଁ ଚିଲି ଗେ?',
        answerEnglish: 'Lion',
        answerMundariRoman: 'Kula',
        answerMundariOdia: 'କୁଲା',
      ),
      BilingualRiddle(
        englishRiddle: 'I love swinging on tree branches and eating bananas. Who am I?',
        mundariRoman: "Aing daru kota re hechoh sukui'ñ-a, ado kera'iñ joma. Aing chili ge?",
        mundariOdia: 'ଆଇଁ ଦାରୁ କୋଟା ରେ ହେଚୋଃ ସୁକୁଇଁ-ଆ, ଆଡ଼ୋ କେରାଁଈଁ ଜୋମା । ଆଇଁ ଚିଲି ଗେ?',
        answerEnglish: 'Monkey',
        answerMundariRoman: 'Gadhi',
        answerMundariOdia: 'ଗାଢ଼ି',
      ),
      BilingualRiddle(
        englishRiddle: 'I live in water and swim using my fins. Who am I?',
        mundariRoman: "Aing dah re'iñ taen-a, ado pai'ñ geai'ñ. Aing chili ge?",
        mundariOdia: 'ଆଇଁ ଦାଃ ରେଈଁ ତାଏନ୍-ଆ, ଆଡ଼ୋ ପାଈଁ ଗେଆଈଁ । ଆଇଁ ଚିଲି ଗେ?',
        answerEnglish: 'Fish',
        answerMundariRoman: 'Hai',
        answerMundariOdia: 'ହାଇ',
      ),
      BilingualRiddle(
        englishRiddle: 'I am a huge animal with a long trunk and big ears. Who am I?',
        mundariRoman: 'Aing marang jib ge, aingyah jiling shund ado marang lutur menah-a. Aing chili ge?',
        mundariOdia: 'ଆଇଁ ମାରାଂ ଜୀବ ଗେ, ଆଇଁୟାଃ ଜିଲିଂ ଶୁଣ୍ଡ ଆଡ଼ୋ ମାରାଂ ଲୁତୁର ମେନାଃ-ଆ । ଆଇଁ ଚିଲି ଗେ?',
        answerEnglish: 'Elephant',
        answerMundariRoman: 'Hati',
        answerMundariOdia: 'ହାତୀ',
      ),
    ],

    'The Food We Eat': [
      BilingualRiddle(
        englishRiddle: 'I am a healthy white drink given by cows. What am I?',
        mundariRoman: "Aing pundi nui jinish ge, gai omeai'ñ. Aing chili ge?",
        mundariOdia: 'ଆଇଁ ପୁଣ୍ଡି ନୁଇ ଜିନିଷ ଗେ, ଗାଈ ଓମେଆଈଁ । ଆଇଁ ଚିଲି ଗେ?',
        answerEnglish: 'Milk',
        answerMundariRoman: 'Toa',
        answerMundariOdia: 'ତୋଆଁ',
      ),
      BilingualRiddle(
        englishRiddle: 'I am sweet, yellow, and known as the King of Fruits. What am I?',
        mundariRoman: 'Aing sibil sasang jo ge, jo koah raja ge aing. Aing chili ge?',
        mundariOdia: 'ଆଇଁ ସିବିଲ୍ ଶାସାଂ ଜୋ ଗେ, ଜୋ କୋଆଃ ରାଜା ଗେ ଆଇଁ । ଆଇଁ ଚିଲି ଗେ?',
        answerEnglish: 'Mango',
        answerMundariRoman: 'Uli',
        answerMundariOdia: 'ଉଲି',
      ),
      BilingualRiddle(
        englishRiddle: 'I am a round flatbread made from wheat flour. What am I?',
        mundariRoman: 'Aing gol roti ge, gaham holong te baiyoh-a. Aing chili ge?',
        mundariOdia: 'ଆଇଁ ଗୋଲ୍ ରୋଟି ଗେ, ଗହମ ହୋଲୋଂ ତେ ବାଈୟୋଃ-ଆ । ଆଇଁ ଚିଲି ଗେ?',
        answerEnglish: 'Roti',
        answerMundariRoman: 'Roti',
        answerMundariOdia: 'ରୋଟି',
      ),
      BilingualRiddle(
        englishRiddle: 'I am a crunchy orange vegetable that rabbits love. What am I?',
        mundariRoman: 'Aing kulai sukuan sasang-ora sabji ge. Aing chili ge?',
        mundariOdia: 'ଆଇଁ କୁଲାଇ ସୁକୁଆନ୍ ସାସାଂ-ଅରା ସବଜି ଗେ । ଆଇଁ ଚିଲି ଗେ?',
        answerEnglish: 'Carrot',
        answerMundariRoman: 'Gajar',
        answerMundariOdia: 'ଗାଜର',
      ),
    ],
  };

  /// Map of English chapter title to quiz questions list
  static const Map<String, List<EnglishQuizQuestion>> chapterQuizzes = {
    'Two Little Hands': [
      EnglishQuizQuestion(
        question: 'What do we smell pleasant flowers with?',
        questionOdia: 'ଆବୁ ସୋଆନ୍ ବାହା କୋ ଚେନାଃ ତେବୁ ସୋଆନେଆ?',
        options: ['Nose', 'Ear', 'Hand', 'Foot'],
        optionsOdia: ['ମୁଆଁ', 'ଲୁତୁର', 'ତି', 'କାଟା'],
        correctIndex: 0,
        explanation: 'We use our Nose to smell things around us.',
      ),
      EnglishQuizQuestion(
        question: 'Which body part do we use to see colors and pictures?',
        questionOdia: 'ରଙ୍ଗ ଓଡ଼ୋଃ ଛବି କୋ ନେଲ ଲାଗି ଆବୁ ଚେନ୍ ହଡ଼ମୋ ହିସା ଇସ୍ତେମାଲ ଏଆବୁ?',
        options: ['Ear', 'Eye', 'Leg', 'Cheek'],
        optionsOdia: ['ଲୁତୁର', 'ମେଦ', 'କାଟା', 'ଜୋଆ'],
        correctIndex: 1,
        explanation: 'We see the world around us using our Eyes.',
      ),
      EnglishQuizQuestion(
        question: 'What do we use to walk and run in the park?',
        questionOdia: 'ପାର୍କ ରେ ସେନ୍ ଓଡ଼ୋଃ ନିର ଲାଗି ଆବୁ ଚେନାଃ ଇସ୍ତେମାଲ ଏଆବୁ?',
        options: ['Head', 'Nose', 'Leg', 'Tongue'],
        optionsOdia: ['ବୋଃ', 'ମୁଆଁ', 'କାଟା', 'ଆଲାଙ୍ଗ'],
        correctIndex: 2,
        explanation: 'Our Legs help us walk, run, and jump.',
      ),
      EnglishQuizQuestion(
        question: 'What body part inside our mouth helps us taste sweet food?',
        questionOdia: 'ମୋଚା ଭିତର ରେ ଚେନ୍ ହଡ଼ମୋ ହିସା ଆବୁକେ ସିବିଲ ଜୋମ୍ ରେ ସାହାଯ୍ୟ ଏଆବୁ?',
        options: ['Skin', 'Tongue', 'Knee', 'Arm'],
        optionsOdia: ['ହର୍ତା', 'ଆଲାଙ୍ଗ', 'ମୁକୁଡ଼ି', 'ଗୋସୋ'],
        correctIndex: 1,
        explanation: 'Our Tongue tastes sweet, salty, and sour flavors.',
      ),
      EnglishQuizQuestion(
        question: 'What do we use to clap when we hear good music?',
        questionOdia: 'ବୁଗିନ୍ ଦୁରଙ୍ଗ ଆୟୁମ କେତେ ଥାପ୍‌ଡ଼ି ଲାଗି ଆବୁ ଚେନାଃ ଇସ୍ତେମାଲ ଏଆବୁ?',
        options: ['Foot', 'Hand', 'Ear', 'Nose'],
        optionsOdia: ['କାଟା', 'ତି', 'ଲୁତୁର', 'ମୁଆଁ'],
        correctIndex: 1,
        explanation: 'We clap together using both our Hands.',
      ),
    ],

    'Life Around Us': [
      EnglishQuizQuestion(
        question: 'Which grand animal has a big mane and is called King of the Jungle?',
        questionOdia: 'ଚେନ୍ ମାରାଙ୍ଗ ଜୀବୁ ଗାଡ଼ା ଜଙ୍ଗଲ ରା ରାଜା ମେନ୍ତେ କାଜିଓଆ?',
        options: ['Lion', 'Rabbit', 'Frog', 'Fish'],
        optionsOdia: ['କୁଲା', 'କୁଲୁ', 'ଚୋକେ', 'ହାଇ'],
        correctIndex: 0,
        explanation: 'The Lion is known as the King of the Jungle.',
      ),
      EnglishQuizQuestion(
        question: 'Which playful animal loves jumping from tree to tree?',
        questionOdia: 'ଚେନ୍ ଇନୁଙ୍ଗ ଜୀବୁ ମିଆଦ ଦାରୁ ଏତେ ଏଟାଃ ଦାରୁ ତେ କୁଦାଉ ଖୁସିଓଆ?',
        options: ['Fish', 'Monkey', 'Elephant', 'Frog'],
        optionsOdia: ['ହାଇ', 'ଗାଡ଼ି', 'ହାତୀ', 'ଚୋକେ'],
        correctIndex: 1,
        explanation: 'Monkeys swing and jump playful across tree branches.',
      ),
      EnglishQuizQuestion(
        question: 'Which animal lives in water and swims using fins?',
        questionOdia: 'ଚେନ୍ ଜୀବୁ ଦାଃ ରେ ତାହେନ୍ ଆୟ ଓଡ଼ୋଃ ପାଖନା ତେ ଉୟୁଙ୍ଗ ଏଆ?',
        options: ['Rabbit', 'Lion', 'Fish', 'Elephant'],
        optionsOdia: ['କୁଲୁ', 'କୁଲା', 'ହାଇ', 'ହାତୀ'],
        correctIndex: 2,
        explanation: 'Fish live in water and swim using their fins.',
      ),
      EnglishQuizQuestion(
        question: 'Which huge animal has a long trunk and big fan ears?',
        questionOdia: 'ଚେନ୍ ମାରାଙ୍ଗ ଜୀବୁ ରା ଜେଲେଙ୍ଗ ସୁଣ୍ଢ ଓଡ଼ୋଃ ବିଞ୍ଚଣା ଲେକାନ୍ ଲୁତୁର ମେନାଃ?',
        options: ['Elephant', 'Frog', 'Monkey', 'Lion'],
        optionsOdia: ['ହାତୀ', 'ଚୋକେ', 'ଗାଡ଼ି', 'କୁଲା'],
        correctIndex: 0,
        explanation: 'Elephants are huge animals with long trunks.',
      ),
      EnglishQuizQuestion(
        question: 'Which green animal hops around ponds and makes "croak" sounds?',
        questionOdia: 'ଚେନ୍ ହାରିଆର୍ ଜୀବୁ ବାନ୍ଧା ଚାରିପାଖେ ରେ କୁଦାଉଆ ଓଡ଼ୋଃ \'କ୍ରୋକ୍\' ଶବ୍ଦ ଏଆ?',
        options: ['Rabbit', 'Frog', 'Lion', 'Elephant'],
        optionsOdia: ['କୁଲୁ', 'ଚୋକେ', 'କୁଲା', 'ହାତୀ'],
        correctIndex: 1,
        explanation: 'Frogs hop around ponds and croak.',
      ),
      EnglishQuizQuestion(
        question: 'Which small fluffy animal has long ears and soft fur?',
        questionOdia: 'ଚେନ୍ ହୁଡିଙ୍ଗ ଲୁମାମ୍ ଜୀବୁ ରା ଜେଲେଙ୍ଗ ଲୁତୁର ଓଡ଼ୋଃ ଲୁମାମ୍ ଉବ୍ ମେନାଃ?',
        options: ['Elephant', 'Fish', 'Monkey', 'Rabbit'],
        optionsOdia: ['ହାତୀ', 'ହାଇ', 'ଗାଡ଼ି', 'କୁଲୁ'],
        correctIndex: 3,
        explanation: 'Rabbits are soft, fluffy animals with long ears.',
      ),
    ],

    'The Food We Eat': [
      EnglishQuizQuestion(
        question: 'What healthy white drink do cows give us?',
        questionOdia: 'ଗାଇ କୋ ଆବୁକେ ଚେନ୍ ବୁଗିନ୍ ପୁଣ୍ଡି ନୁ ଦାଃ କୋ ଏମାବୁଆ?',
        options: ['Milk', 'Honey', 'Chutney', 'Juice'],
        optionsOdia: ['ତୋଆ', 'ମହୁ', 'ଚଟଣି', 'ରସ'],
        correctIndex: 0,
        explanation: 'Cows give us fresh and healthy Milk.',
      ),
      EnglishQuizQuestion(
        question: 'Which sweet yellow fruit is known as the king of fruits?',
        questionOdia: 'ଚେନ୍ ସିବିଲ ସାସାଙ୍ଗ ଜୋ ଜୋ କୋ ରା ରାଜା ମେନ୍ତେ ସେବାସେଡ଼ାଓଆ?',
        options: ['Carrot', 'Mango', 'Brinjal', 'Roti'],
        optionsOdia: ['ଗାଜର', 'ଉଲି', 'ବାଇଗଣ', 'ରୁଟି'],
        correctIndex: 1,
        explanation: 'Mango is a delicious yellow fruit known as the king of fruits.',
      ),
      EnglishQuizQuestion(
        question: 'Who grows crops and food for everyone on the farm?',
        questionOdia: 'ଫାର୍ମ ରେ ସବେନ୍ କୋ ଲାଗି ଚାଷ ଓଡ଼ୋଃ ଜୋମ୍‌ଆ ଚିମିନ୍ ଓଲାଆ?',
        options: ['Doctor', 'Teacher', 'Farmer', 'Pilot'],
        optionsOdia: ['ଡାକ୍ତର', 'ମାଷ୍ଟର', 'ଚାଷୀ', 'ପାଇଲଟ୍'],
        correctIndex: 2,
        explanation: 'Farmers grow food crops and vegetables on farms.',
      ),
      EnglishQuizQuestion(
        question: 'What sweet food do honeybees make in beehives?',
        questionOdia: 'ଶୁଦ୍ଧ ଜୋମ୍‌ଆ ନେଲ୍ ଶୁଟି କୋ ଶୁଟି ଗୁଡ଼ା ରେ ଚିମିନ୍ ବେନାଓଆ?',
        options: ['Curd', 'Butter', 'Honey', 'Idli'],
        optionsOdia: ['ଦହି', 'ଗୋତୋମ', 'ମହୁ', 'ଇଡ୍‌ଲି'],
        correctIndex: 2,
        explanation: 'Honeybees make sweet natural Honey.',
      ),
      EnglishQuizQuestion(
        question: 'What meal do we eat in the morning when we wake up?',
        questionOdia: 'ସେତାଃ ରେ ଆବୁ ଏଭେନ୍ କେତେ ଚେନ୍ ଜୋମ୍‌ଆ ବୁ ଜୋମେଆ?',
        options: ['Dinner', 'Breakfast', 'Snack', 'Lunch'],
        optionsOdia: ['ଆୟୁବ ଜୋମ୍', 'ସେତାଃ ଜୋମ୍', 'ଜଲ୍‌ଖିଆ', 'ଟିକିନ୍ ଜୋମ୍'],
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
