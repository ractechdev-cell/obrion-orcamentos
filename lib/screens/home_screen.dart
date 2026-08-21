import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/app_routes.dart';

/// Placeholder até os módulos de negócio da Fase 1 (Clientes, Medição,
/// Lista de preços, Orçamento, PDF) existirem — ver CLAUDE.md, roadmap.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Obrion Orçamentos'),
        actions: [
          IconButton(
            onPressed: () => context.push('/clients'),
            icon: const Icon(Icons.people_outline),
            tooltip: 'Clientes',
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: const Center(child: Text('Nenhum orçamento ainda.')),
    );
  }
}
