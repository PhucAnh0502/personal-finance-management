import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'isDarkMode';

  ThemeCubit() : super(const ThemeState(isDarkMode: false)) {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDarkMode = prefs.getBool(_themeKey) ?? false;
      emit(ThemeState(isDarkMode: isDarkMode));
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  void toggleTheme() {
    try {
      final newValue = !state.isDarkMode;
      emit(ThemeState(isDarkMode: newValue));
      // Save to SharedPreferences in background without blocking
      _saveThemePreferenceAsync(newValue);
    } catch (e) {
      print('Error toggling theme: $e');
    }
  }

  void setDarkMode(bool isDarkMode) {
    try {
      emit(ThemeState(isDarkMode: isDarkMode));
      // Save to SharedPreferences in background without blocking
      _saveThemePreferenceAsync(isDarkMode);
    } catch (e) {
      print('Error setting theme: $e');
    }
  }

  void _saveThemePreferenceAsync(bool isDarkMode) {
    // Fire and forget - don't await, don't block UI
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_themeKey, isDarkMode);
    }).catchError((e) {
      print('Error saving theme preference: $e');
    });
  }
}
