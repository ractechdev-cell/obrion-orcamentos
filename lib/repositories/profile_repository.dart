import '../database/database.dart';
import '../database/enums.dart';

/// Chaves usadas em `app_settings` para o perfil do profissional. Ver
/// docs/APP_FACTORY_CORE.md, módulo User — nesta fase (sem conta/nuvem),
/// o perfil vive só localmente em `app_settings`.
class _Keys {
  static const professionalName = 'professional_name';
  static const professionalPhone = 'professional_phone';
  static const professionalEmail = 'professional_email';
  static const professionalDocument = 'professional_document';
  static const professionalAddress = 'professional_address';
  static const professionalLogoPath = 'professional_logo_path';
  static const trades = 'professional_trades';
  static const pixKey = 'professional_pix_key';
  static const pdfFooterText = 'pdf_footer_text';
  static const pdfTermsAndConditions = 'pdf_terms_and_conditions';
}

/// Nome e telefone do profissional, usados no cabeçalho do PDF de
/// orçamento (ver CLAUDE.md, módulo PDF). `logoPath` é o caminho absoluto
/// do arquivo de logo salvo no diretório de documentos do app (opcional).
/// `trades` alimenta o filtro de sugestões da lista de preços (ver
/// docs/POSICIONAMENTO_E_FEATURES_APP1.md, "camada de ofício") — vazio
/// significa "não informado", nunca filtra nada.
class ProfessionalProfile {
  const ProfessionalProfile({
    this.name,
    this.phone,
    this.email,
    this.document,
    this.address,
    this.logoPath,
    this.trades = const {},
    this.pixKey,
    this.pdfFooterText,
    this.pdfTermsAndConditions,
  });

  final String? name;
  final String? phone;
  final String? email;

  /// CPF ou CNPJ do profissional/empresa — aparece no cabeçalho do PDF.
  final String? document;

  /// Endereço comercial — aparece no cabeçalho do PDF.
  final String? address;
  final String? logoPath;
  final Set<Trade> trades;
  final String? pixKey;
  final String? pdfFooterText;
  final String? pdfTermsAndConditions;
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
      email: map[_Keys.professionalEmail],
      document: map[_Keys.professionalDocument],
      address: map[_Keys.professionalAddress],
      logoPath: map[_Keys.professionalLogoPath],
      trades: _decodeTrades(map[_Keys.trades]),
      pixKey: map[_Keys.pixKey],
      pdfFooterText: map[_Keys.pdfFooterText],
      pdfTermsAndConditions: map[_Keys.pdfTermsAndConditions],
    );
  }

  /// Salva o perfil de forma parcial — cada tela de Ajustes edita só o
  /// que é dela (ex.: `TradesScreen` só passa `trades`), então um
  /// parâmetro nulo aqui significa "não mexi nisso", preservando o valor
  /// já salvo. Passar string vazia é diferente de não passar: significa
  /// que o usuário limpou o campo de propósito (ex.: removeu a logo).
  Future<void> saveProfile({
    String? name,
    String? phone,
    String? email,
    String? document,
    String? address,
    String? logoPath,
    Set<Trade>? trades,
    String? pixKey,
    String? pdfFooterText,
    String? pdfTermsAndConditions,
  }) async {
    final current = await getProfile();
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.appSettings, [
        AppSettingsCompanion.insert(
          key: _Keys.professionalName,
          value: name ?? current.name ?? '',
        ),
        AppSettingsCompanion.insert(
          key: _Keys.professionalPhone,
          value: phone ?? current.phone ?? '',
        ),
        AppSettingsCompanion.insert(
          key: _Keys.professionalEmail,
          value: email ?? current.email ?? '',
        ),
        AppSettingsCompanion.insert(
          key: _Keys.professionalDocument,
          value: document ?? current.document ?? '',
        ),
        AppSettingsCompanion.insert(
          key: _Keys.professionalAddress,
          value: address ?? current.address ?? '',
        ),
        AppSettingsCompanion.insert(
          key: _Keys.professionalLogoPath,
          value: logoPath ?? current.logoPath ?? '',
        ),
        AppSettingsCompanion.insert(
          key: _Keys.pixKey,
          value: pixKey ?? current.pixKey ?? '',
        ),
        AppSettingsCompanion.insert(
          key: _Keys.pdfFooterText,
          value: pdfFooterText ?? current.pdfFooterText ?? '',
        ),
        AppSettingsCompanion.insert(
          key: _Keys.pdfTermsAndConditions,
          value: pdfTermsAndConditions ?? current.pdfTermsAndConditions ?? '',
        ),
        AppSettingsCompanion.insert(
          key: _Keys.trades,
          value: _encodeTrades(trades ?? current.trades),
        ),
      ]);
    });
  }

  static String _encodeTrades(Set<Trade> trades) => trades.map((t) => t.name).join(',');

  static Set<Trade> _decodeTrades(String? value) {
    if (value == null || value.isEmpty) return const {};
    return value
        .split(',')
        .map((name) => Trade.values.where((t) => t.name == name).firstOrNull)
        .whereType<Trade>()
        .toSet();
  }
}
