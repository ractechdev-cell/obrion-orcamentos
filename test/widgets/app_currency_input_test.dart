import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orcamentos/widgets/app_currency_input.dart';

/// O valor exposto por AppCurrencyInput é sempre `int` em centavos — a
/// formatação em R$ existe só na borda de apresentação (ver CLAUDE.md,
/// "Dinheiro é `int` em centavos — nunca `double`").
void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  Future<void> pumpInput(
    WidgetTester tester, {
    required ValueChanged<int?> onChangedCents,
    int? initialValueCents,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppCurrencyInput(
            label: 'Preço',
            initialValueCents: initialValueCents,
            onChangedCents: onChangedCents,
          ),
        ),
      ),
    );
  }

  testWidgets('typed digits are reported as cents', (tester) async {
    int? cents;
    await pumpInput(tester, onChangedCents: (value) => cents = value);

    await tester.enterText(find.byType(TextField), '2500');
    await tester.pump();

    expect(cents, 2500);
  });

  testWidgets('formats typed digits as brazilian currency', (tester) async {
    await pumpInput(tester, onChangedCents: (_) {});

    await tester.enterText(find.byType(TextField), '2500');
    await tester.pump();

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, contains('25,00'));
  });

  testWidgets('reports null when cleared', (tester) async {
    int? cents;
    await pumpInput(tester, onChangedCents: (value) => cents = value);

    await tester.enterText(find.byType(TextField), '2500');
    await tester.pump();
    expect(cents, 2500);

    await tester.enterText(find.byType(TextField), '');
    await tester.pump();

    expect(cents, isNull);
  });

  testWidgets('renders the initial value in cents', (tester) async {
    await pumpInput(
      tester,
      onChangedCents: (_) {},
      initialValueCents: 31250,
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, contains('312,50'));
  });
}
