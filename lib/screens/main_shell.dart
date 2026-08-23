import 'package:flutter/material.dart';

import 'clients_screen.dart';
import 'home_screen.dart';
import 'services_screen.dart';
import 'settings_screen.dart';

/// Casca de navegação principal — barra inferior persistente com as 4
/// seções de primeiro nível do app. Cada aba mantém seu próprio estado
/// (posição de rolagem, busca em andamento) via `IndexedStack`; telas de
/// detalhe (cliente, medição, orçamento) continuam empilhadas por cima
/// via `Navigator.push`, cobrindo a barra — padrão comum do Flutter,
/// sem precisar de rotas aninhadas do go_router para um app sem
/// necessidade de deep link por aba.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  /// Só a aba visitada é montada — evita disparar consultas ao banco
  /// (Clientes, Preços) ou chamadas de plataforma (Ajustes) de abas que
  /// o usuário nunca abriu nesta sessão.
  final _visited = {0};

  static const _tabs = [
    HomeScreen(),
    ClientsScreen(),
    ServicesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < _tabs.length; i++)
            _visited.contains(i) ? _tabs[i] : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() {
          _index = index;
          _visited.add(index);
        }),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Clientes',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Preços',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
