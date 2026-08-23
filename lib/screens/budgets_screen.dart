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
import '../widgets/app_snackbar.dart';
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

/// Há quantos dias o orçamento está parado em "Enviado" — o sinal de
/// retenção descrito no CLAUDE.md ("orçamento aguardando resposta há N
/// dias"). `null` quando não se aplica (outro status, ou enviado há
/// menos de 3 dias — não vale a pena alarmar cedo demais).
int? _daysWaitingResponse(Budget budget) {
  if (budget.status != BudgetStatus.sent) return null;
  final days = DateTime.now().difference(budget.updatedAt).inDays;
  return days >= 3 ? days : null;
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
            // Avançar status em um toque, sem precisar abrir o orçamento —
            // mecanismo de retenção central do produto (ver CLAUDE.md).
            if (budget.status == BudgetStatus.draft)
              ListTile(
                leading: const Icon(Icons.send_outlined),
                title: const Text('Marcar como enviado'),
                onTap: () => Navigator.of(context).pop('mark_sent'),
              ),
            if (budget.status == BudgetStatus.sent) ...[
              ListTile(
                leading: Icon(Icons.check_circle_outline, color: context.semanticColors.success),
                title: const Text('Marcar como aceito'),
                onTap: () => Navigator.of(context).pop('mark_accepted'),
              ),
              ListTile(
                leading: Icon(Icons.cancel_outlined, color: Theme.of(context).colorScheme.error),
                title: const Text('Marcar como recusado'),
                onTap: () => Navigator.of(context).pop('mark_declined'),
              ),
            ],
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

    if (action == 'mark_sent' || action == 'mark_accepted' || action == 'mark_declined') {
      final status = switch (action) {
        'mark_sent' => BudgetStatus.sent,
        'mark_accepted' => BudgetStatus.accepted,
        _ => BudgetStatus.declined,
      };
      await repo.updateStatus(budget.id, status);
      if (context.mounted) {
        AppSnackBar.show(context, 'Orçamento marcado como ${_statusLabel(status).toLowerCase()}.');
      }
    } else if (action == 'open') {
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
          AppSnackBar.show(context, 'Orçamento excluído.', variant: AppSnackBarVariant.destructive);
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
                          final daysWaiting = _daysWaitingResponse(budget);
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
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
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
                                          if (daysWaiting != null)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: context.semanticColors.warningContainer,
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                'Aguardando há ${daysWaiting}d',
                                                style: TextStyle(
                                                  color: context.semanticColors.onWarningContainer,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
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
