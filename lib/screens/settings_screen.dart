import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

import '../database/enums.dart';
import '../providers/account_repository_provider.dart';
import '../providers/profile_repository_provider.dart';
import '../repositories/account_repository.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_trade_selector.dart';
import 'login_screen.dart';

/// Tela de configurações (módulo Settings do Core — ver
/// docs/APP_FACTORY_CORE.md). Guarda o perfil do profissional (nome,
/// telefone, logo) usado no cabeçalho do PDF de orçamento.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _logoPath;
  Set<Trade> _selectedTrades = {};
  bool _loading = true;
  bool _saving = false;
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
        _nameController.text = profile.name ?? '';
        _phoneController.text = profile.phone ?? '';
        _logoPath = (profile.logoPath?.isNotEmpty ?? false)
            ? profile.logoPath
            : null;
        _selectedTrades = profile.trades;
        _loading = false;
      });
    }
  }

  Future<void> _pickLogo() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    final pickedPath = file?.path;
    if (pickedPath == null) return;

    final documentsDir = await getApplicationDocumentsDirectory();
    final extension = p.extension(pickedPath);
    final destination = p.join(documentsDir.path, 'profile_logo$extension');

    // Remove logo anterior se a extensão mudou (arquivo não seria sobrescrito).
    if (_logoPath != null && _logoPath != destination) {
      final previous = File(_logoPath!);
      if (await previous.exists()) await previous.delete();
    }

    await File(pickedPath).copy(destination);
    if (mounted) setState(() => _logoPath = destination);
  }

  Future<void> _removeLogo() async {
    if (_logoPath != null) {
      final file = File(_logoPath!);
      if (await file.exists()) await file.delete();
    }
    if (mounted) setState(() => _logoPath = null);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(profileRepositoryProvider);
    await repo.saveProfile(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      logoPath: _logoPath,
      trades: _selectedTrades,
    );
    if (mounted) {
      setState(() => _saving = false);
      AppSnackBar.show(context, 'Perfil salvo.');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: _loading
          ? const AppLoading()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _buildAccountCard(context),
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Seu perfil profissional',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Aparece no cabeçalho do PDF de orçamento enviado ao cliente.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _nameController,
                  label: 'Nome ou nome da empresa',
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _phoneController,
                  label: 'Telefone',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildLogoPicker(context),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Seus ofícios',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ajusta as sugestões da sua lista de preços. Pode marcar mais de um.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTradeSelector(
                  selected: _selectedTrades,
                  onChanged: (trades) =>
                      setState(() => _selectedTrades = trades),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Salvar',
                  loading: _saving,
                  onPressed: _saving ? null : _save,
                ),
                if (_versionLabel != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text(
                      _versionLabel!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            _account.signedIn ? Icons.person : Icons.person_outline,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _account.signedIn ? (_account.email ?? '') : 'Visitante',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                _account.signedIn
                    ? 'Conta salva neste aparelho'
                    : 'Dados salvos só neste aparelho',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: _account.signedIn ? _signOut : _openLogin,
          child: Text(_account.signedIn ? 'Sair' : 'Entrar'),
        ),
      ],
    );
  }

  Widget _buildLogoPicker(BuildContext context) {
    return Row(
      children: [
        _LogoPreview(logoPath: _logoPath),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Logo (opcional)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  TextButton(
                    onPressed: _pickLogo,
                    child: const Text('Escolher'),
                  ),
                  if (_logoPath != null)
                    TextButton(
                      onPressed: _removeLogo,
                      child: const Text('Remover'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LogoPreview extends StatelessWidget {
  const _LogoPreview({required this.logoPath});

  final String? logoPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoPath == null
          ? Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant)
          : Image.file(File(logoPath!), fit: BoxFit.cover),
    );
  }
}
