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

  static const successDark = Color(0xFF81C995);
  static const onSuccessDark = Color(0xFF0B3B0E);
  static const successContainerDark = Color(0xFF1B5E20);
  static const onSuccessContainerDark = Color(0xFFC8E6C9);

  static const warningDark = Color(0xFFFFB74D);
  static const onWarningDark = Color(0xFF4A2800);
  static const warningContainerDark = Color(0xFFB35C00);
  static const onWarningContainerDark = Color(0xFFFFE0B2);
}
