import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import 'client_form_screen.dart';

/// Aba inicial — um painel de despacho, não uma vitrine: a única tarefa
/// dela é levar o profissional pro fluxo que gera dinheiro o mais rápido
/// possível. Clientes, Lista de Preços e Configurações agora são abas
/// próprias da barra inferior (ver `main_shell.dart`), então esta tela
/// fica só com a ação primária — sem atalho redundante com a barra.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Obrion Orçamentos')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Comece um orçamento novo',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Cadastre o cliente e siga para medir e montar o orçamento.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Novo Cliente',
            icon: Icons.person_add_outlined,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClientFormScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
