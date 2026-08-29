import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final phoneFormatter = MaskTextInputFormatter(
  mask: '(##) #####-####',
  filter: {'#': RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

/// Formatador inteligente que troca entre CPF e CNPJ automaticamente.
/// - Até 11 dígitos: CPF (999.999.999-99)
/// - A partir do 12º: CNPJ (99.999.999/9999-99)
///
/// Implementado sem estado interno (stateless) — cada chamada aplica a
/// máscara direto sobre os dígitos digitados, sem depender de instâncias
/// de `MaskTextInputFormatter` com estado próprio. Usar duas instâncias
/// separadas e alternar entre elas (abordagem anterior) causava zeros
/// fantasmas: cada formatador tem seu próprio `_resultTextArray` interno,
/// e o formatador que "entra em cena" ao cruzar o 11º dígito não conhece
/// os dígitos que o outro formatador já tinha processado — o resultado
/// era calculado a partir de um estado divergente do texto real.
class DocumentFormatter extends TextInputFormatter {
  static const _cpfPattern = [3, 3, 3, 2];
  static const _cpfSeparators = ['.', '.', '-', ''];
  static const _cnpjPattern = [2, 3, 3, 4, 2];
  static const _cnpjSeparators = ['.', '.', '/', '-', ''];

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    final isCnpj = digits.length > 11;
    final maxDigits = isCnpj ? 14 : 11;
    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }

    final pattern = isCnpj ? _cnpjPattern : _cpfPattern;
    final separators = isCnpj ? _cnpjSeparators : _cpfSeparators;

    final buffer = StringBuffer();
    var digitIndex = 0;
    for (var groupIndex = 0; groupIndex < pattern.length; groupIndex++) {
      final groupLength = pattern[groupIndex];
      if (digitIndex >= digits.length) break;
      final end = (digitIndex + groupLength).clamp(0, digits.length);
      buffer.write(digits.substring(digitIndex, end));
      digitIndex = end;
      if (digitIndex >= digits.length) break;
      buffer.write(separators[groupIndex]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

final documentFormatter = DocumentFormatter();
