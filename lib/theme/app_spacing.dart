/// Escala de espaçamento — usar sempre estes valores em padding/margin/gap,
/// nunca números soltos, pela mesma razão que cor nunca é hardcoded: manter
/// consistência entre telas sem depender de memória ou convenção tácita.
class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}
