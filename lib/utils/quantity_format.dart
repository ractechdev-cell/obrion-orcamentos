/// Formata quantidade para exibição — "6" em vez de "6.00", "12,5" em vez
/// de "12,50", "46,256" preservado. Aparar o `.0000` sem arredondar: o PDF
/// e as telas mostram a MESMA precisão que o total usa (quantidade integral
/// × preço), então a conta que o cliente confere bate — arredondar em 2
/// casas aqui criaria divergência visível na multiplicação da linha
/// (quantidade é medida, `double`, ver CLAUDE.md; usa vírgula decimal
/// como o resto da UI).
String formatQuantity(double value) {
  var fixed = value.toStringAsFixed(4);
  if (fixed.contains('.')) {
    fixed = fixed.replaceFirst(RegExp(r'0+$'), '');
    fixed = fixed.replaceFirst(RegExp(r'\.$'), '');
  }
  return fixed.replaceAll('.', ',');
}