import 'package:flutter/material.dart';

/// Cabeçalho de tela padronizado (ver docs/APP_FACTORY_CORE.md, UI
/// Components). Encapsula `AppBar` para manter consistência de estilo —
/// nunca montar `AppBar` com estilos ad-hoc numa tela.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
