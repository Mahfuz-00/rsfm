part of 'theme_bloc.dart';

abstract class ThemeEvent {}

class ToggleTheme extends ThemeEvent {}

class LoadSavedTheme extends ThemeEvent {} // optional future use