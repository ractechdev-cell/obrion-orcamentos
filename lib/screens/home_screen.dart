import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/budgets_repository_provider.dart';
import '../providers/clients_repository_provider.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import 'client_form_screen.dart';

/// Aba inicial — um painel de despacho, não uma vitrine: a única tarefa
/// dela é levar o profissional pro fluxo que gera dinheiro o mais rápido
/// possível. Clientes, Lista de Preços e Configurações agora são abas
/// próprias da barra inferior (ver `main_shell.dart`), então esta tela
/// fica só com a ação primária e um resumo rápido — sem atalho redundante
/// com a barra.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.request_quote_outlined, color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Comece um orçamento novo',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Cadastre o cliente e siga para medir e montar o orçamento.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Novo Cliente',
          icon: Icons.person_add_outlined,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ClientFormScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const _HomeSummary(),
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

/// Resumo do estado atual — reaproveita o mesmo dado que já alimenta o
/// chip "Aguardando há Xd" em `budgets_screen.dart` (ver
/// `BudgetsRepository.countAwaitingResponse`), agora visível assim que o
/// app abre, sem precisar entrar em Clientes/Orçamentos primeiro.
///
/// Consulta única (`initState`, não `watch()`) de propósito: é só um
/// retrato de "como estão as coisas agora", não precisa ficar reativo
/// segundo a segundo enquanto a pessoa olha a Home.
class _HomeSummary extends ConsumerStatefulWidget {
  const _HomeSummary();

  @override
  ConsumerState<_HomeSummary> createState() => _HomeSummaryState();
}

class _HomeSummaryState extends ConsumerState<_HomeSummary> {
  int? _clientCount;
  int? _awaitingCount;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final clients = await ref.read(clientsRepositoryProvider).countActive();
    final awaiting = await ref.read(budgetsRepositoryProvider).countAwaitingResponse();
    if (mounted) {
      setState(() {
        _clientCount = clients;
        _awaitingCount = awaiting;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryStat(
            icon: Icons.groups_outlined,
            value: _clientCount,
            label: 'clientes',
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SummaryStat(
            icon: Icons.hourglass_bottom_outlined,
            value: _awaitingCount,
            label: 'aguardando resposta',
            warn: (_awaitingCount ?? 0) > 0,
          ),
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.icon,
    required this.value,
    required this.label,
    this.warn = false,
  });

  final IconData icon;
  final int? value;
  final String label;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = warn ? context.semanticColors.warning : colorScheme.primary;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value?.toString() ?? '—',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
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
