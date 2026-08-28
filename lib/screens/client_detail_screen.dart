import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/enums.dart';
import '../measurement/measurement_math.dart';
import '../providers/budgets_repository_provider.dart';
import '../providers/clients_repository_provider.dart';
import '../providers/measurements_repository_provider.dart';
import '../repositories/measurements_repository.dart';
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
import 'measurement_form_screen.dart';

enum _TimelineKind { measurement, budget }

class _TimelineEntry {
  const _TimelineEntry({
    required this.kind,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.status,
    this.onDelete,
  });

  final _TimelineKind kind;
  final DateTime date;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Só para orçamento — define o selo e a cor do marcador na linha do
  /// tempo. Nulo em medição, que não tem ciclo de status.
  final BudgetStatus? status;

  /// Só preenchido pra medição — excluir orçamento não faz parte deste
  /// menu (o orçamento tem seu próprio ciclo de vida via status).
  final VoidCallback? onDelete;
}

/// Histórico do cliente — medições e orçamentos juntos numa linha do
/// tempo, em vez de navegar Clientes → Medições e Clientes → Orçamentos
/// como telas separadas e desconectadas.
///
/// Consulta única (`initState`, `.first` nas streams dos repositórios),
/// recarregada ao voltar de uma tela de detalhe — mesmo motivo do resumo
/// da Home: não precisa ser reativa segundo a segundo, e evita abrir
/// streams de banco concorrentes numa tela que mistura dois repositórios.
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
  String? _projectId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    try {
      final measurementsRepo = ref.read(measurementsRepositoryProvider);
      final budgetsRepo = ref.read(budgetsRepositoryProvider);

      final projects = await measurementsRepo
          .watchProjectsByClient(widget.client.id)
          .first;
      final projectId = projects.isEmpty ? null : projects.first.id;

      final measurements = projectId == null
          ? const <MeasurementWithDetails>[]
          : await measurementsRepo.watchByProject(projectId).first;
      final budgets = await budgetsRepo.watchByClient(widget.client.id).first;

      final entries = <_TimelineEntry>[
        for (final item in measurements)
          _TimelineEntry(
            kind: _TimelineKind.measurement,
            date: item.measurement.createdAt,
            title: item.measurement.name,
            subtitle: '${_floorAreaLabel(item)} de piso',
            onTap: () => _openMeasurement(projectId!, item.measurement.id),
            onDelete: () =>
                _deleteMeasurement(item.measurement.id, item.measurement.name),
          ),
        for (final budget in budgets)
          _TimelineEntry(
            kind: _TimelineKind.budget,
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
          _projectId = projectId;
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

  String _floorAreaLabel(MeasurementWithDetails item) {
    final derived = RoomDerivedQuantities.fromMeasurement(
      lengthMeters: item.measurement.lengthMeters,
      widthMeters: item.measurement.widthMeters,
      heightMeters: item.measurement.heightMeters,
      openings: item.openings,
    );
    return '${derived.floorAreaSqM.toStringAsFixed(2)} m²';
  }

  Future<void> _openMeasurement(String projectId, String measurementId) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MeasurementFormScreen(
          projectId: projectId,
          measurementId: measurementId,
        ),
      ),
    );
    _load();
  }

  /// Excluir medição — não tinha nenhum caminho na UI até agora
  /// (`MeasurementsRepository.softDeleteMeasurement` existia, mas nenhuma
  /// tela chamava). Mesmo padrão de confirmação usado pra excluir cliente.
  Future<void> _deleteMeasurement(String measurementId, String name) async {
    final confirmed = await AppDialog.confirm(
      context,
      isDestructive: true,
      title: 'Excluir "$name"?',
      message: 'Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
    );
    if (confirmed == true) {
      await ref
          .read(measurementsRepositoryProvider)
          .softDeleteMeasurement(measurementId);
      if (mounted) {
        AppSnackBar.show(
          context,
          'Medição excluída.',
          variant: AppSnackBarVariant.destructive,
        );
        _load();
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

  Future<void> _addMeasurement() async {
    var projectId = _projectId;
    if (projectId == null) {
      final repo = ref.read(measurementsRepositoryProvider);
      final project = await repo.createProject(
        clientId: widget.client.id,
        name: 'Obra Principal',
      );
      projectId = project.id;
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MeasurementFormScreen(projectId: projectId!),
      ),
    );
    _load();
  }

  Future<void> _openAddMenu(BuildContext context) async {
    final action = await AppBottomSheet.showActions<String>(
      context,
      actions: const [
        AppBottomSheetAction(
          label: 'Novo orçamento',
          value: 'budget',
          icon: Icons.request_quote_outlined,
        ),
        AppBottomSheetAction(
          label: 'Nova medição',
          value: 'measurement',
          icon: Icons.straighten_outlined,
        ),
      ],
    );
    if (action == 'budget') {
      await _addBudget();
    } else if (action == 'measurement') {
      await _addMeasurement();
    }
  }

  /// Menu por item da linha do tempo — só as medições têm ação de
  /// excluir hoje (ver `_TimelineEntry.onDelete`). Ícone visível em vez de
  /// depender de long-press, pro mesmo público de baixa familiaridade
  /// digital que o resto do app já leva em conta.
  Future<void> _openTimelineEntryMenu(
    BuildContext context,
    _TimelineEntry entry,
  ) async {
    final action = await AppBottomSheet.showActions<String>(
      context,
      title: entry.title,
      actions: const [
        AppBottomSheetAction(
          label: 'Editar',
          value: 'edit',
          icon: Icons.edit_outlined,
        ),
        AppBottomSheetAction(
          label: 'Excluir',
          value: 'delete',
          icon: Icons.delete_outline,
          isDestructive: true,
        ),
      ],
    );
    if (action == 'edit') {
      entry.onTap();
    } else if (action == 'delete') {
      entry.onDelete?.call();
    }
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
        title: Text(widget.client.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _openClientMenu(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddMenu(context),
        tooltip: 'Adicionar',
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
                        'Este cliente ainda não tem medição nem orçamento.\n\n'
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
                          onMenu: entry.onDelete == null
                              ? null
                              : () => _openTimelineEntryMenu(context, entry),
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
    this.onMenu,
  });

  final _TimelineEntry entry;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onMenu;

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
      null => Icons.straighten_outlined,
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
              if (status != null)
                AppStatusChip.budget(status)
              else
                const AppStatusChip(label: 'Medição'),
              const Spacer(),
              Text(
                dateLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (onMenu != null)
                // `visualDensity` compacto: o menu fica na mesma linha do
                // selo e da data, e o alvo padrão de 48px empurraria a
                // altura do cabeçalho do card.
                IconButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  tooltip: 'Mais opções',
                  visualDensity: VisualDensity.compact,
                  onPressed: onMenu,
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
