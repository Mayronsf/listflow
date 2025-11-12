import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Provider para gerenciar tema do aplicativo
class ThemeProvider with ChangeNotifier {
  final StorageService _storageService = StorageService.instance;
  
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  /// Inicializa o provider
  Future<void> init() async {
    // Sempre usa modo escuro
    _isDarkMode = true;
    notifyListeners();
  }

  /// Alterna entre tema claro e escuro
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storageService.saveThemePreference(_isDarkMode);
    notifyListeners();
  }

  /// Define o tema
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _storageService.saveThemePreference(_isDarkMode);
      notifyListeners();
    }
  }

  /// Retorna o tema atual (sempre escuro)
  ThemeData get currentTheme => _darkTheme;

  /// Tema escuro
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF9C27B0), // Roxo
      secondary: Color(0xFF2196F3), // Azul
      surface: Color(0xFF121212),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFF9C27B0),
      unselectedItemColor: Colors.grey,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Colors.grey,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: Colors.grey,
        fontSize: 12,
      ),
    ),
  );

}
