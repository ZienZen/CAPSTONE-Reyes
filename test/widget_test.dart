import 'package:flutter_test/flutter_test.dart';

import 'package:capstone_reyes/main.dart';

void main() {
  testWidgets('Shows the student ID screen first', (WidgetTester tester) async {
    await tester.pumpWidget(const EventApp());

    expect(find.text('School Events'), findsOneWidget);
    expect(find.text('Student ID'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
