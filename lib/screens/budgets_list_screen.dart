import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/enums.dart';
import '../providers/budgets_repository_provider.dart';
import '../providers/clients_repository_provider.dart';
import '../repositories/budgets_repository.dart';
import '../repositories/example_data_seeder.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/follow_up_message.dart';
import '../utils/phone_actions.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_snackbar.dart';
import 'budget_form_screen.dart';

Color _statusColor(BuildContext context, BudgetStatus status) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (status) {
    case BudgetStatus.draft:
      return colorScheme.outline;
    case BudgetStatus.sent:
      return colorScheme.primary;
    case BudgetStatus.accepted:
      return context.semanticColors.success;
    case BudgetStatus.declined:
      return colorScheme.error;
  }
}

/// Todos os orçamentos, de todos os clientes, numerados — visão geral que
/// o histórico por cliente (`ClientDetailScreen`) não substitui: aqui dá
/// pra ver o negócio inteiro de uma vez, não cliente por cliente.
class BudgetsListScreen extends ConsumerWidget {
  const BudgetsListScreen({super.key});

  Future<void> _createBudget(BuildContext context, WidgetRef ref) async {
    final clients = await ref.read(clientsRepositoryProvider).watchAll().first;
    if (!context.mounted) return;

    if (clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre um cliente primeiro, na aba Clientes.')),
      );
      return;
    }

    final selected = await showModalBottomSheet<Client>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: (MediaQuery.of(context).size.height * 0.6).clamp(400.0, 700.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('Orçamento para qual cliente?', style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return ListTile(
                      title: Text(client.name),
                      onTap: () => Navigator.of(context).pop(client),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BudgetFormScreen(clientId: selected.id)),
      );
    }
  }

  /// Busca o telefone do cliente só na hora de mandar o lembrete (evita
  /// carregar isso pra lista inteira via `BudgetWithClientName`, que hoje
  /// não guarda telefone — ver `PhoneActions.openWhatsApp`).
  Future<void> _sendFollowUp(BuildContext context, WidgetRef ref, String clientId, String clientName) async {
    final client = await ref.read(clientsRepositoryProvider).getById(clientId);
    final phone = client?.phone;
    if (!context.mounted) return;
    if (phone == null || phone.isEmpty) {
      AppSnackBar.show(context, 'Esse cliente não tem telefone salvo.', variant: AppSnackBarVariant.warning);
      return;
    }
    await PhoneActions.openWhatsApp(context, phone, message: followUpMessage(clientName));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(budgetsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Orçamentos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createBudget(context, ref),
        tooltip: 'Novo orçamento',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<BudgetWithClientName>>(
        stream: repo.watchAllWithClientNames(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AppError(message: 'Falha ao carregar orçamentos.');
          }
          if (!snapshot.hasData) {
            return const AppLoading();
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return AppEmptyState(
              message: 'Você ainda não criou nenhum orçamento.\n\n'
                  'Crie o primeiro para começar a enviar propostas pelo WhatsApp.',
              actionLabel: 'Criar orçamento',
              onAction: () => _createBudget(context, ref),
              secondaryActionLabel: 'Ver um exemplo',
              onSecondaryAction: () => ExampleDataSeeder.seed(
                clientsRepo: ref.read(clientsRepositoryProvider),
                budgetsRepo: ref.read(budgetsRepositoryProvider),
              ),
            );
          }

          // items vem do mais antigo pro mais novo — número = posição
          // nessa ordem (estável), lista exibida do mais novo pro mais
          // antigo (convenção do resto do app).
          final displayItems = [
            for (var i = items.length - 1; i >= 0; i--) (number: i + 1, entry: items[i]),
          ];

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: displayItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final (:number, :entry) = displayItems[index];
              final budget = entry.budget;
              final color = _statusColor(context, budget.status);

              return AppCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BudgetFormScreen(clientId: budget.clientId, budgetId: budget.id),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$number',
                            style: TextStyle(color: color, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry.clientName, style: Theme.of(context).textTheme.titleMedium),
                              Text(
                                '${budget.createdAt.day}/${budget.createdAt.month}/${budget.createdAt.year}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            switch (budget.status) {
                              BudgetStatus.draft => 'Rascunho',
                              BudgetStatus.sent => 'Enviado',
                              BudgetStatus.accepted => 'Aceito',
                              BudgetStatus.declined => 'Recusado',
                            },
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: color, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (budget.status == BudgetStatus.sent) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          style: const ButtonStyle(visualDensity: VisualDensity.compact),
                          onPressed: () =>
                              _sendFollowUp(context, ref, budget.clientId, entry.clientName),
                          icon: const Icon(Icons.chat_outlined, size: 16),
                          label: const Text('Enviar lembrete'),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
