import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

/// Root application widget for AYOVAANI.
class AyoVaaniApp extends StatelessWidget {
  const AyoVaaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AYOVAANI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
