import '../database/database.dart';

/// Chaves usadas em `app_settings` para o perfil do profissional. Ver
/// docs/APP_FACTORY_CORE.md, módulo User — nesta fase (sem conta/nuvem),
/// o perfil vive só localmente em `app_settings`.
class _Keys {
  static const professionalName = 'professional_name';
  static const professionalPhone = 'professional_phone';
  static const professionalLogoPath = 'professional_logo_path';
}

/// Nome e telefone do profissional, usados no cabeçalho do PDF de
/// orçamento (ver CLAUDE.md, módulo PDF). `logoPath` é o caminho absoluto
/// do arquivo de logo salvo no diretório de documentos do app (opcional).
class ProfessionalProfile {
  const ProfessionalProfile({this.name, this.phone, this.logoPath});

  final String? name;
  final String? phone;
  final String? logoPath;
}

/// Repositório mínimo de perfil — persistência local em `app_settings`
/// (chave/valor), sem exigir tabela dedicada nesta fase.
class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  Future<ProfessionalProfile> getProfile() async {
    final rows = await _db.select(_db.appSettings).get();
    final map = {for (final row in rows) row.key: row.value};
    return ProfessionalProfile(
      name: map[_Keys.professionalName],
      phone: map[_Keys.professionalPhone],
      logoPath: map[_Keys.professionalLogoPath],
    );
  }

  Future<void> saveProfile({String? name, String? phone, String? logoPath}) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.appSettings, [
        AppSettingsCompanion.insert(key: _Keys.professionalName, value: name ?? ''),
        AppSettingsCompanion.insert(key: _Keys.professionalPhone, value: phone ?? ''),
        AppSettingsCompanion.insert(key: _Keys.professionalLogoPath, value: logoPath ?? ''),
      ]);
    });
  }
}
