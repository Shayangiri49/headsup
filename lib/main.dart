import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'utils/app_colors.dart';

// Export for use in other files
ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  runApp(
    ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'HEADSUP HR SOLUTIONS',
          theme: ThemeData(
            primaryColor: primaryBlue,
            scaffoldBackgroundColor: backgroundWhite,
            appBarTheme: const AppBarTheme(
              backgroundColor: backgroundWhite,
              elevation: 1,
              iconTheme: IconThemeData(color: textDark),
              titleTextStyle: TextStyle(
                color: textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: buttonTextWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              selectedItemColor: primaryBlue,
              unselectedItemColor: textSecondary,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: backgroundWhite,
              elevation: 8.0,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: primaryBlue,
            scaffoldBackgroundColor: Color(0xFF181A20),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF23262B),
              elevation: 1,
              iconTheme: IconThemeData(color: Colors.white),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedItemColor: Color(0xFF4A90E2),
              unselectedItemColor: Colors.white70,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Color(0xFF23262B),
              elevation: 8.0,
            ),
            cardColor: Color(0xFF23262B),
            dialogBackgroundColor: Color(0xFF23262B),
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
              titleLarge: TextStyle(color: Colors.white),
            ),
          ),
          themeMode: mode,
          debugShowCheckedModeBanner: false,
          home: const OnboardingScreen(),
        );
      },
    ),
  );
}
