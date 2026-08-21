import 'package:flutter/material.dart';

/// Placeholder da tela de configurações (módulo Settings do Core —
/// ver docs/APP_FACTORY_CORE.md).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: const Center(child: Text('Em breve.')),
    );
  }
}
