import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_year_project/pages/resources.dart';

void main() {
  testWidgets('Resources widget displays resources correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Resources(),
    ));

    expect(find.text('ADHD Power Tools (YouTube)'), findsOneWidget);
    expect(find.text('ADHD Alien (Comics)'), findsOneWidget);
    expect(find.text('ADHD Adult UK (Resources)'), findsOneWidget);
    expect(find.text('ADHD UK (Resources)'), findsOneWidget);

    expect(find.byType(Image), findsNWidgets(4));
    final firstResourceCard = find.text('ADHD Power Tools (YouTube)').last;
    await tester.tap(firstResourceCard);
    await tester.pumpAndSettle();
  });
}
