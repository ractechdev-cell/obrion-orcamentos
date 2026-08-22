import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_routes.dart';
import '../widgets/app_card.dart';
import 'client_form_screen.dart';

/// Tela inicial com acesso rápido às funções centrais da Fase 1.
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
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: AppCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ClientFormScreen()),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.person_add_outlined, size: 32, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      const Text('Novo Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppCard(
                  onTap: () => context.push(AppRoutes.services),
                  child: Column(
                    children: [
                      Icon(Icons.list_alt, size: 32, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 8),
                      const Text('Lista de Preços', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
