/// Centralized route names and navigation constants for AYOVAANI.
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String home = '/';
  static const String learn = '/learn';
  static const String tools = '/tools';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String themePreview = '/theme-preview';
  static const String liveTranslate = '/live-translate';
  static const String balvatika = '/balvatika';
  static const String first = '/first';
  static const String second = '/second';
  static const String third = '/third';
  static const String chapterOptions = '/chapter-options';

  /// 4 Core Destinations for bottom navigation & tablet side rail.
  static const List<String> mainNavTitles = [
    'Home',
    'Learn',
    'Translate',
    'Profile',
  ];
}
