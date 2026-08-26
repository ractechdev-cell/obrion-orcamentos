import 'package:flutter/material.dart';

/// Seed color do esquema de cores Material 3 — fonte única da identidade
/// visual do Obrion Orçamentos (ver docs/APP_FACTORY_CORE.md, "Identidade
/// visual da família": cada app da linha tem sua própria cor de destaque).
/// Trocar a marca deste app = trocar só este valor.
///
/// Âmbar de segurança (23/08/2026, revisão de tema) — não é escolha
/// estética solta: é a cor do canteiro de obra (capacete, colete, cone,
/// faixa zebrada), o que a torna reconhecível para o público de baixa
/// familiaridade digital sem precisar aprender nada novo, e de alto
/// contraste para leitura ao sol. Antes era um azul corporativo genérico
/// — a mesma cor que a maioria dos apps concorrentes de orçamento de obra
/// já usa (ver pesquisa de mercado no CLAUDE.md).
const Color obrionSeed = Color(0xFFC2680A);

/// Paleta estendida extraída do design system Safety Industrial
/// (docs/stitch_document_theme_generator). Usada quando o ColorScheme
/// do Material 3 não gera o tom exato necessário.
class AppColors {
  const AppColors._();

  // ── Primary ──────────────────────────────────────────────
  static const primary = Color(0xFF8F4A00);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFB35E00);
  static const onPrimaryContainer = Color(0xFFFFFFFF);
  static const primaryFixed = Color(0xFFFFDCC4);
  static const primaryFixedDim = Color(0xFFFFB780);

  // ── Secondary ────────────────────────────────────────────
  static const secondary = Color(0xFF535F70);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFD7E3F7);
  static const onSecondaryContainer = Color(0xFF101C2B);

  // ── Tertiary ─────────────────────────────────────────────
  static const tertiary = Color(0xFF6B5778);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFF2DAFF);
  static const onTertiaryContainer = Color(0xFF251431);

  // ── Surface / Background ─────────────────────────────────
  static const surface = Color(0xFFFFFBFF);
  static const onSurface = Color(0xFF201A17);
  static const surfaceVariant = Color(0xFFF3DFD4);
  static const onSurfaceVariant = Color(0xFF52443B);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFFFF1E9);
  static const surfaceContainer = Color(0xFFFCEBE1);
  static const surfaceContainerHigh = Color(0xFFF7E5DB);
  static const surfaceContainerHighest = Color(0xFFF1DFD6);
  static const surfaceDim = Color(0xFFE4D7CF);
  static const surfaceBright = Color(0xFFFFFBFF);
  static const surfaceTint = Color(0xFF8F4A00);

  // ── Outline ──────────────────────────────────────────────
  static const outline = Color(0xFF85746A);
  static const outlineVariant = Color(0xFFD8C2B6);

  // ── Error ────────────────────────────────────────────────
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // ── Inverse ──────────────────────────────────────────────
  static const inverseSurface = Color(0xFF362F2B);
  static const onInverseSurface = Color(0xFFFBEEE8);
  static const inversePrimary = Color(0xFFFFB780);
  static const scrim = Color(0xFF000000);
  static const shadow = Color(0xFF000000);

  // ── Sombras (extraídas do design system) ─────────────────
  static const List<BoxShadow> shadowSm = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> shadowMd = [
    BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> shadowLg = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 4)),
  ];
}

/// success/warning têm o mesmo peso semântico de error na regra de tema do
/// CLAUDE.md, mas o Material 3 ColorScheme só modela error nativamente —
/// por isso entram como paleta própria, consumida via AppSemanticColors.
class AppSemanticPalette {
  const AppSemanticPalette._();

  static const success = Color(0xFF2E7D32);
  static const onSuccess = Color(0xFFFFFFFF);
  static const successContainer = Color(0xFFC8E6C9);
  static const onSuccessContainer = Color(0xFF0B3B0E);

  static const warning = Color(0xFFED6C02);
  static const onWarning = Color(0xFFFFFFFF);
  static const warningContainer = Color(0xFFFFE0B2);
  static const onWarningContainer = Color(0xFF4A2800);
}
