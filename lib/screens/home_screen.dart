import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/budgets_repository_provider.dart';
import '../repositories/budgets_repository.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/currency_format.dart';
import '../utils/follow_up_message.dart';
import '../utils/phone_actions.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import 'budget_form_screen.dart';
import 'client_form_screen.dart';

/// Aba inicial — painel simples do negócio, não só porta de entrada pro
/// "Novo orçamento" (ver docs/ROADMAP_UX_UI_E_FEATURES_APP1.md, seção 3).
/// Clientes, Lista de Preços e Configurações são abas próprias da barra
/// inferior (ver `main_shell.dart`) — decisão já tomada de não duplicar
/// esses atalhos aqui (ver CHANGELOG, "grade de atalhos... descartada").
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HomeSummary(),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Novo Cliente',
          icon: Icons.person_add_outlined,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ClientFormScreen()),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Obrion Orçamentos')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (reduceMotion)
            content
          else
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              builder: (context, value, child) => Opacity(
                opacity: value,
                child: Transform.translate(offset: Offset(0, 12 * (1 - value)), child: child),
              ),
              child: content,
            ),
        ],
      ),
    );
  }
}

/// Resumo financeiro + pendências — consulta única (`initState`, não
/// `watch()`) de propósito: é um retrato de "como estão as coisas agora",
/// não precisa ficar reativo segundo a segundo enquanto a pessoa olha a
/// Home (mesmo raciocínio de `ClientsRepository.countActive`).
class _HomeSummary extends ConsumerStatefulWidget {
  const _HomeSummary();

  @override
  ConsumerState<_HomeSummary> createState() => _HomeSummaryState();
}

class _HomeSummaryState extends ConsumerState<_HomeSummary> {
  HomeSummary? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final summary = await ref.read(budgetsRepositoryProvider).loadHomeSummary();
    if (mounted) setState(() => _summary = summary);
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumo', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _SummaryStat(
                icon: Icons.request_quote_outlined,
                value: summary == null ? null : formatCurrencyBrl(summary.totalOpenCents),
                label: 'em orçamentos',
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _SummaryStat(
                icon: Icons.hourglass_bottom_outlined,
                value: summary == null ? null : formatCurrencyBrl(summary.totalAwaitingCents),
                label: 'aguardando resposta',
                warn: (summary?.totalAwaitingCents ?? 0) > 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _SummaryStat(
                icon: Icons.check_circle_outline,
                value: summary == null ? null : formatCurrencyBrl(summary.totalAcceptedCents),
                label: 'aprovados',
                success: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _SummaryStat(
                icon: Icons.payments_outlined,
                value: summary == null ? null : formatCurrencyBrl(summary.totalReceivedCents),
                label: 'recebidos',
                success: true,
              ),
            ),
          ],
        ),
        if (summary != null && summary.pending.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text('Pendências', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          for (final item in summary.pending) ...[
            _PendingBudgetTile(item: item),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ],
    );
  }
}

class _PendingBudgetTile extends StatelessWidget {
  const _PendingBudgetTile({required this.item});

  final PendingBudgetSummary item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BudgetFormScreen(clientId: item.clientId, budgetId: item.budgetId),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.clientName, style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      item.daysWaiting <= 0
                          ? 'Aguardando resposta'
                          : 'Aguardando há ${item.daysWaiting}d',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: item.daysWaiting >= 3
                                ? context.semanticColors.warning
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                formatCurrencyBrl(item.totalCents),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (item.clientPhone != null && item.clientPhone!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                onPressed: () => PhoneActions.openWhatsApp(
                  context,
                  item.clientPhone!,
                  message: followUpMessage(item.clientName),
                ),
                icon: const Icon(Icons.chat_outlined, size: 16),
                label: const Text('Enviar lembrete'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.value,
    required this.label,
    this.warn = false,
    this.success = false,
  });

  final IconData icon;
  final String? value;
  final String label;
  final bool warn;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = warn
        ? context.semanticColors.warning
        : success
            ? context.semanticColors.success
            : colorScheme.primary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value ?? '—',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
