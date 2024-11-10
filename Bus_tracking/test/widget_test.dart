// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Stop selection dialog displays and allows selecting stops',
      (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the notification icon is present.
    expect(find.byIcon(Icons.notifications), findsOneWidget);

    // Tap the notification icon to open the stop selection dialog.
    await tester.tap(find.byIcon(Icons.notifications));
    await tester.pumpAndSettle();

    // Verify the dialog is displayed with the title 'Select Stops'.
    expect(find.text('Select Stops'), findsOneWidget);

    // Simulate selecting a stop from the list.
    // Make sure 'San Fernando Terminal' exists in the stopCoordinates map in your app.
    await tester.tap(find.text('San Fernando Terminal'));
    await tester.pump();

    // Verify that the stop is selected (checkbox is checked).
    final checkbox =
        find.widgetWithText(CheckboxListTile, 'San Fernando Terminal');
    expect(tester.widget<CheckboxListTile>(checkbox).value, isTrue);

    // Tap the 'Submit' button.
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    // Verify that the dialog is closed after submission.
    expect(find.text('Select Stops'), findsNothing);
  });
}
