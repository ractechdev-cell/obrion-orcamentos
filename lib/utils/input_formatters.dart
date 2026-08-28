import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final phoneFormatter = MaskTextInputFormatter(
  mask: '(##) #####-####',
  filter: {'#': RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

final cpfFormatter = MaskTextInputFormatter(
  mask: '###.###.###-##',
  filter: {'#': RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

final cnpjFormatter = MaskTextInputFormatter(
  mask: '##.###.###/####-##',
  filter: {'#': RegExp(r'[0-9]')},
  type: MaskAutoCompletionType.lazy,
);

MaskTextInputFormatter documentFormatter(String text) {
  final digits = text.replaceAll(RegExp(r'\D'), '');
  if (digits.length <= 11) {
    return cpfFormatter;
  } else {
    return cnpjFormatter;
  }
}
