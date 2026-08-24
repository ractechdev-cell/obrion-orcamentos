/// Validadores reutilizáveis de `Form`/`TextFormField` (ver
/// docs/APP_FACTORY_CORE.md, UI Components). Centraliza mensagens que
/// antes eram duplicadas como lambda inline em cada tela.
library;

/// Campo obrigatório: retorna erro se vazio/só espaços.
String? Function(String?) requiredValidator(String label) {
  return (value) => value == null || value.trim().isEmpty ? 'Informe $label' : null;
}

/// E-mail obrigatório com formato básico validado (não confere se o
/// domínio existe — só a forma `algo@algo.algo`).
String? emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'Informe o e-mail';
  final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  return valid ? null : 'E-mail inválido';
}

/// E-mail opcional — só valida formato se algo foi digitado (ao
/// contrário de [emailValidator], que exige o campo preenchido).
String? optionalEmailValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  return valid ? null : 'E-mail inválido';
}

/// Telefone é opcional em todo o app — só valida formato se algo foi
/// digitado. Aceita qualquer combinação de dígitos/espaços/parênteses/
/// hífen com pelo menos 8 dígitos (cobre fixo e celular, com ou sem DDD).
String? phoneValidator(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
  if (digitsOnly.length < 8) return 'Telefone inválido';
  return null;
}

/// Número obrigatório e maior que zero (medidas, quantidades). Recebe o
/// texto já digitado (com `,` ou `.`) e o nome do campo para a mensagem.
String? Function(String?) positiveNumberValidator(String label) {
  return (value) {
    if (value == null || value.trim().isEmpty) return 'Informe $label';
    final normalized = value.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null) return '$label inválido';
    if (parsed <= 0) return '$label deve ser maior que zero';
    return null;
  };
}
