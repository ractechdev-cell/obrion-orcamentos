import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/theme/app_theme.dart';

/// Guarda contra o campo de formulário sumir no fundo.
///
/// Regressão real (28/08/2026): o preenchimento do input e o
/// `scaffoldBackgroundColor` foram definidos com a **mesma** cor
/// (`surfaceContainerLow`), então nos formulários sobrava só o rótulo
/// flutuando — sem caixa, sem linha, nada indicando onde tocar. Passou
/// por `flutter analyze` e por toda a suíte, porque nada olhava para a
/// relação entre as duas cores.
///
/// O teste compara luminância em vez de exigir cores específicas: o que
/// importa é existir contraste, não qual tom foi escolhido.
void main() {
  final theme = AppTheme.light();

  double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }

  test('o preenchimento do campo se distingue do fundo da tela', () {
    final fill = theme.inputDecorationTheme.fillColor!;
    final background = theme.scaffoldBackgroundColor;

    expect(
      fill,
      isNot(background),
      reason: 'Campo e fundo com a mesma cor deixam o formulário invisível.',
    );
    expect(
      contrast(fill, background),
      greaterThan(1.03),
      reason: 'Contraste baixo demais entre campo e fundo da tela.',
    );
  });

  test('o preenchimento do campo se distingue do card e do bottom sheet', () {
    final fill = theme.inputDecorationTheme.fillColor!;
    // Card, diálogo e bottom sheet são todos brancos
    // (`surfaceContainerLowest`) — formulário também aparece dentro deles.
    final card = theme.colorScheme.surfaceContainerLowest;

    expect(contrast(fill, card), greaterThan(1.03));
  });

  test('o campo tem borda visível já antes de receber foco', () {
    final enabled = theme.inputDecorationTheme.enabledBorder!;
    expect(enabled.borderSide.style, BorderStyle.solid);
    expect(enabled.borderSide.color.a, greaterThan(0.0));
  });

  test('a borda não muda de espessura ao focar', () {
    // Espessura diferente entre os estados faz o campo "pular" quando
    // recebe foco, empurrando o resto do formulário.
    final enabled = theme.inputDecorationTheme.enabledBorder!;
    final focused = theme.inputDecorationTheme.focusedBorder!;
    expect(focused.borderSide.width, enabled.borderSide.width);
    expect(focused.borderSide.color, isNot(enabled.borderSide.color));
  });
}
