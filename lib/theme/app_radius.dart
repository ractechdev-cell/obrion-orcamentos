/// Escala de raio de canto — usar sempre estes valores em vez de números
/// soltos, mesmo motivo do `AppSpacing`. Cantos mais arredondados (`md`)
/// em vez do padrão Material anterior (8/12) lêem como "ferramenta fácil",
/// não "software técnico" — decisão de tema de 23/08/2026, ver CLAUDE.md.
class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 16;
  static const double pill = 999;
}
