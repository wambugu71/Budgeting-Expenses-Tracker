import 'package:expensetracker/db/States_save.dart';
import 'package:flutter/material.dart';

class MyThemeHandler extends ChangeNotifier {
  ThemeData _theme = ThemeData.light().copyWith(
    primaryColor: Colors.teal,
    colorScheme: ColorScheme.light(
      primary: Colors.teal,
      secondary: Colors.tealAccent,
      onSurface: Colors.black87,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor:  Color(0xFF2E86C1),
      unselectedItemColor: Colors.grey,
    ),
    scaffoldBackgroundColor: Colors.grey.shade100,
    cardTheme: CardTheme(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
    ),
  );

  ThemeData get theme => _theme;
  var _switchstate  = false;
bool get switchstate =>  _switchstate;
 void SWitchState(bool state) {
    _switchstate = state;
    // Save to Hive
    HiveService.saveThemeMode(state);
    notifyListeners();
  }
  
  void getTheme(bool isDarkMode) {
    if (isDarkMode) {
      _theme = ThemeData.dark().copyWith(
        primaryColor: Colors.tealAccent,
        colorScheme: ColorScheme.dark(
          primary: Colors.tealAccent,
          secondary: Colors.teal,
          onSurface: Colors.white,
          surface: Colors.grey.shade800,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade900,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor:  Color(0xFF1E3C72),
          unselectedItemColor: Colors.grey,
          backgroundColor: Color(0xFF121212),
        ),
        scaffoldBackgroundColor: Colors.grey.shade900,
        cardTheme: CardTheme(
          color: Colors.grey.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade700,
        ),
        textTheme: Typography.whiteMountainView.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      );
    } else {
      _theme = ThemeData.light().copyWith(
        primaryColor: Colors.teal,
        colorScheme: ColorScheme.light(
          primary: Colors.teal,
          secondary: Colors.tealAccent,
          onSurface: Colors.black87,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
        ),
        scaffoldBackgroundColor: Colors.grey.shade100,
        cardTheme: CardTheme(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade300,
        ),
      );
    }
    HiveService.saveThemeMode(isDarkMode);
    notifyListeners();
  }
}