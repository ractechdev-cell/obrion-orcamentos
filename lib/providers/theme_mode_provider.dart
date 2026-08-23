import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tema atual do app — carregado do `PreferencesRepository` no boot
/// (ver `main.dart`) e atualizado a partir de `SettingsScreen`. Fica em
/// `system` até o carregamento terminar.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
