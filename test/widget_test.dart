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
/// para um banco em memória (mesmo padrão dos testes de repositório;
/// instância única por teste, fechada no `tearDown`, sem aviso de DB
/// duplicada do Drift).
///
/// `showUpgradeAlertProvider` é desligado: `UpgradeAlert` faz uma chamada
/// de rede real pra loja que fica pendente em ambiente de teste.
/// `runSystemServicesProvider` desliga o que depende de plugin nativo —
/// analytics (Firebase), notificações locais e checagem de patch OTA —
/// que no teste não existem e apenas so­sobem ruído "falhou" no log.
///
/// Banco em memória sempre começa sem onboarding visto, então todo teste
/// passa primeiro pelas telas de `OnboardingScreen` e toca "Pular" —
/// mesmo caminho que a primeira abertura real do app segue.
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  testWidgets('App builds and shows the home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          showUpgradeAlertProvider.overrideWithValue(false),
          runSystemServicesProvider.overrideWithValue(false),
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
          appDatabaseProvider.overrideWithValue(database),
          showUpgradeAlertProvider.overrideWithValue(false),
          runSystemServicesProvider.overrideWithValue(false),
        ],
        child: const ObrionOrcamentosApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();

    expect(find.text('Perfil Profissional'), findsOneWidget);
  });

  testWidgets('Light theme resolves without throwing',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light(), home: const SizedBox()),
    );
  });
}