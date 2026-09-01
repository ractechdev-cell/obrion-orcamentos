import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import '../providers/account_repository_provider.dart';
import '../providers/profile_repository_provider.dart';
import '../repositories/account_repository.dart';
import '../repositories/profile_repository.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_loading.dart';
import 'login_screen.dart';
import 'settings/identity_screen.dart';
import 'settings/pdf_settings_screen.dart';
import 'settings/professional_profile_screen.dart';
import 'settings/trades_screen.dart';

/// Tela de configurações (módulo Settings do Core — ver
/// docs/APP_FACTORY_CORE.md). Menu de navegação: cada seção abre em sua
/// própria tela (ver conversa 01/09/2026 — padrão adotado do app COTIX,
/// em vez de cards com formulário expandido inline).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  ProfessionalProfile? _profile;
  bool _loading = true;
  String? _versionLabel;
  LocalAccount _account = const LocalAccount(signedIn: false);

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadVersionInfo();
    _loadAccount();
  }

  Future<void> _loadAccount() async {
    final repo = ref.read(accountRepositoryProvider);
    final account = await repo.getAccount();
    if (mounted) setState(() => _account = account);
  }

  Future<void> _openLogin() async {
    final signedIn = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const LoginScreen()));
    if (signedIn ?? false) _loadAccount();
  }

  Future<void> _signOut() async {
    final repo = ref.read(accountRepositoryProvider);
    await repo.signOut();
    _loadAccount();
  }

  /// Versão do build + número do patch OTA (Shorebird) atual, se houver —
  /// pensado pra confirmar visualmente se um patch chegou de verdade
  /// (a versão do app não muda com patch, só o número de patch muda).
  Future<void> _loadVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    var label = 'Versão ${info.version} (build ${info.buildNumber})';

    try {
      final updater = ShorebirdUpdater();
      if (updater.isAvailable) {
        final patch = await updater.readCurrentPatch();
        label += patch == null ? ' · sem patch' : ' · patch ${patch.number}';
      }
    } catch (_) {
      // Sem engine do Shorebird disponível (ex.: build fora do release
      // do Shorebird) — mostra só a versão, sem quebrar a tela.
    }

    if (mounted) setState(() => _versionLabel = label);
  }

  Future<void> _loadProfile() async {
    final repo = ref.read(profileRepositoryProvider);
    final profile = await repo.getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
    }
  }

  /// Reconsulta o perfil ao voltar de uma sub-tela — cada uma salva só o
  /// que edita, então recarregar aqui é o jeito simples de refletir a
  /// mudança sem duplicar estado entre a tela principal e as sub-telas.
  Future<void> _openAndReload(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: _loading
          ? const AppLoading()
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: [
                _buildAccountTile(context),
                const SizedBox(height: AppSpacing.lg),
                _buildSectionHeader(context, 'PERFIL'),
                _buildListTile(
                  context,
                  title: 'Perfil Profissional',
                  subtitle: (_profile?.name?.isNotEmpty ?? false)
                      ? _profile!.name
                      : 'Nome, telefone, e-mail e endereço',
                  icon: Icons.badge_outlined,
                  onTap: () => _openAndReload(const ProfessionalProfileScreen()),
                ),
                _buildListTile(
                  context,
                  title: 'Meus Ofícios',
                  subtitle: (_profile?.trades.isNotEmpty ?? false)
                      ? '${_profile!.trades.length} selecionado(s)'
                      : 'Personalize os modelos de orçamento',
                  icon: Icons.handyman_outlined,
                  onTap: () => _openAndReload(const TradesScreen()),
                ),
                _buildListTile(
                  context,
                  title: 'Identidade',
                  subtitle: (_profile?.logoPath?.isNotEmpty ?? false)
                      ? 'Logo adicionada'
                      : 'Adicione sua logomarca (opcional)',
                  icon: Icons.image_outlined,
                  onTap: () => _openAndReload(const IdentityScreen()),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildSectionHeader(context, 'PDF'),
                _buildListTile(
                  context,
                  title: 'Configurações do PDF',
                  subtitle: 'Chave PIX, rodapé e termos',
                  icon: Icons.picture_as_pdf_outlined,
                  onTap: () => _openAndReload(const PdfSettingsScreen()),
                ),
                if (_versionLabel != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text(
                      _versionLabel!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
    );
  }

  Widget _buildAccountTile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final logoPath = _profile?.logoPath;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: colorScheme.primaryContainer,
        backgroundImage: (logoPath?.isNotEmpty ?? false)
            ? FileImage(File(logoPath!))
            : null,
        child: (logoPath?.isNotEmpty ?? false)
            ? null
            : Icon(
                _account.signedIn ? Icons.person : Icons.person_outline,
                color: colorScheme.onPrimaryContainer,
              ),
      ),
      title: Text(
        _account.signedIn ? (_account.email ?? '') : 'Visitante',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: Text(
        _account.signedIn
            ? 'Conta salva neste aparelho'
            : 'Dados salvos só neste aparelho',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: TextButton(
        onPressed: _account.signedIn ? _signOut : _openLogin,
        child: Text(_account.signedIn ? 'Sair' : 'Entrar'),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
