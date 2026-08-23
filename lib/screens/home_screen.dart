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
