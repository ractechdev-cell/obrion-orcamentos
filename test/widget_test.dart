import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orcamentos/main.dart';
import 'package:orcamentos/theme/app_theme.dart';

void main() {
  testWidgets('App builds and shows the app bar title',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ObrionOrcamentosApp());

    expect(find.text('Obrion Orçamentos'), findsOneWidget);
  });

  testWidgets('Light and dark themes both resolve without throwing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const SizedBox()),
    );
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark(), home: const SizedBox()),
    );
  });
}
