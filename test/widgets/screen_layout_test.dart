import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/database/enums.dart';
import 'package:orcamentos/providers/database_provider.dart';
import 'package:orcamentos/repositories/budgets_repository.dart';
import 'package:orcamentos/repositories/clients_repository.dart';
import 'package:orcamentos/repositories/services_repository.dart';
import 'package:orcamentos/screens/budgets_list_screen.dart';
import 'package:orcamentos/screens/client_detail_screen.dart';
import 'package:orcamentos/screens/clients_screen.dart';
import 'package:orcamentos/screens/home_screen.dart';
import 'package:orcamentos/screens/services_screen.dart';
import 'package:orcamentos/theme/app_theme.dart';

/// Guarda contra estouro de layout nas telas de lista.
///
/// O `flutter_test` transforma qualquer `RenderFlex overflowed` em falha,
/// então basta renderizar cada tela com dado realista para que um estouro
/// quebre o teste. Vale a pena porque o público usa aparelho de tela
/// pequena e nomes/valores longos são dado real (nome de construtora,
/// orçamento de seis dígitos), não caso de borda inventado.
///
/// As larguras cobrem os dois extremos que importam: 320dp é o menor
/// telefone Android ainda em uso, 411dp é o tamanho comum de aparelho
/// intermediário.
void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => database.close());

  /// Dado propositalmente hostil ao layout: nome longo sem espaço para
  /// quebrar bem, e valores na casa dos milhões.
  Future<Client> seedStressData() async {
    final clientsRepo = ClientsRepository(database);
    final budgetsRepo = BudgetsRepository(database);
    final servicesRepo = ServicesRepository(database);

    final client = await clientsRepo.create(
      name: 'Construtora Empreendimentos Imobiliários Alfa Beta Ltda',
      phone: '(11) 98765-4321',
      address: 'Avenida Engenheiro Luís Carlos Berrini, 1500 — Brooklin',
    );

    for (final status in BudgetStatus.values) {
      final budget = await budgetsRepo.create(clientId: client.id);
      await budgetsRepo.addItem(
        budget.id,
        const BudgetItemInput(
          description: 'Assentamento de porcelanato retificado 120x120',
          unit: ServiceUnit.squareMeter,
          quantity: 999,
          unitPriceCents: 123456,
        ),
      );
      await budgetsRepo.updateStatus(budget.id, status);
    }

    await servicesRepo.create(
      name: 'Impermeabilização de laje com manta asfáltica dupla',
      unit: ServiceUnit.squareMeter,
      defaultPriceCents: 12345678,
      category: 'Impermeabilização e vedação',
    );
    // Serviço sem preço nem categoria — o outro extremo.
    await servicesRepo.create(name: 'Serviço', unit: ServiceUnit.unit);

    return client;
  }

  /// Renderiza [screen] no tamanho pedido, deixa o dado carregar, roda
  /// [expectations] e desmonta a árvore.
  ///
  /// A desmontagem acontece **dentro** do teste, não num `addTearDown`:
  /// telas com campo de busca e botão flutuante deixam temporizadores
  /// vivos enquanto montadas, e o `flutter_test` falha com
  /// `!timersPending` se eles ainda existirem no fim do teste — mesmo
  /// tendo a tela renderizado corretamente, que é o que se quer medir.
  Future<void> renderScreen(
    WidgetTester tester,
    Widget screen, {
    required Size size,
    required void Function() expectations,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(theme: AppTheme.light(), home: screen),
      ),
    );

    // `runAsync` deixa as consultas reais do Drift completarem — sem
    // isso a tela fica no `AppLoading` e o layout de verdade nunca chega
    // a ser medido.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );

    // `pump` com duração fixa, não `pumpAndSettle`: o indicador do
    // `AppLoading` gira para sempre, então `pumpAndSettle` esperaria por
    // uma quietude que nunca chega.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expectations();

    // Desmonta e deixa os temporizadores restantes expirarem.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  const sizes = <String, Size>{
    'tela pequena (320dp)': Size(320, 640),
    'tela comum (411dp)': Size(411, 891),
  };

  for (final entry in sizes.entries) {
    group(entry.key, () {
      testWidgets('Home não estoura', (tester) async {
        await seedStressData();
        await renderScreen(
          tester,
          const HomeScreen(),
          size: entry.value,
          expectations: () => expect(find.text('OBRION'), findsOneWidget),
        );
      });

      testWidgets('Lista de orçamentos não estoura', (tester) async {
        await seedStressData();
        await renderScreen(
          tester,
          const BudgetsListScreen(),
          size: entry.value,
          expectations: () =>
              expect(find.byType(BudgetsListScreen), findsOneWidget),
        );
      });

      testWidgets('Lista de clientes não estoura', (tester) async {
        await seedStressData();
        await renderScreen(
          tester,
          const ClientsScreen(),
          size: entry.value,
          expectations: () =>
              expect(find.textContaining('orçamento'), findsWidgets),
        );
      });

      testWidgets('Lista de preços não estoura', (tester) async {
        await seedStressData();
        await renderScreen(
          tester,
          const ServicesScreen(),
          size: entry.value,
          expectations: () =>
              expect(find.byType(ServicesScreen), findsOneWidget),
        );
      });

      testWidgets('Ficha do cliente (linha do tempo) não estoura',
          (tester) async {
        // O cliente vem do próprio seeder: consultar o banco aqui, no
        // corpo do teste, travaria — `await` em stream do Drift dentro da
        // zona de tempo simulado do `flutter_test` nunca completa.
        final client = await seedStressData();
        await renderScreen(
          tester,
          ClientDetailScreen(client: client),
          size: entry.value,
          expectations: () =>
              expect(find.byType(ClientDetailScreen), findsOneWidget),
        );
      });

      testWidgets('estado vazio não estoura', (tester) async {
        // Sem `seedStressData`: o estado vazio tem layout próprio
        // (ilustração + mensagem + duas ações), que numa tela de 320dp
        // é justamente onde sobra menos espaço.
        await renderScreen(
          tester,
          const ClientsScreen(),
          size: entry.value,
          expectations: () =>
              expect(find.byType(ClientsScreen), findsOneWidget),
        );
      });
    });
  }
}
