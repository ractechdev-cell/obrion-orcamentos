import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../budget/budget_calculations.dart';
import '../database/database.dart';
import '../providers/budget_templates_repository_provider.dart';
import '../theme/app_spacing.dart';
import '../utils/currency_format.dart';
import '../widgets/app_card.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_snackbar.dart';

/// Lista de "Meus Modelos" — ver docs/ROADMAP_UX_UI_E_FEATURES_APP1.md,
/// seção 14. Um modelo nasce sempre a partir de um orçamento existente
/// ("Salvar como modelo", ver `budget_form_screen.dart`); aqui só se
/// consulta, usa ou exclui — nunca edita depois de criado.
///
/// Fluxo de uso: aberta a partir da Etapa 1 do wizard ("Usar modelo") em
/// modo seleção (retorna o `BudgetTemplate` escolhido via `Navigator.pop`)
/// ou a partir de Ajustes/Orçamentos em modo consulta (sem retorno,
/// só gerenciar/excluir).
class BudgetTemplatesScreen extends ConsumerWidget {
  const BudgetTemplatesScreen({super.key, this.selectionMode = false});

  /// Quando `true`, tocar num modelo devolve o `BudgetTemplate` via
  /// `Navigator.pop` em vez de só abrir um menu de gerenciamento.
  final bool selectionMode;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    BudgetTemplate template,
  ) async {
    final confirmed = await AppDialog.confirm(
      context,
      isDestructive: true,
      title: 'Excluir modelo?',
      message: '"${template.name}" não pode ser recuperado depois.',
      confirmLabel: 'Excluir',
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(budgetTemplatesRepositoryProvider).softDelete(template.id);
    if (context.mounted) {
      AppSnackBar.show(
        context,
        'Modelo excluído.',
        variant: AppSnackBarVariant.destructive,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(budgetTemplatesRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(selectionMode ? 'Escolher modelo' : 'Meus Modelos'),
      ),
      body: StreamBuilder<List<BudgetTemplate>>(
        stream: repo.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const AppError(message: 'Falha ao carregar modelos.');
          }
          if (!snapshot.hasData) {
            return const AppLoading();
          }
          final templates = snapshot.data!;

          if (templates.isEmpty) {
            return const AppEmptyState(
              icon: Icons.description_outlined,
              message: 'Você ainda não tem nenhum modelo salvo.\n\n'
                  'Abra um orçamento pronto e toque em "Salvar como '
                  'modelo" pra reaproveitar os mesmos itens depois.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: templates.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final template = templates[index];
              return _TemplateCard(
                template: template,
                selectionMode: selectionMode,
                onTap: () {
                  if (selectionMode) {
                    Navigator.of(context).pop(template);
                  }
                },
                onDelete: () => _delete(context, ref, template),
              );
            },
          );
        },
      ),
    );
  }
}

class _TemplateCard extends ConsumerWidget {
  const _TemplateCard({
    required this.template,
    required this.selectionMode,
    required this.onTap,
    required this.onDelete,
  });

  final BudgetTemplate template;
  final bool selectionMode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                FutureBuilder<BudgetTemplateSummary>(
                  future: _loadSummary(ref),
                  builder: (context, snapshot) {
                    final summary = snapshot.data;
                    if (summary == null) {
                      return const SizedBox(height: 16);
                    }
                    return Text(
                      '${summary.itemCount} '
                      '${summary.itemCount == 1 ? "item" : "itens"} · '
                      '${formatCurrencyBrl(summary.totalCents)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          if (selectionMode)
            const Icon(Icons.chevron_right)
          else
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              tooltip: 'Excluir modelo',
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  Future<BudgetTemplateSummary> _loadSummary(WidgetRef ref) async {
    final data = await ref
        .read(budgetTemplatesRepositoryProvider)
        .getWithItems(template.id);
    final items = data?.items ?? const [];
    final totals = BudgetTotals.fromItems(
      items: items
          .map((i) => BudgetLineItem(quantity: i.quantity, unitPriceCents: i.unitPriceCents))
          .toList(),
      discountCents: template.discountCents,
    );
    return BudgetTemplateSummary(
      itemCount: items.length,
      totalCents: totals.totalCents,
    );
  }
}

class BudgetTemplateSummary {
  const BudgetTemplateSummary({required this.itemCount, required this.totalCents});

  final int itemCount;
  final int totalCents;
}
