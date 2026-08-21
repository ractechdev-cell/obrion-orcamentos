import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_text_field.dart';

/// Seleção de data padronizada (ver docs/APP_FACTORY_CORE.md, UI
/// Components). Campo somente leitura que abre o `showDatePicker` nativo —
/// nunca abrir o seletor de data direto de uma tela sem passar por aqui.
class AppDatePicker extends StatelessWidget {
  const AppDatePicker({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
  });

  final String? label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(now.year - 5),
      lastDate: lastDate ?? DateTime(now.year + 5),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatted = value == null
        ? null
        : DateFormat('dd/MM/yyyy', 'pt_BR').format(value!);

    return GestureDetector(
      onTap: enabled ? () => _pickDate(context) : null,
      child: AbsorbPointer(
        child: AppTextField(
          label: label,
          hint: 'dd/mm/aaaa',
          enabled: enabled,
          controller: TextEditingController(text: formatted),
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
      ),
    );
  }
}
