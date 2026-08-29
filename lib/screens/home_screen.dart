import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/budgets_repository_provider.dart';
import '../providers/home_refresh_provider.dart';
import '../providers/profile_repository_provider.dart';
import '../repositories/budgets_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/currency_format.dart';
import '../utils/follow_up_message.dart';
import '../utils/phone_actions.dart';
import '../widgets/app_avatar.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_metric_card.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_segmented_bar.dart';
import '../widgets/app_status_chip.dart';
import 'budget_form_screen.dart';
import 'client_form_screen.dart';

/// Aba inicial — painel do negócio, não só porta de entrada pro "Novo
/// orçamento" (ver docs/ROADMAP_UX_UI_E_FEATURES_APP1.md, seção 3).
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
        const _Greeting(),
        const SizedBox(height: AppSpacing.lg),
        const _HomeSummary(),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // Marca em caixa alta e âmbar, como nos modelos — a Home é a
        // única tela que mostra o nome do produto em vez do nome da
        // seção; nas outras o título já diz onde a pessoa está.
        title: Text(
          'OBRION',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(color: AppColors.safetyAmber, letterSpacing: -0.5),
        ),
      ),
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
                child: Transform.translate(
                  offset: Offset(0, 12 * (1 - value)),
                  child: child,
                ),
              ),
              child: content,
            ),
        ],
      ),
    );
  }
}

/// Saudação por período do dia, com o nome do perfil quando existir.
class _Greeting extends ConsumerWidget {
  const _Greeting();

  static String _timeOfDayGreeting(DateTime now) {
    if (now.hour < 12) return 'Bom dia';
    if (now.hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final greeting = _timeOfDayGreeting(DateTime.now());

    return FutureBuilder(
      future: ref.read(profileRepositoryProvider).getProfile(),
      builder: (context, snapshot) {
        // O primeiro nome basta — "Bom dia, João Silva Engenharia 👋"
        // ficaria longo e estranho.
        final rawName = snapshot.data?.name?.trim() ?? '';
        final firstName = rawName.isEmpty
            ? null
            : rawName.split(RegExp(r'\s+')).first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              firstName == null ? '$greeting 👋' : '$greeting, $firstName 👋',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Resumo das suas atividades de hoje.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
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
  int _lastRefreshToken = -1;

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
    // `HomeScreen` fica sempre montada (`IndexedStack`), então escuta o
    // contador de `homeRefreshProvider` para recarregar sempre que algo
    // relevante mudar em outra tela (pagamento, status, novo orçamento).
    final refreshToken = ref.watch(homeRefreshProvider);
    if (refreshToken != _lastRefreshToken) {
      _lastRefreshToken = refreshToken;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    }

    final summary = _summary;
    final semantic = context.semanticColors;
    String money(int? cents) => cents == null ? '—' : formatCurrencyBrl(cents);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Destaque: o dinheiro que já entrou. Sem o selo de variação
        // ("+12% vs mês ant.") dos modelos — o app ainda não guarda
        // histórico mensal, e inventar a comparação daria ao profissional
        // uma leitura falsa do próprio negócio.
        AppMetricCard.featured(
          label: 'Recebidos',
          value: money(summary?.totalReceivedCents),
          icon: Icons.payments_outlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        // `IntrinsicHeight` dá altura limitada ao `Row` para que os dois
        // cards fiquem do mesmo tamanho mesmo com rótulos de alturas
        // diferentes. Sem ele, `CrossAxisAlignment.stretch` estoura: o
        // eixo vertical é ilimitado dentro do `ListView`.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AppMetricCard(
                  label: 'Aguardando',
                  value: money(summary?.totalAwaitingCents),
                  icon: Icons.hourglass_bottom_outlined,
                  valueColor: (summary?.totalAwaitingCents ?? 0) > 0
                      ? semantic.warning
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppMetricCard(
                  label: 'Aprovados',
                  value: money(summary?.totalAcceptedCents),
                  icon: Icons.thumb_up_outlined,
                  valueColor: semantic.success,
                ),
              ),
            ],
          ),
        ),
        if (summary != null &&
            (summary.totalAcceptedCents + summary.totalAwaitingCents) > 0) ...[
          const SizedBox(height: AppSpacing.md),
          _BusinessHealth(summary: summary),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Novo Cliente',
          icon: Icons.person_add_outlined,
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ClientFormScreen())),
        ),
        if (summary != null && summary.pending.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          const AppSectionHeader(title: 'Pendências'),
          const SizedBox(height: AppSpacing.sm),
          for (final item in summary.pending) ...[
            _PendingBudgetTile(item: item),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ],
    );
  }
}

/// Proporção aprovado × aguardando — a "Saúde do Negócio" dos modelos.
class _BusinessHealth extends StatelessWidget {
  const _BusinessHealth({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final accepted = summary.totalAcceptedCents;
    final awaiting = summary.totalAwaitingCents;
    final total = accepted + awaiting;
    final percent = total == 0 ? 0 : (accepted / total * 100).round();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SAÚDE DO NEGÓCIO',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                '$percent% aprovado',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppSegmentedBar(
            segments: [
              AppBarSegment(
                value: accepted,
                color: semantic.success,
                label: 'Aprovados',
              ),
              AppBarSegment(
                value: awaiting,
                color: semantic.warning,
                label: 'Aguardando',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingBudgetTile extends StatelessWidget {
  const _PendingBudgetTile({required this.item});

  final PendingBudgetSummary item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhone = (item.clientPhone ?? '').isNotEmpty;

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BudgetFormScreen(
            clientId: item.clientId,
            budgetId: item.budgetId,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: item.clientName, size: 40),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // `Wrap`: valor e selo lado a lado quando cabem, em
                    // duas linhas quando o nome/valor forem longos.
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          formatCurrencyBrl(item.totalCents),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.safetyAmber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AppStatusChip(
                          label: item.daysWaiting <= 0
                              ? 'Enviado hoje'
                              : 'Enviado há ${item.daysWaiting}d',
                          icon: Icons.schedule,
                          tone: item.daysWaiting >= 3
                              ? AppStatusTone.warning
                              : AppStatusTone.neutral,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasPhone) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => PhoneActions.openWhatsApp(
                  context,
                  item.clientPhone!,
                  message: followUpMessage(item.clientName),
                ),
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: const Text('Enviar lembrete'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
