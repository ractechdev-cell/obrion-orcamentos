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

  /// Âmbar de segurança — a cor da marca, mais clara e saturada que
  /// [primary]. O design system trata as duas como papéis distintos, e
  /// misturá-las foi o que deixava o app mais "marrom" que os modelos:
  ///
  /// - `safetyAmber` (#C2680A) — marca, ação principal (CTA/FAB) e
  ///   valores em dinheiro. É o que o olho procura na tela.
  /// - `primary` (#8F4A00) — tom mais escuro, para ícones e texto sobre
  ///   fundo claro, onde #C2680A não teria contraste suficiente.
  static const safetyAmber = Color(0xFFC2680A);

  // ── Primary ──────────────────────────────────────────────
  static const primary = Color(0xFF8F4A00);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFB35E00);
  static const onPrimaryContainer = Color(0xFFFFFFFF);
  static const primaryFixed = Color(0xFFFFDCC4);
  static const primaryFixedDim = Color(0xFFFFB780);

  // ── Secondary ────────────────────────────────────────────
  static const secondary = Color(0xFF1B6D24);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFA0F399);
  static const onSecondaryContainer = Color(0xFF217128);

  // ── Tertiary ─────────────────────────────────────────────
  static const tertiary = Color(0xFF5A5C5E);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF737577);
  static const onTertiaryContainer = Color(0xFFFCFCFF);

  // ── Surface / Background ─────────────────────────────────
  static const surface = Color(0xFFFAF9F7);
  static const onSurface = Color(0xFF1A1C1B);
  static const surfaceVariant = Color(0xFFE3E2E0);
  static const onSurfaceVariant = Color(0xFF554337);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF4F3F1);
  static const surfaceContainer = Color(0xFFEFEEEC);
  static const surfaceContainerHigh = Color(0xFFE9E8E6);
  static const surfaceContainerHighest = Color(0xFFE3E2E0);
  static const surfaceDim = Color(0xFFDADAD8);
  static const surfaceBright = Color(0xFFFAF9F7);
  static const surfaceTint = Color(0xFF924C00);

  // ── Outline ──────────────────────────────────────────────
  static const outline = Color(0xFF887365);
  static const outlineVariant = Color(0xFFDBC2B1);

  /// Cinza neutro de contorno — **a borda padrão do design system**, usada
  /// em card, input, divisor e barra de navegação (118 ocorrências nos
  /// modelos, contra 1 de [outlineVariant]).
  ///
  /// Importa não confundir com [outlineVariant], que é um bege quente: o
  /// design constrói hierarquia por contorno em vez de sombra (ver
  /// "Elevation & Depth" no DESIGN.md — sombra some ao sol), então a cor
  /// da borda é estrutural aqui, não decorativa.
  static const surfaceOutline = Color(0xFFC4C7C5);

  // ── Error ────────────────────────────────────────────────
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // ── Inverse ──────────────────────────────────────────────
  static const inverseSurface = Color(0xFF2F3130);
  static const onInverseSurface = Color(0xFFF1F1EF);
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

  /// Azul informativo — nos modelos é o estado "Enviado" do orçamento:
  /// já saiu das mãos do profissional, mas ainda não teve resposta. Não
  /// é sucesso nem alerta, por isso não reaproveita nenhum dos dois.
  static const info = Color(0xFF1565C0);
  static const onInfo = Color(0xFFFFFFFF);
  static const infoContainer = Color(0xFFE3F2FD);
  static const onInfoContainer = Color(0xFF1565C0);

  /// `error-red` do design (#D32F2F) — tom de alerta usado em *badge* e
  /// texto sobre fundo claro. Distinto de [AppColors.error] (#BA1A1A),
  /// que é o vermelho do `ColorScheme` para estados de erro de campo.
  static const danger = Color(0xFFD32F2F);
  static const onDanger = Color(0xFFFFFFFF);
  static const dangerContainer = Color(0xFFFFDAD6);
  static const onDangerContainer = Color(0xFFD32F2F);
}
