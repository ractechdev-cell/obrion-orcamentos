import 'package:flutter/material.dart';

import '../database/database.dart';

/// Chave usada em `app_settings` para persistir a preferência de tema.
class _Keys {
  static const themeMode = 'theme_mode';
}

/// Repositório mínimo de preferências do app (tema) — mesmo padrão de
/// chave/valor do `ProfileRepository`. Ver docs/APP_FACTORY_CORE.md,
/// módulo Settings.
class PreferencesRepository {
  PreferencesRepository(this._db);

  final AppDatabase _db;

  Future<ThemeMode> getThemeMode() async {
    final rows = await _db.select(_db.appSettings).get();
    final map = {for (final row in rows) row.key: row.value};
    final value = map[_Keys.themeMode];
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.appSettings, [
        AppSettingsCompanion.insert(key: _Keys.themeMode, value: value),
      ]);
    });
  }
}
