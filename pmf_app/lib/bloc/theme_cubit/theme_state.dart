part of 'theme_cubit.dart';

class ThemeState {
  final bool isDarkMode;

  const ThemeState({
    required this.isDarkMode,
  });

  ThemeState copyWith({
    bool? isDarkMode,
  }) {
    return ThemeState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeState &&
          runtimeType == other.runtimeType &&
          isDarkMode == other.isDarkMode;

  @override
  int get hashCode => isDarkMode.hashCode;
}
