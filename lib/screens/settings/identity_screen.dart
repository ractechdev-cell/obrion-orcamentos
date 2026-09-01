import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../providers/profile_repository_provider.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_snackbar.dart';

/// Sub-tela de Ajustes — logomarca exibida nos orçamentos em PDF.
class IdentityScreen extends ConsumerStatefulWidget {
  const IdentityScreen({super.key});

  @override
  ConsumerState<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends ConsumerState<IdentityScreen> {
  String? _logoPath;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(profileRepositoryProvider);
    final profile = await repo.getProfile();
    if (!mounted) return;
    setState(() {
      _logoPath =
          (profile.logoPath?.isNotEmpty ?? false) ? profile.logoPath : null;
      _loading = false;
    });
  }

  Future<void> _pickLogo() async {
    final file = await FilePicker.pickFile(type: FileType.image);
    final pickedPath = file?.path;
    if (pickedPath == null) return;

    final documentsDir = await getApplicationDocumentsDirectory();
    final extension = p.extension(pickedPath);
    final destination = p.join(documentsDir.path, 'profile_logo$extension');

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
    await repo.saveProfile(logoPath: _logoPath ?? '');
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackBar.show(context, 'Identidade salva.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Identidade')),
      body: _loading
          ? const AppLoading()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  'Adicione sua logomarca aos orçamentos. (Opcional)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _logoPath == null
                          ? Icon(
                              Icons.add_photo_alternate_outlined,
                              color: colorScheme.onSurfaceVariant,
                            )
                          : Image.file(File(_logoPath!), fit: BoxFit.cover),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pickLogo,
                            icon: const Icon(Icons.upload_outlined, size: 20),
                            label: const Text('Escolher Logo'),
                          ),
                          if (_logoPath != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            TextButton.icon(
                              onPressed: _removeLogo,
                              icon: const Icon(Icons.delete_outline, size: 20),
                              label: const Text('Remover'),
                              style: TextButton.styleFrom(
                                foregroundColor: colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Salvar',
                  icon: Icons.save,
                  loading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
    );
  }
}
