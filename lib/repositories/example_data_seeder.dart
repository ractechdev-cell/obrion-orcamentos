import '../database/enums.dart';
import 'budgets_repository.dart';
import 'clients_repository.dart';

/// Cria um cliente + orçamento de exemplo, marcados com `[exemplo]` —
/// resolve o "app abre vazio" (ver docs/ANALISE_CONCORRENCIA_E_ESCOPO.md,
/// Parte 5, item 1) sem precisar de seeding automático no primeiro boot.
/// Um preço marcado `[exemplo]` não é sugestão, é amostra — não conflita
/// com a regra de nunca sugerir preço na Lista de Preços (essa regra é
/// sobre `services`, não sobre este registro de demonstração).
///
/// São registros normais, soft-deletáveis como qualquer cliente/orçamento
/// real — nenhuma flag especial de "é exemplo" no schema.
class ExampleDataSeeder {
  const ExampleDataSeeder._();

  static Future<void> seed({
    required ClientsRepository clientsRepo,
    required BudgetsRepository budgetsRepo,
  }) async {
    final client = await clientsRepo.create(
      name: 'Roberto Alves [exemplo]',
      phone: '(11) 91111-2222',
      address: 'Rua das Azaléias, 142',
    );
    final budget = await budgetsRepo.create(
      clientId: client.id,
      notes: 'Orçamento de exemplo — pode excluir quando quiser.',
    );
    await budgetsRepo.addItem(
      budget.id,
      const BudgetItemInput(
        description: 'Pintura acrílica (2 demãos) [exemplo]',
        unit: ServiceUnit.squareMeter,
        quantity: 40,
        unitPriceCents: 2500,
      ),
    );
    await budgetsRepo.addItem(
      budget.id,
      const BudgetItemInput(
        description: 'Reboco de parede [exemplo]',
        unit: ServiceUnit.squareMeter,
        quantity: 20,
        unitPriceCents: 3000,
      ),
    );
  }
}
