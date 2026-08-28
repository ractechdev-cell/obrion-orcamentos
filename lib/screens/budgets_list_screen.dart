import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/enums.dart';
import '../providers/budgets_repository_provider.dart';
import '../providers/clients_repository_provider.dart';
import '../widgets/app_dialog.dart';
import '../repositories/budgets_repository.dart';
import '../repositories/example_data_seeder.dart';
import '../theme/app_spacing.dart';
import '../utils/currency_format.dart';
import '../utils/follow_up_message.dart';
import '../utils/phone_actions.dart';
import '../widgets/app_card.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error.dart';
import '../widgets/app_filter_chips.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_search_field.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_status_chip.dart';
import 'budget_form_screen.dart';
import 'budget_wizard_screen.dart';

/// Todos os orçamentos, de todos os clientes, numerados — visão geral que
/// o histórico por cliente (`ClientDetailScreen`) não substitui: aqui dá
/// pra ver o negócio inteiro de uma vez, não cliente por cliente.
class BudgetsListScreen extends ConsumerStatefulWidget {
  const BudgetsListScreen({super.key});

  @override
  ConsumerState<BudgetsListScreen> createState() => _BudgetsListScreenState();
}

class _BudgetsListScreenState extends ConsumerState<BudgetsListScreen> {
  String _query = '';
  BudgetStatus? _statusFilter;

  Future<void> _createBudget(BuildContext context, WidgetRef ref) async {
    final clients = await ref.read(clientsRepositoryProvider).watchAll().first;
    if (!context.mounted) return;

    if (clients.isEmpty) {
      AppSnackBar.show(
        context,
        'Cadastre um cliente primeiro, na aba Clientes.',
        variant: AppSnackBarVariant.warning,
      );
      return;
    }

    final selected = await showModalBottomSheet<Client>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Text(
                  'Orçamento para qual cliente?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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
      // Wizard, não o formulário direto: criar orçamento tem que abrir do
      // mesmo jeito aqui e na ficha do cliente. Antes cada caminho abria
      // uma tela diferente pro mesmo ato.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BudgetWizardScreen(clientId: selected.id),
        ),
      );
    }
  }

  Future<void> _deleteBudget(
    BuildContext context,
    BudgetWithClientName entry,
  ) async {
    final confirmed = await AppDialog.confirm(
      context,
      isDestructive: true,
      title: 'Excluir orçamento?',
      message: 'Os itens e pagamentos registrados nele saem junto. '
          'Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(budgetsRepositoryProvider).softDelete(entry.budget.id);
    if (context.mounted) {
      AppSnackBar.show(
        context,
        'Orçamento excluído.',
        variant: AppSnackBarVariant.destructive,
      );
    }
  }

  /// Busca o telefone do cliente só na hora de mandar o lembrete (evita
  /// carregar isso pra lista inteira via `BudgetWithClientName`, que hoje
  /// não guarda telefone — ver `PhoneActions.openWhatsApp`).
  Future<void> _sendFollowUp(
    BuildContext context,
    WidgetRef ref,
    String clientId,
    String clientName,
  ) async {
    final client = await ref.read(clientsRepositoryProvider).getById(clientId);
    final phone = client?.phone;
    if (!context.mounted) return;
    if (phone == null || phone.isEmpty) {
      AppSnackBar.show(
        context,
        'Esse cliente não tem telefone salvo.',
        variant: AppSnackBarVariant.warning,
      );
      return;
    }
    await PhoneActions.openWhatsApp(
      context,
      phone,
      message: followUpMessage(clientName),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          final all = snapshot.data!;

          if (all.isEmpty) {
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

          // `all` vem do mais antigo pro mais novo — número = posição
          // nessa ordem (estável), lista exibida do mais novo pro mais
          // antigo (convenção do resto do app). A numeração é atribuída
          // antes de filtrar, pra que o "nº 3" continue sendo o mesmo
          // orçamento independentemente do filtro ativo.
          final numbered = [
            for (var i = all.length - 1; i >= 0; i--)
              (number: i + 1, entry: all[i]),
          ];

          final query = _query.trim().toLowerCase();
          final visible = numbered.where((row) {
            final matchesStatus =
                _statusFilter == null || row.entry.budget.status == _statusFilter;
            final matchesQuery = query.isEmpty ||
                row.entry.clientName.toLowerCase().contains(query);
            return matchesStatus && matchesQuery;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: AppSearchField(
                  hint: 'Buscar por cliente...',
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              AppFilterChips<BudgetStatus>(
                selected: _statusFilter,
                onSelected: (value) => setState(() => _statusFilter = value),
                options: const [
                  AppFilterOption(value: null, label: 'Todos'),
                  AppFilterOption(
                    value: BudgetStatus.draft,
                    label: 'Rascunho',
                  ),
                  AppFilterOption(value: BudgetStatus.sent, label: 'Enviado'),
                  AppFilterOption(
                    value: BudgetStatus.accepted,
                    label: 'Aceito',
                  ),
                  AppFilterOption(
                    value: BudgetStatus.declined,
                    label: 'Recusado',
                  ),
                ],
              ),
              Expanded(
                child: visible.isEmpty
                    ? AppEmptyState(
                        message: query.isNotEmpty
                            ? 'Nenhum orçamento encontrado para "$_query".'
                            : 'Nenhum orçamento com esse status.',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.sm,
                          AppSpacing.md,
                          // Espaço extra no fim pra que o último card não
                          // fique atrás do botão flutuante.
                          AppSpacing.xxl + AppSpacing.lg,
                        ),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final (:number, :entry) = visible[index];
                          return _BudgetCard(
                            number: number,
                            entry: entry,
                            onFollowUp: () => _sendFollowUp(
                              context,
                              ref,
                              entry.budget.clientId,
                              entry.clientName,
                            ),
                            onDelete: () => _deleteBudget(context, entry),
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

/// Card de orçamento no formato dos modelos: título e data à esquerda,
/// selo de estado à direita, e uma faixa inferior separada por filete com
/// o valor e a ação principal.
class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.number,
    required this.entry,
    required this.onFollowUp,
    required this.onDelete,
  });

  final int number;
  final BudgetWithClientName entry;
  final VoidCallback onFollowUp;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final budget = entry.budget;
    final isDraft = budget.status == BudgetStatus.draft;

    // Rascunho continua no wizard (é onde ele foi montado); orçamento já
    // fechado abre no formulário, que é a tela de gestão — status,
    // pagamento, recibo, compartilhar.
    void open() => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => isDraft
                ? BudgetWizardScreen(
                    clientId: budget.clientId,
                    budgetId: budget.id,
                  )
                : BudgetFormScreen(
                    clientId: budget.clientId,
                    budgetId: budget.id,
                  ),
          ),
        );

    final date = budget.createdAt;
    final dateLabel = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';

    return AppCard(
      onTap: open,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orçamento nº $number — ${entry.clientName}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Criado em $dateLabel',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppStatusChip.budget(budget.status),
              PopupMenuButton<String>(
                iconSize: 20,
                padding: EdgeInsets.zero,
                tooltip: 'Mais ações',
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        'Excluir orçamento',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  // Rascunho sem item ainda não tem valor a mostrar — o
                  // traço evita anunciar "R$ 0,00" como se fosse decisão
                  // do profissional.
                  isDraft && entry.totalCents == 0
                      ? '—'
                      : formatCurrencyBrl(entry.totalCents),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              TextButton(
                onPressed: open,
                child: Text(isDraft ? 'Continuar' : 'Ver detalhes'),
              ),
            ],
          ),
          if (budget.status == BudgetStatus.sent) ...[
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onFollowUp,
                icon: const Icon(
                  Icons.notifications_active_outlined,
                  size: 18,
                ),
                label: const Text('Enviar lembrete'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
