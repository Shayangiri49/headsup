import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(const HeadsUpApp());
}

class HeadsUpApp extends StatelessWidget {
  const HeadsUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HEADSUP HR SOLUTIONS',
      theme: ThemeData(
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: backgroundWhite,
        // Remove fontFamily line or use system default
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundWhite,
          elevation: 1,
          iconTheme: IconThemeData(color: textDark),
          titleTextStyle: TextStyle(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            // Remove fontFamily line
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
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
    );
  }
}
