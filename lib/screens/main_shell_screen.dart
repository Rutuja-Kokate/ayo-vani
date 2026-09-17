import 'package:flutter/material.dart';
import '../widgets/ayo_bottom_nav_bar.dart';
import '../widgets/ayo_screen_background.dart';
import 'balvatika/balvatika_screen.dart';
import 'first/first_screen.dart';
import 'home/home_screen.dart';
import 'learn/learn_screen.dart';
import 'learn/student_levels_screen.dart';
import 'learn/teacher_levels_screen.dart';
import 'live_translate/live_translate_screen.dart';
import 'profile/profile_screen.dart';
import 'second/second_screen.dart';
import 'third/third_screen.dart';

/// Main adaptive navigation shell for AYOVAANI.
///
/// Features:
/// - Fixed bottom navigation bar with 4 items: Home, Learn, Translate, Profile
/// - Persistent bottom navigation bar across mobile and tablet
/// - Preserves state across screens using [IndexedStack]
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToLiveTranslate() {
    _onDestinationSelected(2);
  }

  void _navigateToBalvatika() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BalvatikaScreen(
          onNavigateTab: (index) {
            _onDestinationSelected(index);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _navigateToStudentLevels() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => StudentLevelsScreen(
          onNavigateTab: (index) {
            _onDestinationSelected(index);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _navigateToFirst() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => FirstScreen(
          onNavigateTab: (index) {
            _onDestinationSelected(index);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _navigateToSecond() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SecondScreen(
          onNavigateTab: (index) {
            _onDestinationSelected(index);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _navigateToThird() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ThirdScreen(
          onNavigateTab: (index) {
            _onDestinationSelected(index);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _navigateToTeacherLevels() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TeacherLevelsScreen(
          onNavigateTab: (index) {
            _onDestinationSelected(index);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      HomeScreen(
        onNavigateToLearn: () => _onDestinationSelected(1),
        onNavigateToTranslate: _navigateToLiveTranslate,
        onNavigateToProfile: () => _onDestinationSelected(3),
        onNavigateToBalvatika: _navigateToBalvatika,
        onNavigateToFirst: _navigateToFirst,
        onNavigateToSecond: _navigateToSecond,
        onNavigateToThird: _navigateToThird,
      ),
      LearnScreen(
        isShellTab: true,
        onBack: () => _onDestinationSelected(0),
        onNavigateToTeacher: _navigateToTeacherLevels,
        onNavigateToStudent: _navigateToStudentLevels,
        onNavigateToBalvatika: _navigateToBalvatika,
        onNavigateToFirst: _navigateToFirst,
        onNavigateToSecond: _navigateToSecond,
        onNavigateToThird: _navigateToThird,
        onNavigateTab: _onDestinationSelected,
      ),
      LiveTranslateScreen(
        isShellTab: true,
        onNavigateTab: _onDestinationSelected,
      ),
      ProfileScreen(
        onNavigateTab: _onDestinationSelected,
      ),
    ];

    return AyoScreenBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
        ),
        bottomNavigationBar: AyoBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemSelected: _onDestinationSelected,
        ),
      ),
    );
  }
}
