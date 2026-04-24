import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiopass/main.dart';

void main() {
  testWidgets('Kiopass smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KiopassApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}