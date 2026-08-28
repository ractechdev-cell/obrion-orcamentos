import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/main.dart';
import 'package:orcamentos/providers/database_provider.dart';
import 'package:orcamentos/theme/app_theme.dart';

/// Widget tests rodam o app inteiro, incluindo o banco local. Sem
/// sobrescrever o provider, `AppDatabase()` tentaria abrir um arquivo via
/// `path_provider`, indisponível no ambiente de teste — daí o override
/// para um banco em memória (mesmo padrão dos testes de repositório).
/// `showUpgradeAlertProvider` também é desligado: `UpgradeAlert` faz uma
/// chamada de rede real pra loja que fica pendente em ambiente de teste.
///
/// Banco em memória sempre começa sem onboarding visto, então todo teste
/// passa primeiro pelas 3 telas de `OnboardingScreen` e toca "Pular" —
/// mesmo caminho que a primeira abertura real do app segue.
void main() {
  testWidgets('App builds and shows the home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(
            AppDatabase.forTesting(NativeDatabase.memory()),
          ),
          showUpgradeAlertProvider.overrideWithValue(false),
        ],
        child: const ObrionOrcamentosApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    // A Home mostra a marca em caixa alta (design system Safety
    // Industrial); as outras abas mostram o nome da seção.
    expect(find.text('OBRION'), findsOneWidget);
    expect(find.text('Novo Cliente'), findsOneWidget);
    // Barra de navegação inferior com as 5 abas de primeiro nível.
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Orçamentos'), findsOneWidget);
    expect(find.text('Clientes'), findsOneWidget);
    expect(find.text('Preços'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
  });

  testWidgets('Tapping the Ajustes tab shows the settings screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(
            AppDatabase.forTesting(NativeDatabase.memory()),
          ),
          showUpgradeAlertProvider.overrideWithValue(false),
        ],
        child: const ObrionOrcamentosApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();

    expect(find.text('Seu perfil profissional'), findsOneWidget);
  });

  testWidgets('Light theme resolves without throwing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const SizedBox()),
    );
  });
}
