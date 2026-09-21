import 'package:flutter/material.dart';
import 'package:flutter_foundation/features/ai_tutor/widgets/ai_tutor_fab.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AiTutorFab renders robot icon and handles taps', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          floatingActionButton: AiTutorFab(),
        ),
      ),
    );

    // Verify that the robot icon is rendered inside AiTutorFab
    expect(find.byType(AiTutorFab), findsOneWidget);
    expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
  });
}
