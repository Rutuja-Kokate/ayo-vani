import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// App Name - Proper noun
  ///
  /// In en, this message translates to:
  /// **'AYOVAANI'**
  String get appName;

  /// Subject Name - Proper noun
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Subject Name - Proper noun
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get math;

  /// Subject Name - Proper noun
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get science;

  /// Subject Name - Proper noun
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// Subject Name - Proper noun
  ///
  /// In en, this message translates to:
  /// **'Social Science'**
  String get socialScience;

  /// Subject Name - Proper noun
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get computer;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get navLearn;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navTranslate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get navTranslate;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @btnSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get btnSubmit;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @btnBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get btnBack;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @btnTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get btnTryAgain;

  /// No description provided for @btnPlayAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get btnPlayAgain;

  /// No description provided for @btnDownloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get btnDownloadPdf;

  /// No description provided for @btnPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get btnPrint;

  /// No description provided for @btnFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get btnFilter;

  /// No description provided for @btnShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show Less'**
  String get btnShowLess;

  /// No description provided for @btnViewMoreChapters.
  ///
  /// In en, this message translates to:
  /// **'View More Chapters'**
  String get btnViewMoreChapters;

  /// No description provided for @btnListen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get btnListen;

  /// No description provided for @btnStartClassroom.
  ///
  /// In en, this message translates to:
  /// **'Start Classroom →'**
  String get btnStartClassroom;

  /// No description provided for @btnDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get btnDone;

  /// No description provided for @btnEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get btnEditProfile;

  /// No description provided for @btnLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get btnLogOut;

  /// No description provided for @btnGenerateContent.
  ///
  /// In en, this message translates to:
  /// **'✨ Generate Content'**
  String get btnGenerateContent;

  /// No description provided for @btnGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get btnGenerating;

  /// No description provided for @btnExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get btnExplore;

  /// No description provided for @btnStartLearning.
  ///
  /// In en, this message translates to:
  /// **'Start Learning'**
  String get btnStartLearning;

  /// No description provided for @btnEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btnEdit;

  /// No description provided for @btnReviewNow.
  ///
  /// In en, this message translates to:
  /// **'Review Now'**
  String get btnReviewNow;

  /// No description provided for @labelSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get labelSearch;

  /// No description provided for @labelChapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get labelChapters;

  /// No description provided for @labelTotalChapters.
  ///
  /// In en, this message translates to:
  /// **'Total Chapters'**
  String get labelTotalChapters;

  /// No description provided for @labelSubjectStatus.
  ///
  /// In en, this message translates to:
  /// **'Subject Status'**
  String get labelSubjectStatus;

  /// No description provided for @labelFunctional.
  ///
  /// In en, this message translates to:
  /// **'Functional'**
  String get labelFunctional;

  /// No description provided for @labelAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get labelAvailable;

  /// No description provided for @labelComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get labelComingSoon;

  /// No description provided for @labelOfflineReady.
  ///
  /// In en, this message translates to:
  /// **'Offline Ready'**
  String get labelOfflineReady;

  /// No description provided for @labelScore.
  ///
  /// In en, this message translates to:
  /// **'Score:'**
  String get labelScore;

  /// No description provided for @labelWellDone.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get labelWellDone;

  /// No description provided for @labelQuizCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz Completed!'**
  String get labelQuizCompleted;

  /// No description provided for @labelQuestCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quest Completed!'**
  String get labelQuestCompleted;

  /// No description provided for @labelTimesUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get labelTimesUp;

  /// No description provided for @labelAnswer.
  ///
  /// In en, this message translates to:
  /// **'Answer:'**
  String get labelAnswer;

  /// No description provided for @labelAnswerKey.
  ///
  /// In en, this message translates to:
  /// **'Answer key:'**
  String get labelAnswerKey;

  /// No description provided for @labelCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer:'**
  String get labelCorrectAnswer;

  /// No description provided for @labelInstructionLanguage.
  ///
  /// In en, this message translates to:
  /// **'Instruction Language'**
  String get labelInstructionLanguage;

  /// No description provided for @labelMotherTongue.
  ///
  /// In en, this message translates to:
  /// **'Mother Tongue'**
  String get labelMotherTongue;

  /// No description provided for @countModules.
  ///
  /// In en, this message translates to:
  /// **'{count} Modules'**
  String countModules(int count);

  /// No description provided for @countSubjects.
  ///
  /// In en, this message translates to:
  /// **'{count} Subjects'**
  String countSubjects(int count);

  /// No description provided for @labelClassWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Class {number}'**
  String labelClassWithNumber(String number);

  /// No description provided for @badgeRealTime.
  ///
  /// In en, this message translates to:
  /// **'Real-Time'**
  String get badgeRealTime;

  /// No description provided for @badgeAssessments.
  ///
  /// In en, this message translates to:
  /// **'Assessments'**
  String get badgeAssessments;

  /// No description provided for @badgeContinuity.
  ///
  /// In en, this message translates to:
  /// **'Continuity'**
  String get badgeContinuity;

  /// No description provided for @hintSearchChapters.
  ///
  /// In en, this message translates to:
  /// **'Search chapters...'**
  String get hintSearchChapters;

  /// No description provided for @tagGrade1.
  ///
  /// In en, this message translates to:
  /// **'Grade 1 | Learn, Listen, Speak'**
  String get tagGrade1;

  /// No description provided for @tagEnglishSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore foundational English chapters, audio vocabulary & activities.'**
  String get tagEnglishSubtitle;

  /// No description provided for @cardKeepLearningTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep Learning!'**
  String get cardKeepLearningTitle;

  /// No description provided for @cardKeepLearningSub.
  ///
  /// In en, this message translates to:
  /// **'Practice flashcards, games & worksheets with your students every day.'**
  String get cardKeepLearningSub;

  /// No description provided for @tabFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get tabFlashcards;

  /// No description provided for @tabWorksheets.
  ///
  /// In en, this message translates to:
  /// **'Worksheets'**
  String get tabWorksheets;

  /// No description provided for @tabQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get tabQuizzes;

  /// No description provided for @tabGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get tabGames;

  /// No description provided for @flashcardTapReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal meaning / translation'**
  String get flashcardTapReveal;

  /// No description provided for @flashcardTapFlip.
  ///
  /// In en, this message translates to:
  /// **'Tap to flip back'**
  String get flashcardTapFlip;

  /// No description provided for @worksheetTabTracing.
  ///
  /// In en, this message translates to:
  /// **'1. Tracing & Writing'**
  String get worksheetTabTracing;

  /// No description provided for @worksheetTabMatching.
  ///
  /// In en, this message translates to:
  /// **'2. Matching & Drawing'**
  String get worksheetTabMatching;

  /// No description provided for @worksheetTabRiddles.
  ///
  /// In en, this message translates to:
  /// **'3. Riddles'**
  String get worksheetTabRiddles;

  /// No description provided for @worksheetTabOddOneOut.
  ///
  /// In en, this message translates to:
  /// **'4. Odd One Out'**
  String get worksheetTabOddOneOut;

  /// No description provided for @worksheetExTrace.
  ///
  /// In en, this message translates to:
  /// **'Exercise: Trace and write the words below'**
  String get worksheetExTrace;

  /// No description provided for @worksheetExMatchSentence.
  ///
  /// In en, this message translates to:
  /// **'Exercise 1: Draw lines to match each picture to its sentence'**
  String get worksheetExMatchSentence;

  /// No description provided for @worksheetExFunWithWords.
  ///
  /// In en, this message translates to:
  /// **'Exercise 2: Fun with Words - Read the syllables'**
  String get worksheetExFunWithWords;

  /// No description provided for @worksheetExRiddles.
  ///
  /// In en, this message translates to:
  /// **'Exercise: Read the riddles and write the answers below'**
  String get worksheetExRiddles;

  /// No description provided for @worksheetExOddOneOut.
  ///
  /// In en, this message translates to:
  /// **'Exercise: Circle the odd one out in each row below'**
  String get worksheetExOddOneOut;

  /// No description provided for @gameHandyTitle.
  ///
  /// In en, this message translates to:
  /// **'Handy Actions Match'**
  String get gameHandyTitle;

  /// No description provided for @gameFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Power Sorting'**
  String get gameFoodTitle;

  /// No description provided for @gameQuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore & Find Quest'**
  String get gameQuestTitle;

  /// No description provided for @gameSelectMundari.
  ///
  /// In en, this message translates to:
  /// **'Select the matching Mundari word:'**
  String get gameSelectMundari;

  /// No description provided for @gameFindAnimals.
  ///
  /// In en, this message translates to:
  /// **'Find All 6 Animals:'**
  String get gameFindAnimals;

  /// No description provided for @labelClasses.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get labelClasses;

  /// No description provided for @classBalvatika.
  ///
  /// In en, this message translates to:
  /// **'Balvatika'**
  String get classBalvatika;

  /// No description provided for @classFirst.
  ///
  /// In en, this message translates to:
  /// **'First'**
  String get classFirst;

  /// No description provided for @classSecond.
  ///
  /// In en, this message translates to:
  /// **'Second'**
  String get classSecond;

  /// No description provided for @classThird.
  ///
  /// In en, this message translates to:
  /// **'Third'**
  String get classThird;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, Teacher'**
  String get homeGreeting;

  /// No description provided for @homeSubGreeting.
  ///
  /// In en, this message translates to:
  /// **'Ready to inspire today?'**
  String get homeSubGreeting;

  /// No description provided for @homeContentSynced.
  ///
  /// In en, this message translates to:
  /// **'Content synced today.'**
  String get homeContentSynced;

  /// No description provided for @homeLetsStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start'**
  String get homeLetsStart;

  /// No description provided for @homeFeaturedLessonTitle.
  ///
  /// In en, this message translates to:
  /// **'Numbers 1–20'**
  String get homeFeaturedLessonTitle;

  /// No description provided for @homeStatsTodayCompleted.
  ///
  /// In en, this message translates to:
  /// **'Today: {count} lessons completed'**
  String homeStatsTodayCompleted(int count);

  /// No description provided for @homeStatsWeeklyTotal.
  ///
  /// In en, this message translates to:
  /// **'This week: {count} lessons'**
  String homeStatsWeeklyTotal(int count);

  /// No description provided for @homeNextLessonPreview.
  ///
  /// In en, this message translates to:
  /// **'Next lesson: Addition Practice'**
  String get homeNextLessonPreview;

  /// No description provided for @homeHeaderLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync: Today 9:00 AM'**
  String get homeHeaderLastSync;

  /// No description provided for @classSubtitleBalvatika.
  ///
  /// In en, this message translates to:
  /// **'3 Modules'**
  String get classSubtitleBalvatika;

  /// No description provided for @classSubtitleFirst.
  ///
  /// In en, this message translates to:
  /// **'12 Lessons'**
  String get classSubtitleFirst;

  /// No description provided for @classSubtitleSecond.
  ///
  /// In en, this message translates to:
  /// **'12 Lessons'**
  String get classSubtitleSecond;

  /// No description provided for @classSubtitleThird.
  ///
  /// In en, this message translates to:
  /// **'12 Lessons'**
  String get classSubtitleThird;

  /// No description provided for @balvatikaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation Stage | Learn, Listen, Speak'**
  String get balvatikaSubtitle;

  /// No description provided for @balvatikaDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore foundation stage learning modules and activities.'**
  String get balvatikaDesc;

  /// No description provided for @balvatikaComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Learning content is coming soon.\nFoundational language modules, stories, and sensory games are currently in development.'**
  String get balvatikaComingSoonMessage;

  /// No description provided for @balvatikaModulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation Modules'**
  String get balvatikaModulesTitle;

  /// No description provided for @balvatikaCurriculumModules.
  ///
  /// In en, this message translates to:
  /// **'Curriculum Modules'**
  String get balvatikaCurriculumModules;

  /// No description provided for @balvatikaNoticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Early Learning Focus'**
  String get balvatikaNoticeTitle;

  /// No description provided for @balvatikaNoticeDesc.
  ///
  /// In en, this message translates to:
  /// **'Balvatika content is currently being curated in regional tribal languages.'**
  String get balvatikaNoticeDesc;

  /// No description provided for @balvatikaModule1Title.
  ///
  /// In en, this message translates to:
  /// **'Early Literacy & Rhymes'**
  String get balvatikaModule1Title;

  /// No description provided for @balvatikaModule1Sub.
  ///
  /// In en, this message translates to:
  /// **'Nursery rhymes, animal sounds, picture-words, folklore & oral storytelling'**
  String get balvatikaModule1Sub;

  /// No description provided for @balvatikaModule2Title.
  ///
  /// In en, this message translates to:
  /// **'Early Numeracy & Shapes'**
  String get balvatikaModule2Title;

  /// No description provided for @balvatikaModule2Sub.
  ///
  /// In en, this message translates to:
  /// **'Counting 1–10, everyday shape recognition, big/small, colors & rhymes'**
  String get balvatikaModule2Sub;

  /// No description provided for @balvatikaModule3Title.
  ///
  /// In en, this message translates to:
  /// **'Sensory & World Play'**
  String get balvatikaModule3Title;

  /// No description provided for @balvatikaModule3Sub.
  ///
  /// In en, this message translates to:
  /// **'Five senses, body parts, family members, weather & nature exploration'**
  String get balvatikaModule3Sub;

  /// No description provided for @balvatikaTopicRhymesTitle.
  ///
  /// In en, this message translates to:
  /// **'Nursery Rhymes & Lullabies'**
  String get balvatikaTopicRhymesTitle;

  /// No description provided for @balvatikaTopicRhymesDesc.
  ///
  /// In en, this message translates to:
  /// **'Listen to rhymes in Hindi and regional languages with audio narration'**
  String get balvatikaTopicRhymesDesc;

  /// No description provided for @balvatikaTopicSoundsTitle.
  ///
  /// In en, this message translates to:
  /// **'Animal & Nature Sounds'**
  String get balvatikaTopicSoundsTitle;

  /// No description provided for @balvatikaTopicSoundsDesc.
  ///
  /// In en, this message translates to:
  /// **'Match pictures with animal and nature sounds (cow, dog, rain, wind)'**
  String get balvatikaTopicSoundsDesc;

  /// No description provided for @balvatikaTopicPictureWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Picture-Word Association'**
  String get balvatikaTopicPictureWordsTitle;

  /// No description provided for @balvatikaTopicPictureWordsDesc.
  ///
  /// In en, this message translates to:
  /// **'Associate everyday objects with words in both Hindi and tribal languages'**
  String get balvatikaTopicPictureWordsDesc;

  /// No description provided for @balvatikaTopicStoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Oral Storytelling & Folklore'**
  String get balvatikaTopicStoriesTitle;

  /// No description provided for @balvatikaTopicStoriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Short 1-2 minute stories with repetition and simple moral lessons'**
  String get balvatikaTopicStoriesDesc;

  /// No description provided for @balvatikaTopicListenRepeatTitle.
  ///
  /// In en, this message translates to:
  /// **'Listen & Repeat Practice'**
  String get balvatikaTopicListenRepeatTitle;

  /// No description provided for @balvatikaTopicListenRepeatDesc.
  ///
  /// In en, this message translates to:
  /// **'Audio prompt exercises for children to repeat and practice pronunciation'**
  String get balvatikaTopicListenRepeatDesc;

  /// No description provided for @balvatikaTopicRhymingWordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Simple Rhyming Words'**
  String get balvatikaTopicRhymingWordsTitle;

  /// No description provided for @balvatikaTopicRhymingWordsDesc.
  ///
  /// In en, this message translates to:
  /// **'Fun rhyming word pairs in Hindi and regional tribal languages'**
  String get balvatikaTopicRhymingWordsDesc;

  /// No description provided for @balvatikaTopicCountingTitle.
  ///
  /// In en, this message translates to:
  /// **'Counting 1 to 10'**
  String get balvatikaTopicCountingTitle;

  /// No description provided for @balvatikaTopicCountingDesc.
  ///
  /// In en, this message translates to:
  /// **'Count 1–10 using fingers, fruits, stones, and local objects'**
  String get balvatikaTopicCountingDesc;

  /// No description provided for @balvatikaTopicShapesTitle.
  ///
  /// In en, this message translates to:
  /// **'Shapes in Everyday Objects'**
  String get balvatikaTopicShapesTitle;

  /// No description provided for @balvatikaTopicShapesDesc.
  ///
  /// In en, this message translates to:
  /// **'Recognize circle (roti), square (window), and triangle (roof)'**
  String get balvatikaTopicShapesDesc;

  /// No description provided for @balvatikaTopicComparisonsTitle.
  ///
  /// In en, this message translates to:
  /// **'Big/Small & More/Less'**
  String get balvatikaTopicComparisonsTitle;

  /// No description provided for @balvatikaTopicComparisonsDesc.
  ///
  /// In en, this message translates to:
  /// **'Compare sizes and quantities using visual object cards'**
  String get balvatikaTopicComparisonsDesc;

  /// No description provided for @balvatikaTopicColorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Primary Colors & Nature'**
  String get balvatikaTopicColorsTitle;

  /// No description provided for @balvatikaTopicColorsDesc.
  ///
  /// In en, this message translates to:
  /// **'Recognize red, yellow, blue, and green through fruits and flowers'**
  String get balvatikaTopicColorsDesc;

  /// No description provided for @balvatikaTopicSortingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sorting & Grouping'**
  String get balvatikaTopicSortingTitle;

  /// No description provided for @balvatikaTopicSortingDesc.
  ///
  /// In en, this message translates to:
  /// **'Group objects by shape, size, or color'**
  String get balvatikaTopicSortingDesc;

  /// No description provided for @balvatikaTopicNumberRhymesTitle.
  ///
  /// In en, this message translates to:
  /// **'Number Rhymes & Songs'**
  String get balvatikaTopicNumberRhymesTitle;

  /// No description provided for @balvatikaTopicNumberRhymesDesc.
  ///
  /// In en, this message translates to:
  /// **'Catchy counting songs and number rhymes in regional languages'**
  String get balvatikaTopicNumberRhymesDesc;

  /// No description provided for @balvatikaTopicFiveSensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Five Senses Exploration'**
  String get balvatikaTopicFiveSensesTitle;

  /// No description provided for @balvatikaTopicFiveSensesDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore touch, smell, taste, sound, and sight with everyday items'**
  String get balvatikaTopicFiveSensesDesc;

  /// No description provided for @balvatikaTopicBodyPartsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Body Parts'**
  String get balvatikaTopicBodyPartsTitle;

  /// No description provided for @balvatikaTopicBodyPartsDesc.
  ///
  /// In en, this message translates to:
  /// **'Name and identify body parts through songs, visuals, and audio games'**
  String get balvatikaTopicBodyPartsDesc;

  /// No description provided for @balvatikaTopicFamilyTitle.
  ///
  /// In en, this message translates to:
  /// **'Family & Relationships'**
  String get balvatikaTopicFamilyTitle;

  /// No description provided for @balvatikaTopicFamilyDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn names for Mother, Father, Brother, Sister in both languages'**
  String get balvatikaTopicFamilyDesc;

  /// No description provided for @balvatikaTopicAnimalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Animals Around Us'**
  String get balvatikaTopicAnimalsTitle;

  /// No description provided for @balvatikaTopicAnimalsDesc.
  ///
  /// In en, this message translates to:
  /// **'Farm and forest animals, their names, habitats, and sounds'**
  String get balvatikaTopicAnimalsDesc;

  /// No description provided for @balvatikaTopicWeatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather & Seasons'**
  String get balvatikaTopicWeatherTitle;

  /// No description provided for @balvatikaTopicWeatherDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily weather observations (sunny, rainy, cold) and nature play'**
  String get balvatikaTopicWeatherDesc;

  /// No description provided for @balvatikaTopicRolePlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Role Play & Daily Life'**
  String get balvatikaTopicRolePlayTitle;

  /// No description provided for @balvatikaTopicRolePlayDesc.
  ///
  /// In en, this message translates to:
  /// **'Simple scenarios: cooking, farming, and visiting the local market'**
  String get balvatikaTopicRolePlayDesc;

  /// No description provided for @tabListenLearn.
  ///
  /// In en, this message translates to:
  /// **'Listen & Learn'**
  String get tabListenLearn;

  /// No description provided for @tabPictureWord.
  ///
  /// In en, this message translates to:
  /// **'Picture & Sound'**
  String get tabPictureWord;

  /// No description provided for @tabPlayPractice.
  ///
  /// In en, this message translates to:
  /// **'Play & Practice'**
  String get tabPlayPractice;

  /// No description provided for @tabListenRepeat.
  ///
  /// In en, this message translates to:
  /// **'Listen & Repeat'**
  String get tabListenRepeat;

  /// No description provided for @btnPlayStory.
  ///
  /// In en, this message translates to:
  /// **'Play Story Audio'**
  String get btnPlayStory;

  /// No description provided for @btnStopAudio.
  ///
  /// In en, this message translates to:
  /// **'Stop Audio'**
  String get btnStopAudio;

  /// No description provided for @labelMoral.
  ///
  /// In en, this message translates to:
  /// **'Moral:'**
  String get labelMoral;

  /// No description provided for @labelTapAudio.
  ///
  /// In en, this message translates to:
  /// **'Tap card to listen to pronunciation'**
  String get labelTapAudio;

  /// No description provided for @labelListenPrompt.
  ///
  /// In en, this message translates to:
  /// **'Listen to the prompt and repeat out loud:'**
  String get labelListenPrompt;

  /// No description provided for @btnRecordRepeat.
  ///
  /// In en, this message translates to:
  /// **'Tap to Repeat'**
  String get btnRecordRepeat;

  /// No description provided for @labelPlaceholderNotice.
  ///
  /// In en, this message translates to:
  /// **'Audio/Image assets are placeholders and ready for content drop-in.'**
  String get labelPlaceholderNotice;

  /// No description provided for @firstSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grade 1 | Learn, Listen, Speak'**
  String get firstSubtitle;

  /// No description provided for @firstDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore Grade 1 learning modules and activities.'**
  String get firstDesc;

  /// No description provided for @firstModulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Grade 1 Modules'**
  String get firstModulesTitle;

  /// No description provided for @secondSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grade 2 | Learn, Listen, Speak'**
  String get secondSubtitle;

  /// No description provided for @secondDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore Grade 2 learning modules and activities.'**
  String get secondDesc;

  /// No description provided for @thirdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Grade 3 | Learn, Listen, Speak'**
  String get thirdSubtitle;

  /// No description provided for @thirdDesc.
  ///
  /// In en, this message translates to:
  /// **'Explore Grade 3 learning modules and activities.'**
  String get thirdDesc;

  /// No description provided for @chapterTitle.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get chapterTitle;

  /// No description provided for @topicsLabel.
  ///
  /// In en, this message translates to:
  /// **'Topics:'**
  String get topicsLabel;

  /// No description provided for @lessonLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson:'**
  String get lessonLabel;

  /// No description provided for @chapterFlashcardsSub.
  ///
  /// In en, this message translates to:
  /// **'Interactive visual aids'**
  String get chapterFlashcardsSub;

  /// No description provided for @chapterWorksheetsSub.
  ///
  /// In en, this message translates to:
  /// **'Downloadable exercises'**
  String get chapterWorksheetsSub;

  /// No description provided for @chapterGamesSub.
  ///
  /// In en, this message translates to:
  /// **'Fun matching & sorting activities'**
  String get chapterGamesSub;

  /// No description provided for @chapterQuizzesSub.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge'**
  String get chapterQuizzesSub;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @practiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceLabel;

  /// No description provided for @quizPreviewQuestion.
  ///
  /// In en, this message translates to:
  /// **'Key chapter question?'**
  String get quizPreviewQuestion;

  /// No description provided for @quizPreviewFruitQuestion.
  ///
  /// In en, this message translates to:
  /// **'Which is a red fruit?'**
  String get quizPreviewFruitQuestion;

  /// No description provided for @optionA.
  ///
  /// In en, this message translates to:
  /// **'Option A'**
  String get optionA;

  /// No description provided for @optionB.
  ///
  /// In en, this message translates to:
  /// **'Option B'**
  String get optionB;

  /// No description provided for @optionC.
  ///
  /// In en, this message translates to:
  /// **'Option C'**
  String get optionC;

  /// No description provided for @learnTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn & Teach'**
  String get learnTitle;

  /// No description provided for @learnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your classroom learning path'**
  String get learnSubtitle;

  /// No description provided for @learnTeacherMode.
  ///
  /// In en, this message translates to:
  /// **'Teacher-Led Learning'**
  String get learnTeacherMode;

  /// No description provided for @learnTeacherSub.
  ///
  /// In en, this message translates to:
  /// **'Curriculum modules, lesson plans & activities for classroom teaching'**
  String get learnTeacherSub;

  /// No description provided for @learnStudentMode.
  ///
  /// In en, this message translates to:
  /// **'Student Practice & Levels'**
  String get learnStudentMode;

  /// No description provided for @learnStudentSub.
  ///
  /// In en, this message translates to:
  /// **'Interactive phased practice, questions & oral response activities'**
  String get learnStudentSub;

  /// No description provided for @learnForTeachers.
  ///
  /// In en, this message translates to:
  /// **'For Teachers'**
  String get learnForTeachers;

  /// No description provided for @learnTeacherSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan, prepare & teach'**
  String get learnTeacherSubtitle;

  /// No description provided for @learnTeacherTags.
  ///
  /// In en, this message translates to:
  /// **'Lessons • Worksheets • Quizzes • Translation'**
  String get learnTeacherTags;

  /// No description provided for @learnForStudents.
  ///
  /// In en, this message translates to:
  /// **'For Students'**
  String get learnForStudents;

  /// No description provided for @learnStudentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn, practice & play'**
  String get learnStudentSubtitle;

  /// No description provided for @learnStudentTags.
  ///
  /// In en, this message translates to:
  /// **'Lessons • Flashcards • Games • Activities'**
  String get learnStudentTags;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher Profile & Settings'**
  String get profileTitle;

  /// No description provided for @profileSub.
  ///
  /// In en, this message translates to:
  /// **'Classroom parameters & offline management'**
  String get profileSub;

  /// No description provided for @profileAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Interface Language'**
  String get profileAppLanguage;

  /// No description provided for @profileAppLanguageSub.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language for the app interface'**
  String get profileAppLanguageSub;

  /// No description provided for @profileClassroomLangs.
  ///
  /// In en, this message translates to:
  /// **'Classroom Languages'**
  String get profileClassroomLangs;

  /// No description provided for @profileClassroomLangsSub.
  ///
  /// In en, this message translates to:
  /// **'Configure default mother-tongue and medium of instruction'**
  String get profileClassroomLangsSub;

  /// No description provided for @profileMediumLabel.
  ///
  /// In en, this message translates to:
  /// **'Medium of Instruction'**
  String get profileMediumLabel;

  /// No description provided for @profileMotherTongueLabel.
  ///
  /// In en, this message translates to:
  /// **'Mother Tongue / Regional Dialect'**
  String get profileMotherTongueLabel;

  /// No description provided for @profileOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Content & Storage'**
  String get profileOfflineTitle;

  /// No description provided for @profileOfflineSub.
  ///
  /// In en, this message translates to:
  /// **'Download lessons, audio pronunciations, and worksheets for zero-internet use'**
  String get profileOfflineSub;

  /// No description provided for @profileOfflinePack.
  ///
  /// In en, this message translates to:
  /// **'Offline Pack: Grade 1 Multilingual'**
  String get profileOfflinePack;

  /// No description provided for @profileAutoSync.
  ///
  /// In en, this message translates to:
  /// **'Auto-sync when Wi-Fi is available'**
  String get profileAutoSync;

  /// No description provided for @profileAutoSyncSub.
  ///
  /// In en, this message translates to:
  /// **'Background synchronization of teacher logs'**
  String get profileAutoSyncSub;

  /// No description provided for @profileAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Human-in-the-Loop AI Translation'**
  String get profileAiTitle;

  /// No description provided for @profileAiSub.
  ///
  /// In en, this message translates to:
  /// **'Teacher verification before classroom broadcast'**
  String get profileAiSub;

  /// No description provided for @profileRequireApproval.
  ///
  /// In en, this message translates to:
  /// **'Require Teacher Approval for New Words'**
  String get profileRequireApproval;

  /// No description provided for @profileRequireApprovalSub.
  ///
  /// In en, this message translates to:
  /// **'Flag AI-translated phrases for teacher review before adding to student flashcards'**
  String get profileRequireApprovalSub;

  /// No description provided for @profileSaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Classroom Settings'**
  String get profileSaveSettings;

  /// No description provided for @profileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher Profile'**
  String get profileScreenTitle;

  /// No description provided for @profileScreenSub.
  ///
  /// In en, this message translates to:
  /// **'Classroom settings, offline sync status, and educator preferences.'**
  String get profileScreenSub;

  /// No description provided for @profileTeacherName.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get profileTeacherName;

  /// No description provided for @profileTeacherRole.
  ///
  /// In en, this message translates to:
  /// **'Classroom Educator'**
  String get profileTeacherRole;

  /// No description provided for @profileTeacherFocus.
  ///
  /// In en, this message translates to:
  /// **'Primary Section • Tribal Language Focus'**
  String get profileTeacherFocus;

  /// No description provided for @profileLessonsSynced.
  ///
  /// In en, this message translates to:
  /// **'24 lessons'**
  String get profileLessonsSynced;

  /// No description provided for @profileLessonsOffline.
  ///
  /// In en, this message translates to:
  /// **'24 lessons available offline'**
  String get profileLessonsOffline;

  /// No description provided for @profileMyClassroom.
  ///
  /// In en, this message translates to:
  /// **'My Classroom'**
  String get profileMyClassroom;

  /// No description provided for @profileCurrentClass.
  ///
  /// In en, this message translates to:
  /// **'Current Class'**
  String get profileCurrentClass;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get profileStudents;

  /// No description provided for @profileStudentsCount.
  ///
  /// In en, this message translates to:
  /// **'32 students'**
  String get profileStudentsCount;

  /// No description provided for @profileLanguageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get profileLanguageSettings;

  /// No description provided for @profileTeachingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Teaching Language'**
  String get profileTeachingLanguage;

  /// No description provided for @profileDownloadedContent.
  ///
  /// In en, this message translates to:
  /// **'Downloaded Content'**
  String get profileDownloadedContent;

  /// No description provided for @profileAvailableOffline.
  ///
  /// In en, this message translates to:
  /// **'Available Offline'**
  String get profileAvailableOffline;

  /// No description provided for @profileStorageUsed.
  ///
  /// In en, this message translates to:
  /// **'Storage Used'**
  String get profileStorageUsed;

  /// No description provided for @profileSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettingsSection;

  /// No description provided for @profileNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotificationsTitle;

  /// No description provided for @profileNotificationsSub.
  ///
  /// In en, this message translates to:
  /// **'Classroom alerts & reminder updates'**
  String get profileNotificationsSub;

  /// No description provided for @profileOfflineSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Sync'**
  String get profileOfflineSyncTitle;

  /// No description provided for @profileOfflineSyncSub.
  ///
  /// In en, this message translates to:
  /// **'Sync lessons when Wi-Fi is available'**
  String get profileOfflineSyncSub;

  /// No description provided for @profileHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpTitle;

  /// No description provided for @profileHelpSub.
  ///
  /// In en, this message translates to:
  /// **'Teacher guide & classroom FAQs'**
  String get profileHelpSub;

  /// No description provided for @profileAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About AYOVAANI'**
  String get profileAboutTitle;

  /// No description provided for @translateTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Speech Translation'**
  String get translateTitle;

  /// No description provided for @translateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Speak in Hindi, listen & read in Mundari'**
  String get translateSubtitle;

  /// No description provided for @translateTapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap microphone and speak'**
  String get translateTapToSpeak;

  /// No description provided for @translateListening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get translateListening;

  /// No description provided for @translateProcessing.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get translateProcessing;

  /// No description provided for @translateMundariOutput.
  ///
  /// In en, this message translates to:
  /// **'Mundari Audio Output'**
  String get translateMundariOutput;

  /// No description provided for @translateReplay.
  ///
  /// In en, this message translates to:
  /// **'Replay Audio'**
  String get translateReplay;

  /// No description provided for @translateSourcePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Speak or type to begin...'**
  String get translateSourcePlaceholder;

  /// No description provided for @translateTargetPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Translation will appear here...'**
  String get translateTargetPlaceholder;

  /// No description provided for @tagOfflineTranslation.
  ///
  /// In en, this message translates to:
  /// **'Offline Translation'**
  String get tagOfflineTranslation;

  /// No description provided for @btnCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get btnCopy;

  /// No description provided for @btnShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get btnShare;

  /// No description provided for @btnTypeInstead.
  ///
  /// In en, this message translates to:
  /// **'Type Instead'**
  String get btnTypeInstead;

  /// No description provided for @translateRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Translations'**
  String get translateRecentTitle;

  /// No description provided for @translateRecentPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your recent translations will appear here'**
  String get translateRecentPlaceholder;

  /// No description provided for @typeDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Type Hindi Phrase'**
  String get typeDialogTitle;

  /// No description provided for @typeDialogHint.
  ///
  /// In en, this message translates to:
  /// **'Enter text here...'**
  String get typeDialogHint;

  /// No description provided for @msgCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get msgCopied;

  /// No description provided for @msgShared.
  ///
  /// In en, this message translates to:
  /// **'Sharing translation...'**
  String get msgShared;

  /// No description provided for @toolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher Tools'**
  String get toolsTitle;

  /// No description provided for @toolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Utilities & resources for the classroom'**
  String get toolsSubtitle;

  /// No description provided for @toolsLiveTranslate.
  ///
  /// In en, this message translates to:
  /// **'Live Translate'**
  String get toolsLiveTranslate;

  /// No description provided for @toolsLiveTranslateDesc.
  ///
  /// In en, this message translates to:
  /// **'Real-time teacher-student dialogue with mother-tongue audio & text display.'**
  String get toolsLiveTranslateDesc;

  /// No description provided for @toolsWorksheetGen.
  ///
  /// In en, this message translates to:
  /// **'Worksheet Generator'**
  String get toolsWorksheetGen;

  /// No description provided for @toolsWorksheetGenDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate printable and digital multilingual worksheets with matching & vocabulary.'**
  String get toolsWorksheetGenDesc;

  /// No description provided for @toolsQuizMaker.
  ///
  /// In en, this message translates to:
  /// **'Quiz Builder'**
  String get toolsQuizMaker;

  /// No description provided for @toolsQuizMakerDesc.
  ///
  /// In en, this message translates to:
  /// **'Build interactive comprehension quizzes, listening tests, and oral evaluations.'**
  String get toolsQuizMakerDesc;

  /// No description provided for @toolsContinuityTitle.
  ///
  /// In en, this message translates to:
  /// **'Learning Continuity Mode'**
  String get toolsContinuityTitle;

  /// No description provided for @toolsContinuityDesc.
  ///
  /// In en, this message translates to:
  /// **'Pre-packaged autonomous learning modules when the teacher is unavailable.'**
  String get toolsContinuityDesc;

  /// No description provided for @toolsReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Human-in-the-Loop Translation Notice'**
  String get toolsReviewTitle;

  /// No description provided for @toolsReviewNoticeMsg.
  ///
  /// In en, this message translates to:
  /// **'2 AI-suggested Gondi translations require teacher confirmation before printing.'**
  String get toolsReviewNoticeMsg;

  /// No description provided for @studentLevelsTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Learning Levels'**
  String get studentLevelsTitle;

  /// No description provided for @studentLevelsSub.
  ///
  /// In en, this message translates to:
  /// **'Phased oral practice & response activities'**
  String get studentLevelsSub;

  /// No description provided for @phase1Title.
  ///
  /// In en, this message translates to:
  /// **'Phase 1: Basic Listening & Speaking'**
  String get phase1Title;

  /// No description provided for @phase2Title.
  ///
  /// In en, this message translates to:
  /// **'Phase 2: Word & Sentence Practice'**
  String get phase2Title;

  /// No description provided for @phase3Title.
  ///
  /// In en, this message translates to:
  /// **'Phase 3: Interactive Stories & Q&A'**
  String get phase3Title;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
