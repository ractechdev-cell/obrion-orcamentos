import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tipografia do design system Safety Industrial (ver
/// `docs/stitch_document_theme_generator/safety_industrial/DESIGN.md`).
///
/// **Hanken Grotesk** foi escolhida no design pela clareza e pelo ar
/// industrial. Vem empacotada como asset (`assets/fonts/`), não pelo
/// pacote `google_fonts`: o app é local-first e precisa renderizar certo
/// sem sinal no canteiro — fonte baixada em runtime cairia no fallback
/// justamente no cenário de uso principal.
///
/// A escala é a do design, convertida de `px/line-height` (CSS) para
/// `fontSize`/`height` (Flutter, onde `height` é *múltiplo* do tamanho —
/// por isso 36px de entrelinha sobre 28px de fonte vira `1.286`).
class AppTypography {
  const AppTypography._();

  /// Nome da família registrado no `pubspec.yaml`.
  static const String fontFamily = 'HankenGrotesk';

  // ── Escala do design ───────────────────────────────────────
  // headline-md         28px / 36px / 700
  // headline-md-mobile  24px / 32px / 700  → usado como headlineSmall
  // title-lg            20px / 28px / 600
  // title-md            16px / 24px / 600
  // body-lg             16px / 24px / 400
  // body-md             14px / 20px / 400
  // body-sm             12px / 16px / 400
  // label-lg            14px / 20px / 500 / +0.1 letter-spacing
  // label-md            12px / 16px / 500

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
  );

  /// `headline-md-mobile` do design — o tamanho que as manchetes assumem
  /// em coluna estreita. Como este app é mobile-only, é este o usado na
  /// marca ("OBRION") e no valor de destaque do painel.
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );

  /// Fora da escala do design — o Material precisa de `labelSmall` para
  /// componentes internos (ex.: rótulo de `NavigationBar` comprimido).
  /// Derivado de `label-md` um passo abaixo, não inventado do zero.
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    height: 16 / 11,
    fontWeight: FontWeight.w500,
  );

  /// `TextTheme` completo, já com a família e a cor de texto padrão
  /// aplicadas — o tema não deve repetir `fontFamily` campo a campo.
  static TextTheme textTheme() {
    const base = TextTheme(
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
    return base.apply(
      fontFamily: fontFamily,
      bodyColor: AppColors.onSurface,
      displayColor: AppColors.onSurface,
    );
  }
}
