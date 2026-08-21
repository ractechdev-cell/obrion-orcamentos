import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orcamentos/main.dart';
import 'package:orcamentos/theme/app_theme.dart';

void main() {
  testWidgets('App builds and shows the home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ObrionOrcamentosApp());

    expect(find.text('Obrion Orçamentos'), findsOneWidget);
    expect(find.text('Nenhum orçamento ainda.'), findsOneWidget);
  });

  testWidgets('Navigating to settings shows the settings screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ObrionOrcamentosApp());

    await tester.tap(find.byTooltip('Configurações'));
    await tester.pumpAndSettle();

    expect(find.text('Configurações'), findsOneWidget);
    expect(find.text('Em breve.'), findsOneWidget);
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
