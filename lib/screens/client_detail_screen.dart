import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/enums.dart';
import '../providers/budgets_repository_provider.dart';
import '../providers/clients_repository_provider.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/phone_actions.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_status_chip.dart';
import '../widgets/app_timeline_tile.dart';
import 'budget_form_screen.dart';
import 'budget_wizard_screen.dart';
import 'client_form_screen.dart';
import 'house_screen.dart';

class _TimelineEntry {
  const _TimelineEntry({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.status,
  });

  final DateTime date;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Define o selo e a cor do marcador na linha do tempo.
  final BudgetStatus status;
}

/// Histórico de orçamentos do cliente, em linha do tempo.
///
/// **Medição não entra mais aqui** (decisão 01/09/2026) — antes medição e
/// orçamento apareciam juntos, o que confundia (medição em obra civil já
/// tem outro significado: boletim financeiro de % executada). Cada
/// cômodo medido vive agora em [HouseScreen], acessível pelo ícone de
/// casa no app bar.
///
/// Consulta única (`initState`, `.first` na stream do repositório),
/// recarregada ao voltar de uma tela de detalhe — mesmo motivo do resumo
/// da Home: não precisa ser reativa segundo a segundo.
class ClientDetailScreen extends ConsumerStatefulWidget {
  const ClientDetailScreen({super.key, required this.client});

  final Client client;

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  bool _loading = true;
  String? _error;
  List<_TimelineEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final budgetsRepo = ref.read(budgetsRepositoryProvider);
      final budgets = await budgetsRepo.watchByClient(widget.client.id).first;

      final entries = <_TimelineEntry>[
        for (final budget in budgets)
          _TimelineEntry(
            date: budget.createdAt,
            title:
                'Orçamento ${budget.createdAt.day}/${budget.createdAt.month}/${budget.createdAt.year}',
            subtitle: statusLabel(budget.status),
            status: budget.status,
            onTap: () => _openBudget(
              budget.id,
              isDraft: budget.status == BudgetStatus.draft,
            ),
          ),
      ]..sort((a, b) => b.date.compareTo(a.date));

      if (mounted) {
        setState(() {
          _entries = entries;
          _error = null;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Falha ao carregar o histórico do cliente.';
          _loading = false;
        });
      }
    }
  }

  Future<void> _openBudget(String budgetId, {bool isDraft = false}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => isDraft
            ? BudgetWizardScreen(
                clientId: widget.client.id,
                budgetId: budgetId,
              )
            : BudgetFormScreen(
                clientId: widget.client.id,
                budgetId: budgetId,
              ),
      ),
    );
    _load();
  }

  Future<void> _addBudget() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BudgetWizardScreen(clientId: widget.client.id),
      ),
    );
    _load();
  }

  Future<void> _openHouse() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HouseScreen(
          clientId: widget.client.id,
          clientName: widget.client.name,
        ),
      ),
    );
  }

  Future<void> _openClientMenu(BuildContext context) async {
    final action = await AppBottomSheet.showActions<String>(
      context,
      title: widget.client.name,
      actions: const [
        AppBottomSheetAction(
          label: 'Editar cliente',
          value: 'edit',
          icon: Icons.edit_outlined,
        ),
        AppBottomSheetAction(
          label: 'Excluir cliente',
          value: 'delete',
          icon: Icons.delete_outline,
          isDestructive: true,
        ),
      ],
    );
    if (!context.mounted || action == null) return;

    if (action == 'edit') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ClientFormScreen(clientId: widget.client.id),
        ),
      );
      if (mounted) setState(() {});
    } else if (action == 'delete') {
      final confirmed = await AppDialog.confirm(
        context,
        isDestructive: true,
        title: 'Excluir ${widget.client.name}?',
        message: 'Esta ação não pode ser desfeita.',
        confirmLabel: 'Excluir',
      );
      if (confirmed == true) {
        await ref.read(clientsRepositoryProvider).softDelete(widget.client.id);
        if (context.mounted) {
          AppSnackBar.show(
            context,
            'Cliente excluído.',
            variant: AppSnackBarVariant.destructive,
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.client.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Casa do cliente',
            onPressed: _openHouse,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _openClientMenu(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBudget,
        tooltip: 'Novo orçamento',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if ((widget.client.phone ?? '').isNotEmpty)
            _buildContactActions(context),
          Expanded(
            child: _loading
                ? const AppLoading()
                : _error != null
                ? AppError(message: _error!, onRetry: _load)
                : _entries.isEmpty
                ? AppEmptyState(
                    message:
                        'Este cliente ainda não tem orçamento.\n\n'
                        'Crie o primeiro orçamento para começar o histórico dele.',
                    actionLabel: 'Criar orçamento',
                    onAction: _addBudget,
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.md,
                        AppSpacing.md,
                        // Espaço pro último card não ficar sob o botão
                        // flutuante.
                        AppSpacing.xxl + AppSpacing.lg,
                      ),
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return _TimelineTile(
                          entry: entry,
                          isFirst: index == 0,
                          isLast: index == _entries.length - 1,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Ligar / WhatsApp direto da ficha — ver
  /// docs/ANALISE_CONCORRENCIA_E_ESCOPO.md, Parte 5, item 6.
  Widget _buildContactActions(BuildContext context) {
    final phone = widget.client.phone!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => PhoneActions.openWhatsApp(context, phone),
              icon: const Icon(Icons.chat_outlined, size: 18),
              label: const Text('WhatsApp'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => PhoneActions.call(context, phone),
              icon: const Icon(Icons.call_outlined, size: 18),
              label: const Text('Ligar'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Item da linha do tempo — marcador colorido pelo estado do orçamento
/// (verde aprovado, vermelho recusado) e card com selo, data e resumo.
class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.entry,
    required this.isFirst,
    required this.isLast,
  });

  final _TimelineEntry entry;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final status = entry.status;

    // Marcador ganha cor só quando o estado carrega informação — aceito e
    // recusado são desfecho; rascunho e enviado ainda estão em curso, e
    // colorir tudo tiraria o destaque justamente de quem o tem.
    final accent = switch (status) {
      BudgetStatus.accepted => semantic.success,
      BudgetStatus.declined => semantic.danger,
      _ => null,
    };

    final icon = switch (status) {
      BudgetStatus.accepted => Icons.check_circle_outline,
      BudgetStatus.declined => Icons.cancel_outlined,
      _ => Icons.request_quote_outlined,
    };

    final date = entry.date;
    final dateLabel = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';

    return AppTimelineTile(
      icon: icon,
      accent: accent,
      isFirst: isFirst,
      isLast: isLast,
      onTap: entry.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(child: AppStatusChip.budget(status)),
              const Spacer(),
              Text(
                dateLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            entry.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 2),
          Text(
            entry.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
