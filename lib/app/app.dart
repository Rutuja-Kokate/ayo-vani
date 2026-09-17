import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
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
      locale: context.watch<LocaleProvider>().locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SplashScreen(),
    );
  }
}
