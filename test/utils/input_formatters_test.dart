import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/utils/input_formatters.dart';

/// Simula a digitação de um caractere por vez, como o teclado real faz —
/// cada chamada de `formatEditUpdate` recebe o texto completo já com o
/// novo caractere (comportamento do `TextField`), não só o caractere
/// isolado.
TextEditingValue _typeDigits(String digits) {
  var current = const TextEditingValue(text: '');
  for (final digit in digits.split('')) {
    // O TextField já mescla o texto anterior formatado com o novo
    // caractere digitado no fim — simula isso concatenando o texto
    // mascarado atual (sem os separadores importa pouco aqui, o
    // formatador extrai dígitos de qualquer forma) com o dígito novo.
    final rawNext = TextEditingValue(
      text: current.text + digit,
      selection: TextSelection.collapsed(offset: current.text.length + 1),
    );
    current = documentFormatter.formatEditUpdate(current, rawNext);
  }
  return current;
}

void main() {
  group('DocumentFormatter', () {
    test('formata CPF completo sem zeros extras', () {
      final result = _typeDigits('12345678901');
      expect(result.text, '123.456.789-01');
    });

    test('formata CNPJ completo sem zeros extras ao cruzar o 11º dígito', () {
      final result = _typeDigits('12345678000199');
      expect(result.text, '12.345.678/0001-99');
    });

    test('CPF parcial (menos de 11 dígitos) não aplica máscara de CNPJ', () {
      final result = _typeDigits('123456789');
      expect(result.text, '123.456.789');
    });

    test('volta para máscara de CPF ao apagar dígitos do CNPJ', () {
      final typed = _typeDigits('12345678000199');
      expect(typed.text, '12.345.678/0001-99');

      // Simula apagar até sobrar 11 dígitos.
      final digits = '12345678000199'.substring(0, 11);
      final backspaced = documentFormatter.formatEditUpdate(
        typed,
        TextEditingValue(
          text: digits,
          selection: TextSelection.collapsed(offset: digits.length),
        ),
      );
      expect(backspaced.text, '123.456.780-00');
    });

    test('não deixa passar de 14 dígitos (limite do CNPJ)', () {
      final result = _typeDigits('123456789001991234');
      final digitsOnly = result.text.replaceAll(RegExp(r'\D'), '');
      expect(digitsOnly.length, 14);
    });
  });
}
