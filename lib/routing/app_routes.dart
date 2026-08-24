/// Caminhos de rota — nome centralizado para não espalhar strings soltas de
/// navegação pelo app (mesma razão de não hardcodar cor: uma fonte única).
class AppRoutes {
  const AppRoutes._();

  /// Raiz do app — a casca de navegação (`MainShell`), não mais uma
  /// tela isolada. Clientes/Preços/Ajustes viraram abas dela; ver
  /// `main_shell.dart`.
  static const home = '/';
}
