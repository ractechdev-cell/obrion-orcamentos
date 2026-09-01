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
import '../utils/input_formatters.dart';
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
  final _emailController = TextEditingController();
  final _documentController = TextEditingController();
  final _addressController = TextEditingController();
  final _pixKeyController = TextEditingController();
  final _pdfFooterTextController = TextEditingController();
  final _pdfTermsAndConditionsController = TextEditingController();
  String? _logoPath;
  Set<Trade> _selectedTrades = {};
  bool _loading = true;
  bool _saving = false;
  String? _versionLabel;
  LocalAccount _account = const LocalAccount(signedIn: false);
  bool _pdfConfigExpanded = false;

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
        _emailController.text = profile.email ?? '';
        _documentController.text = profile.document ?? '';
        _addressController.text = profile.address ?? '';
        _pixKeyController.text = profile.pixKey ?? '';
        _pdfFooterTextController.text = profile.pdfFooterText ?? '';
        _pdfTermsAndConditionsController.text = profile.pdfTermsAndConditions ?? '';
        _logoPath = (profile.logoPath?.isNotEmpty ?? false)
            ? profile.logoPath
            : null;
        _selectedTrades = profile.trades;
        _pdfConfigExpanded = [
          _pixKeyController,
          _pdfFooterTextController,
          _pdfTermsAndConditionsController,
        ].any((c) => c.text.isNotEmpty);
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
      email: _emailController.text.trim(),
      document: _documentController.text.trim(),
      address: _addressController.text.trim(),
      logoPath: _logoPath,
      trades: _selectedTrades,
      pixKey: _pixKeyController.text.trim(),
      pdfFooterText: _pdfFooterTextController.text.trim(),
      pdfTermsAndConditions: _pdfTermsAndConditionsController.text.trim(),
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
    _emailController.dispose();
    _documentController.dispose();
    _addressController.dispose();
    _pixKeyController.dispose();
    _pdfFooterTextController.dispose();
    _pdfTermsAndConditionsController.dispose();
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
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.badge_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Perfil Profissional',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Estas informações aparecerão no cabeçalho do seu orçamento em PDF.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _nameController,
                        label: 'Seu nome ou da empresa',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _phoneController,
                        label: 'Telefone',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [phoneFormatter],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _documentController,
                        label: 'CPF ou CNPJ (opcional)',
                        hint: 'Ex: 00.000.000/0001-00',
                        keyboardType: TextInputType.number,
                        inputFormatters: [documentFormatter],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _emailController,
                        label: 'E-mail (opcional)',
                        hint: 'Ex: joao@pinturas.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _addressController,
                        label: 'Endereço comercial (opcional)',
                        hint: 'Ex: Rua das Flores, 123 — São Paulo/SP',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.handyman_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Meus Ofícios',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Selecione suas áreas de atuação para personalizar os modelos de orçamento.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTradeSelector(
                        selected: _selectedTrades,
                        onChanged: (trades) =>
                            setState(() => _selectedTrades = trades),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.image_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Identidade',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Adicione sua logomarca aos orçamentos. (Opcional)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildLogoPicker(context),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _pdfConfigExpanded = !_pdfConfigExpanded),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Icon(
                                Icons.picture_as_pdf_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'Configurações do PDF',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              AnimatedRotation(
                                turns: _pdfConfigExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.expand_more,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_pdfConfigExpanded)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chave PIX, rodapé customizado, termos e condições',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppTextField(
                                controller: _pixKeyController,
                                label: 'Chave PIX (opcional)',
                                hint: 'Aparece no final do PDF',
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppTextField(
                                controller: _pdfFooterTextController,
                                label: 'Texto do rodapé (opcional)',
                                hint: 'Ex: Obrigado pela confiança!',
                                maxLines: 2,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppTextField(
                                controller: _pdfTermsAndConditionsController,
                                label: 'Termos e condições (opcional)',
                                hint: 'Ex: Pagamento em 3x sem juros',
                                maxLines: 4,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Salvar Configurações',
                  icon: Icons.save,
                  loading: _saving,
                  onPressed: _saving ? null : _save,
                ),
                if (_versionLabel != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Text(
                      _versionLabel!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
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
          radius: 24,
          backgroundColor: colorScheme.primaryContainer,
          backgroundImage: _logoPath != null ? FileImage(File(_logoPath!)) : null,
          child: _logoPath == null
              ? Icon(
                  _account.signedIn ? Icons.person : Icons.person_outline,
                  color: colorScheme.onPrimaryContainer,
                )
              : null,
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
