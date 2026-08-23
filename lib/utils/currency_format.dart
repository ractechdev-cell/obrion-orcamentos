/// Formata centavos como `R$ 1.234,56` (ponto na casa de milhares, vírgula
/// nos centavos) — único lugar dessa regra, usada em toda tela/PDF que
/// mostra dinheiro (ver CLAUDE.md, "Dinheiro é `int` em centavos"). Nunca
/// usar `toStringAsFixed(2).replaceAll('.', ',')` sozinho numa tela — isso
/// troca o separador decimal mas não insere separador de milhar.
String formatCurrencyBrl(int cents) {
  final reais = cents ~/ 100;
  final centavos = (cents % 100).abs().toString().padLeft(2, '0');
  final reaisFormatted = reais.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );
  return 'R\$ $reaisFormatted,$centavos';
}
