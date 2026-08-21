import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Item de ação de um [AppBottomSheet.showActions].
class AppBottomSheetAction {
  const AppBottomSheetAction({
    required this.label,
    required this.value,
    this.icon,
    this.isDestructive = false,
  });

  final String label;
  final Object value;
  final IconData? icon;
  final bool isDestructive;
}

/// Ações contextuais (ex.: opções de um item) — ver
/// docs/APP_FACTORY_CORE.md, UI Components. Nunca chamar `showModalBottomSheet`
/// cru numa tela — sempre via `AppBottomSheet.showActions`.
class AppBottomSheet {
  const AppBottomSheet._();

  static Future<T?> showActions<T>(
    BuildContext context, {
    required List<AppBottomSheetAction> actions,
    String? title,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
            for (final action in actions)
              ListTile(
                leading: action.icon == null
                    ? null
                    : Icon(
                        action.icon,
                        color: action.isDestructive ? colorScheme.error : null,
                      ),
                title: Text(
                  action.label,
                  style: action.isDestructive
                      ? TextStyle(color: colorScheme.error)
                      : null,
                ),
                onTap: () => Navigator.of(context).pop(action.value as T?),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}
