part of 'theme_bloc.dart';

enum AppThemeMode { light, dark }

class ThemeState {
  final AppThemeMode mode;
  ThemeState(this.mode);

  bool get isDark => mode == AppThemeMode.dark;
}