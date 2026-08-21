import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const ObrionOrcamentosApp());
}

class ObrionOrcamentosApp extends StatelessWidget {
  const ObrionOrcamentosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Obrion Orçamentos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: const _HomePlaceholder(),
    );
  }
}

/// Placeholder até a navegação (próximo passo da Fase 0) e as telas de
/// negócio (Fase 1 — Clientes, Medição, Orçamento, PDF) existirem.
class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Obrion Orçamentos')),
      body: const Center(child: Text('Tema configurado.')),
    );
  }
}
