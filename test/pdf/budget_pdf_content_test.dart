import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/database/enums.dart';
import 'package:orcamentos/pdf/budget_pdf_content.dart';
import 'package:orcamentos/repositories/budgets_repository.dart';
import 'package:orcamentos/repositories/clients_repository.dart';
import 'package:orcamentos/repositories/profile_repository.dart';

/// Testa se a informação certa vai pro conteúdo do PDF (cliente, itens,
/// valores, desconto, observações) sem depender de renderizar/rasterizar
/// nada — ver nota em `budget_pdf_content.dart` sobre por que não é um
/// golden test visual (rasterização real de PDF exige host de plataforma,
/// não roda no `flutter test` comum).
void main() {
  late AppDatabase database;
  late ClientsRepository clientsRepo;
  late BudgetsRepository budgetsRepo;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    clientsRepo = ClientsRepository(database);
    budgetsRepo = BudgetsRepository(database);
  });

  tearDown(() => database.close());

  test('inclui dados do cliente, profissional, itens e total', () async {
    final client = await clientsRepo.create(
      name: 'Maria da Silva',
      phone: '11999998888',
      address: 'Rua das Flores, 123',
    );
    final budget = await budgetsRepo.create(clientId: client.id);
    await budgetsRepo.addItem(
      budget.id,
      const BudgetItemInput(
        description: 'Pintura de parede',
        unit: ServiceUnit.squareMeter,
        quantity: 40,
        unitPriceCents: 2500,
      ),
    );
    final data = await budgetsRepo.watchById(budget.id).first;

    final content = BudgetPdfContent.fromData(
      data: data!,
      client: client,
      professional: const ProfessionalProfile(name: 'João Pedreiro', phone: '11988887777'),
    );

    expect(content.professionalName, 'João Pedreiro');
    expect(content.professionalPhone, '11988887777');
    expect(content.clientName, 'Maria da Silva');
    expect(content.clientPhone, '11999998888');
    expect(content.clientAddress, 'Rua das Flores, 123');
    expect(content.items, hasLength(1));
    expect(content.items.single.description, 'Pintura de parede');
    expect(content.items.single.quantityAndUnit, '40.0 m²');
    expect(content.items.single.unitPriceFormatted, 'R\$ 25,00');
    expect(content.items.single.totalFormatted, 'R\$ 1.000,00');
    expect(content.subtotalFormatted, 'R\$ 1.000,00');
    expect(content.totalFormatted, 'R\$ 1.000,00');
    expect(content.discountFormatted, isNull);
    expect(content.notes, isNull);
  });

  test('mostra desconto só quando maior que zero, e reflete no total', () async {
    final client = await clientsRepo.create(name: 'Cliente Teste');
    final budget = await budgetsRepo.create(clientId: client.id);
    await budgetsRepo.addItem(
      budget.id,
      const BudgetItemInput(
        description: 'Reboco',
        unit: ServiceUnit.squareMeter,
        quantity: 10,
        unitPriceCents: 3000,
      ),
    );
    await budgetsRepo.updateDiscount(budget.id, 5000);
    final data = await budgetsRepo.watchById(budget.id).first;

    final content = BudgetPdfContent.fromData(
      data: data!,
      client: client,
      professional: const ProfessionalProfile(),
    );

    expect(content.subtotalFormatted, 'R\$ 300,00');
    expect(content.discountFormatted, 'R\$ 50,00');
    expect(content.totalFormatted, 'R\$ 250,00');
    // Sem nome cadastrado, o cabeçalho cai no rótulo genérico.
    expect(content.professionalName, 'Orçamento');
  });

  test('mostra observações só quando preenchidas', () async {
    final client = await clientsRepo.create(name: 'Cliente Teste');
    final budget = await budgetsRepo.create(clientId: client.id, notes: 'Entrega em 15 dias.');
    final data = await budgetsRepo.watchById(budget.id).first;

    final content = BudgetPdfContent.fromData(
      data: data!,
      client: client,
      professional: const ProfessionalProfile(),
    );

    expect(content.notes, 'Entrega em 15 dias.');
  });
}
