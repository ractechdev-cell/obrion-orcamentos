import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/enums.dart';
import '../analytics/analytics_service.dart';
import '../providers/budgets_repository_provider.dart';
import '../theme/app_semantic_colors.dart';
import '../widgets/app_card.dart';
import '../widgets/app_dialog.dart';
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
      return context.semanticColors.success;
    case BudgetStatus.declined:
      return colorScheme.error;
  }
}

/// Lista de orçamentos de um cliente — status é o mecanismo de retenção
/// central do produto (ver CLAUDE.md).
class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  BudgetStatus? _statusFilter;

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
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text('Excluir', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
            clientId: widget.clientId,
            budgetId: budget.id,
          ),
        ),
      );
    } else if (action == 'duplicate') {
      final duplicated = await repo.duplicate(budget.id);
      AnalyticsService.trackEvent('budget_duplicated');
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BudgetFormScreen(
              clientId: widget.clientId,
              budgetId: duplicated.id,
            ),
          ),
        );
      }
    } else if (action == 'delete') {
      final confirmed = await AppDialog.confirm(
        context,
        isDestructive: true,
        title: 'Excluir orçamento?',
        message: 'Esta ação não pode ser desfeita.',
        confirmLabel: 'Excluir',
      );
      if (confirmed == true) {
        await repo.softDelete(budget.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Orçamento excluído.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(budgetsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Orçamentos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BudgetFormScreen(clientId: widget.clientId),
          ),
        ),
        tooltip: 'Novo orçamento',
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Budget>>(
        stream: repo.watchByClient(widget.clientId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AppError(message: 'Falha ao carregar orçamentos.');
          }
          if (!snapshot.hasData) {
            return const AppLoading();
          }
          final allBudgets = snapshot.data!;
          // Filtro client-side por status
          final budgets = _statusFilter == null
              ? allBudgets
              : allBudgets.where((b) => b.status == _statusFilter).toList();

          return Column(
            children: [
              // Chips de filtro por status
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('Todos'),
                      selected: _statusFilter == null,
                      onSelected: (_) => setState(() => _statusFilter = null),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Rascunho'),
                      selected: _statusFilter == BudgetStatus.draft,
                      onSelected: (_) => setState(() => _statusFilter = BudgetStatus.draft),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Enviado'),
                      selected: _statusFilter == BudgetStatus.sent,
                      onSelected: (_) => setState(() => _statusFilter = BudgetStatus.sent),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Aceito'),
                      selected: _statusFilter == BudgetStatus.accepted,
                      onSelected: (_) => setState(() => _statusFilter = BudgetStatus.accepted),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Recusado'),
                      selected: _statusFilter == BudgetStatus.declined,
                      onSelected: (_) => setState(() => _statusFilter = BudgetStatus.declined),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: budgets.isEmpty
                    ? AppEmptyState(
                        message: _statusFilter == null
                            ? 'Nenhum orçamento ainda.'
                            : 'Nenhum orçamento ${_statusLabel(_statusFilter!).toLowerCase()}.',
                        actionLabel: _statusFilter == null ? 'Criar orçamento' : null,
                        onAction: _statusFilter == null
                            ? () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BudgetFormScreen(clientId: widget.clientId),
                                  ),
                                )
                            : null,
                      )
                    : ListView.separated(
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
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
