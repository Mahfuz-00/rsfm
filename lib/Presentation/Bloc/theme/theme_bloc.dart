import 'package:flutter_bloc/flutter_bloc.dart';
part 'theme_state.dart';
part 'theme_event.dart';


class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(AppThemeMode.light)) {
    on<ToggleTheme>((event, emit) {
      final newMode = state.isDark ? AppThemeMode.light : AppThemeMode.dark;
      emit(ThemeState(newMode));
    });
  }
}