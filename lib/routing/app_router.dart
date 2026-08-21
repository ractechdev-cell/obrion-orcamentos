import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import 'app_routes.dart';

/// Esqueleto de navegação da Fase 0. Os módulos de negócio da Fase 1
/// (Clientes, Medição, Lista de preços, Orçamento, PDF) entram aqui como
/// novas rotas, sem precisar redesenhar esta estrutura.
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
