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
class DocumentFormatter extends TextInputFormatter {
  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  final _cnpjFormatter = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    // Escolhe o formatador baseado na quantidade de dígitos
    final formatter = digits.length <= 11 ? _cpfFormatter : _cnpjFormatter;
    
    return formatter.formatEditUpdate(oldValue, newValue);
  }
}

final documentFormatter = DocumentFormatter();
