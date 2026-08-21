import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_text_field.dart';

/// Entrada numérica para medidas e quantidades (ver docs/APP_FACTORY_CORE.md,
/// UI Components). Ao contrário de [AppCurrencyInput], aqui o valor é
/// `double` — precisão de ponto flutuante é irrelevante para medidas
/// (m², m³, metro linear), diferente de dinheiro (ver CLAUDE.md).
class AppNumberInput extends StatelessWidget {
  const AppNumberInput({
    super.key,
    this.label,
    this.hint,
    this.suffixText,
    this.controller,
    this.errorText,
    this.enabled = true,
    this.allowDecimal = true,
    this.onChanged,
  });

  final String? label;
  final String? hint;
  final String? suffixText;
  final TextEditingController? controller;
  final String? errorText;
  final bool enabled;
  final bool allowDecimal;
  final ValueChanged<double?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      enabled: enabled,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        if (allowDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*$'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      suffixIcon: suffixText == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                widthFactor: 1,
                child: Text(suffixText!),
              ),
            ),
      onChanged: (value) {
        final normalized = value.replaceAll(',', '.');
        onChanged?.call(double.tryParse(normalized));
      },
    );
  }
}
