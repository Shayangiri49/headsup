// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:headsup_ats/main.dart';

void main() {
  testWidgets('App loads onboarding screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
await tester.pumpWidget(const HeadsUpApp());

    // Verify that the onboarding screen is present (by checking for a known text or widget).
    // Update the text below to something unique from your OnboardingScreen.
expect(find.text('HEADSUP HR SOLUTIONS'), findsOneWidget);
  });
}
