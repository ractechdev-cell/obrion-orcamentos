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

    expect(find.text('Obrion Orçamentos'), findsOneWidget);
    expect(find.text('Novo Cliente'), findsOneWidget);
    // Barra de navegação inferior com as 4 abas de primeiro nível.
    expect(find.text('Início'), findsOneWidget);
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

    await tester.tap(find.text('Ajustes'));
    await tester.pumpAndSettle();

    expect(find.text('Seu perfil profissional'), findsOneWidget);
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
