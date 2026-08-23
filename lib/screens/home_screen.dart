import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_routes.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import 'client_form_screen.dart';

/// Tela inicial — um painel de despacho, não uma vitrine: a única tarefa
/// dela é levar o profissional pro fluxo que gera dinheiro o mais rápido
/// possível, ou de volta pro que ele já estava fazendo. "Novo Cliente" é
/// a ação primária (começa o fluxo medir→orçar→enviar); "Clientes" e
/// "Lista de Preços" são utilitárias — daí o peso visual desigual.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obrion Orçamentos'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppButton(
            label: 'Novo Cliente',
            icon: Icons.person_add_outlined,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClientFormScreen()),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ShortcutCard(
                  icon: Icons.groups_outlined,
                  label: 'Clientes',
                  onTap: () => context.push(AppRoutes.clients),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ShortcutCard(
                  icon: Icons.list_alt,
                  label: 'Lista de Preços',
                  onTap: () => context.push(AppRoutes.services),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: AppSpacing.xs),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
