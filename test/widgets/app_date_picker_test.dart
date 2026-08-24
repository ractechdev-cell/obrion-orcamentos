import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orcamentos/widgets/app_date_picker.dart';

/// `AppDatePicker` formata com `DateFormat(..., 'pt_BR')` — sem
/// `initializeDateFormatting('pt_BR')` isso lança em runtime e o widget
/// vira um bloco cinza (`ErrorWidget`) em vez do campo de data. Achado em
/// teste manual real no aparelho: o app nunca chamava
/// `initializeDateFormatting` (só os testes chamavam, isolado — o app de
/// verdade nunca pegou o fix). Agora `main.dart` chama isso no boot.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  Future<void> pumpPicker(WidgetTester tester, {DateTime? value}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppDatePicker(
            label: 'Válido até',
            value: value,
            onChanged: (_) {},
          ),
        ),
      ),
    );
  }

  testWidgets('renders without a value', (tester) async {
    await pumpPicker(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders a formatted date without throwing', (tester) async {
    await pumpPicker(tester, value: DateTime(2026, 9, 24));

    expect(tester.takeException(), isNull);
    expect(find.text('24/09/2026'), findsOneWidget);
  });
}
