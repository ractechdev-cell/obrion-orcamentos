import 'package:go_router/go_router.dart';

import '../screens/client_form_screen.dart';
import '../screens/main_shell.dart';
import '../screens/measurement_form_screen.dart';
import '../screens/measurements_screen.dart';
import 'app_routes.dart';

/// A raiz do app é a casca de navegação (`MainShell`, barra inferior com
/// Início/Clientes/Preços/Ajustes) — só telas de detalhe continuam como
/// rotas próprias, empilhadas por cima dela.
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainShell(),
    ),
    GoRoute(
      path: '/clients/new',
      builder: (context, state) => const ClientFormScreen(),
    ),
    GoRoute(
      path: '/measurements/:projectId',
      builder: (context, state) => MeasurementsScreen(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
    GoRoute(
      path: '/measurements/:projectId/new',
      builder: (context, state) => MeasurementFormScreen(
        projectId: state.pathParameters['projectId']!,
      ),
    ),
  ],
);
