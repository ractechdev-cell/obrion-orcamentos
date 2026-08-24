import 'package:go_router/go_router.dart';

import '../screens/main_shell.dart';
import 'app_routes.dart';

/// A raiz do app é a casca de navegação (`MainShell`, barra inferior com
/// Início/Clientes/Preços/Ajustes) — telas de detalhe são empilhadas por
/// cima dela via `Navigator.push` direto nas telas, não como rotas do
/// go_router (ver comentário em `main_shell.dart`). Por isso esta é a
/// única rota registrada aqui.
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainShell(),
    ),
  ],
);
