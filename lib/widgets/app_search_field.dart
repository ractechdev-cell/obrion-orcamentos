import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Campo de busca das listas (Clientes, Orçamentos, Lista de Preços).
///
/// Difere do [AppTextField] comum de propósito: nos modelos a busca é uma
/// caixa cinza de cantos arredondados com lupa à esquerda, **sem rótulo**
/// e sem a barra de foco dos campos de formulário — ela é um controle de
/// navegação, não um campo a preencher.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
    this.initialValue,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String? initialValue;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    // Só descarta o controlador que este widget criou — descartar um
    // controlador recebido de fora quebraria quem o passou.
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _controller,
      onChanged: (value) {
        // Redesenha só para mostrar/esconder o "limpar"; o valor em si
        // é gerido pela tela dona da busca.
        setState(() {});
        widget.onChanged(value);
      },
      textInputAction: TextInputAction.search,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: scheme.surfaceContainer,
        prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Limpar busca',
                color: scheme.onSurfaceVariant,
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                  widget.onChanged('');
                },
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        // Sem a barra de foco herdada do tema de formulário.
        border: _border(Colors.transparent),
        enabledBorder: _border(Colors.transparent),
        focusedBorder: _border(scheme.primary),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: BorderSide(
          color: color,
          width: color == Colors.transparent ? 0 : 2,
        ),
      );
}
