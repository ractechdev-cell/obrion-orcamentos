import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/enums.dart';
import '../providers/budgets_repository_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
import 'budget_form_screen.dart';

String _statusLabel(BudgetStatus status) {
  switch (status) {
    case BudgetStatus.draft:
      return 'Rascunho';
    case BudgetStatus.sent:
      return 'Enviado';
    case BudgetStatus.accepted:
      return 'Aceito';
    case BudgetStatus.declined:
      return 'Recusado';
  }
}

Color _statusColor(BuildContext context, BudgetStatus status) {
  final colorScheme = Theme.of(context).colorScheme;
  switch (status) {
    case BudgetStatus.draft:
      return colorScheme.outline;
    case BudgetStatus.sent:
      return colorScheme.primary;
    case BudgetStatus.accepted:
      return Colors.green;
    case BudgetStatus.declined:
      return colorScheme.error;
  }
}

/// Lista de orçamentos de um cliente — status é o mecanismo de retenção
/// central do produto (ver CLAUDE.md).
class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key, required this.clientId});

  final String clientId;

  Future<void> _openBudgetActions(BuildContext context, WidgetRef ref, Budget budget) async {
    final repo = ref.read(budgetsRepositoryProvider);
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Abrir orçamento'),
              onTap: () => Navigator.of(context).pop('open'),
            ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Duplicar como novo rascunho'),
              onTap: () => Navigator.of(context).pop('duplicate'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Excluir', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || action == null) return;

    if (action == 'open') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BudgetFormScreen(
            clientId: clientId,
            budgetId: budget.id,
          ),
        ),
      );
    } else if (action == 'duplicate') {
      final duplicated = await repo.duplicate(budget.id);
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BudgetFormScreen(
              clientId: clientId,
              budgetId: duplicated.id,
            ),
          ),
        );
      }
    } else if (action == 'delete') {
      await repo.softDelete(budget.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(budgetsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Orçamentos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BudgetFormScreen(clientId: clientId),
          ),
        ),
        tooltip: 'Novo orçamento',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Budget>>(
        stream: repo.watchByClient(clientId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AppError(message: 'Falha ao carregar orçamentos.');
          }
          if (!snapshot.hasData) {
            return const AppLoading();
          }
          final budgets = snapshot.data!;
          if (budgets.isEmpty) {
            return AppEmptyState(
              message: 'Nenhum orçamento ainda.',
              actionLabel: 'Criar orçamento',
              onAction: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BudgetFormScreen(clientId: clientId),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return AppCard(
                onTap: () => _openBudgetActions(context, ref, budget),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Orçamento ${budget.createdAt.day}/${budget.createdAt.month}/${budget.createdAt.year}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusColor(context, budget.status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _statusLabel(budget.status),
                              style: TextStyle(
                                color: _statusColor(context, budget.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_vert),
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
