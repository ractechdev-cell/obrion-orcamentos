import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../providers/preferences_repository_provider.dart';
import '../providers/profile_repository_provider.dart';
import '../providers/theme_mode_provider.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// Tela de configurações (módulo Settings do Core — ver
/// docs/APP_FACTORY_CORE.md). Guarda o perfil do profissional (nome,
/// telefone, logo) usado no cabeçalho do PDF de orçamento, e a
/// preferência de tema do app.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _logoPath;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final repo = ref.read(profileRepositoryProvider);
    final profile = await repo.getProfile();
    if (mounted) {
      setState(() {
        _nameController.text = profile.name ?? '';
        _phoneController.text = profile.phone ?? '';
        _logoPath = (profile.logoPath?.isNotEmpty ?? false) ? profile.logoPath : null;
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
    );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil salvo.')),
      );
    }
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    ref.read(themeModeProvider.notifier).set(mode);
    final repo = ref.read(preferencesRepositoryProvider);
    await repo.saveThemeMode(mode);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
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
                AppButton(
                  label: 'Salvar',
                  loading: _saving,
                  onPressed: _saving ? null : _save,
                ),
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Text('Aparência', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(value: ThemeMode.light, label: Text('Claro'), icon: Icon(Icons.light_mode)),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Escuro'), icon: Icon(Icons.dark_mode)),
                    ButtonSegment(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.brightness_auto)),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) => _setThemeMode(selection.first),
                ),
              ],
            ),
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
              Text('Logo (opcional)', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  TextButton(onPressed: _pickLogo, child: const Text('Escolher')),
                  if (_logoPath != null)
                    TextButton(onPressed: _removeLogo, child: const Text('Remover')),
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
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: logoPath == null
          ? Icon(Icons.image_outlined, color: colorScheme.onSurfaceVariant)
          : Image.file(File(logoPath!), fit: BoxFit.cover),
    );
  }
}
