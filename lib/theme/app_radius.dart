/// Escala de raio de canto — usar sempre estes valores em vez de números
/// soltos, mesmo motivo do `AppSpacing`. Extraída do design system Safety
/// Industrial (docs/stitch_document_theme_generator).
///
/// Regra: cards e inputs usam `sm` (4px) pra parecerem "ferramenta" e não
/// "software bonito". Botões usam `md` (8px) pra serem visivelmente
/// clicáveis. Badges e avatares usam `full` pra serem circulares.
class AppRadius {
  const AppRadius._();

  /// Cantos sutis — inputs e badges pequenos
  static const double xs = 4;

  /// Padrão — botões, bottom sheets, diálogos
  static const double sm = 8;

  /// Cards e containers de seção
  static const double md = 12;

  /// Destaque — modais, drawers
  static const double lg = 24;

  /// Circular — avatares, badges, FABs
  static const double full = 999;
}
