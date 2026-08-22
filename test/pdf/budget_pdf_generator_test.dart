import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/database/enums.dart';
import 'package:orcamentos/pdf/budget_pdf_generator.dart';
import 'package:orcamentos/repositories/budgets_repository.dart';
import 'package:orcamentos/repositories/clients_repository.dart';
import 'package:orcamentos/repositories/profile_repository.dart';

void main() {
  test('generates non-empty PDF bytes for a budget with items', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final clientsRepo = ClientsRepository(database);
    final budgetsRepo = BudgetsRepository(database);

    final client = await clientsRepo.create(name: 'Cliente Teste', phone: '11999999999');
    final budget = await budgetsRepo.create(clientId: client.id, notes: 'Pagamento à vista');
    await budgetsRepo.addItem(
      budget.id,
      const BudgetItemInput(
        description: 'Pintura de parede',
        unit: ServiceUnit.squareMeter,
        quantity: 20,
        unitPriceCents: 2500,
      ),
    );

    final data = await budgetsRepo.watchById(budget.id).first;

    final doc = await BudgetPdfGenerator.generate(
      data: data!,
      client: client,
      professional: const ProfessionalProfile(name: 'Fulano', phone: '11888888888'),
    );

    final bytes = await doc.save();
    expect(bytes, isNotEmpty);
  });
}
