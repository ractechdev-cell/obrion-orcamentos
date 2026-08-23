import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/preferences_repository_provider.dart';
import '../widgets/app_loading.dart';
import 'budgets_list_screen.dart';
import 'clients_screen.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'services_screen.dart';
import 'settings_screen.dart';

/// Casca de navegação principal — barra inferior persistente com as 5
/// seções de primeiro nível do app. Cada aba mantém seu próprio estado
/// (posição de rolagem, busca em andamento) via `IndexedStack`; telas de
/// detalhe (cliente, medição, orçamento) continuam empilhadas por cima
/// via `Navigator.push`, cobrindo a barra — padrão comum do Flutter,
/// sem precisar de rotas aninhadas do go_router para um app sem
/// necessidade de deep link por aba.
///
/// Na primeira abertura, mostra o onboarding (3 telas) antes da barra —
/// ver `OnboardingScreen`.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  /// Só a aba visitada é montada — evita disparar consultas ao banco
  /// (Clientes, Preços) ou chamadas de plataforma (Ajustes) de abas que
  /// o usuário nunca abriu nesta sessão.
  final _visited = {0};

  /// `null` enquanto carrega, depois `true`/`false`.
  bool? _onboardingSeen;

  static const _tabs = [
    HomeScreen(),
    BudgetsListScreen(),
    ClientsScreen(),
    ServicesScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadOnboardingState();
  }

  Future<void> _loadOnboardingState() async {
    final seen = await ref.read(preferencesRepositoryProvider).getOnboardingSeen();
    if (mounted) setState(() => _onboardingSeen = seen);
  }

  Future<void> _completeOnboarding() async {
    await ref.read(preferencesRepositoryProvider).markOnboardingSeen();
    if (mounted) setState(() => _onboardingSeen = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingSeen == null) {
      return const Scaffold(body: AppLoading());
    }
    if (_onboardingSeen == false) {
      return OnboardingScreen(onDone: _completeOnboarding);
    }

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
            icon: Icon(Icons.request_quote_outlined),
            selectedIcon: Icon(Icons.request_quote),
            label: 'Orçamentos',
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
