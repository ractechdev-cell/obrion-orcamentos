import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'app_text_field.dart';

/// Formata dígitos digitados como centavos em R$ (ex.: "2500" → "R$ 25,00").
/// Formatação para R$ é responsabilidade só desta borda de apresentação —
/// o valor de negócio continua `int` em centavos (ver CLAUDE.md, "Dinheiro
/// é `int` em centavos — nunca `double`").
class _CentsCurrencyFormatter extends TextInputFormatter {
  _CentsCurrencyFormatter(this._currency);

  final NumberFormat _currency;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final cents = int.parse(digitsOnly);
    final formatted = _currency.format(cents / 100);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Entrada de valores monetários (ver docs/APP_FACTORY_CORE.md, UI
/// Components). Expõe o valor sempre como `int` centavos via
/// [onChangedCents] — nunca como `double`.
class AppCurrencyInput extends StatefulWidget {
  const AppCurrencyInput({
    super.key,
    this.label,
    this.initialValueCents,
    this.onChangedCents,
    this.errorText,
    this.enabled = true,
    this.controller,
  });

  final String? label;
  final int? initialValueCents;
  final ValueChanged<int?>? onChangedCents;
  final String? errorText;
  final bool enabled;
  final TextEditingController? controller;

  @override
  State<AppCurrencyInput> createState() => _AppCurrencyInputState();
}

class _AppCurrencyInputState extends State<AppCurrencyInput> {
  late final TextEditingController _controller;
  late final NumberFormat _currency;

  @override
  void initState() {
    super.initState();
    _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    _controller = widget.controller ?? TextEditingController();
    if (widget.initialValueCents != null) {
      _controller.text = _currency.format(widget.initialValueCents! / 100);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleChanged(String text) {
    final digitsOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
    widget.onChangedCents?.call(digitsOnly.isEmpty ? null : int.parse(digitsOnly));
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      label: widget.label,
      hint: 'R\$ 0,00',
      errorText: widget.errorText,
      enabled: widget.enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        _CentsCurrencyFormatter(_currency),
      ],
      onChanged: _handleChanged,
    );
  }
}
