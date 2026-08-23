import '../database/database.dart';

/// Chaves usadas em `app_settings` para a conta local (ver CLAUDE.md,
/// decisão 5: tela de login só de interface nesta fase — sem Supabase,
/// sem conta real. `email` aqui é só o que a pessoa digitou, não é
/// validado contra nenhum servidor.
class _Keys {
  static const email = 'account_email';
  static const signedIn = 'account_signed_in';
}

/// Estado local da "conta" — sem autenticação de verdade (ver
/// docs/APP_FACTORY_CORE.md, módulo Authentication, e a decisão 5 em
/// CLAUDE.md). Existe só para a interface não ficar vazia e preparar o
/// terreno visual para a Fase 2, quando `email` vira uma conta Supabase
/// de verdade vinculada ao mesmo dado local já existente.
class LocalAccount {
  const LocalAccount({required this.signedIn, this.email});

  final bool signedIn;
  final String? email;
}

/// Repositório mínimo da conta local — mesmo padrão de chave/valor do
/// `ProfileRepository`/`PreferencesRepository`.
class AccountRepository {
  AccountRepository(this._db);

  final AppDatabase _db;

  Future<LocalAccount> getAccount() async {
    final rows = await _db.select(_db.appSettings).get();
    final map = {for (final row in rows) row.key: row.value};
    return LocalAccount(
      signedIn: map[_Keys.signedIn] == '1',
      email: map[_Keys.email],
    );
  }

  Future<void> signIn(String email) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.appSettings, [
        AppSettingsCompanion.insert(key: _Keys.email, value: email),
        AppSettingsCompanion.insert(key: _Keys.signedIn, value: '1'),
      ]);
    });
  }

  Future<void> signOut() async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.appSettings, [
        AppSettingsCompanion.insert(key: _Keys.signedIn, value: ''),
      ]);
    });
  }
}
