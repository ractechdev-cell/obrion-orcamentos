import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/profile_repository_provider.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_text_field.dart';

/// Sub-tela de Ajustes — chave PIX, rodapé customizado e termos exibidos
/// no PDF do orçamento.
class PdfSettingsScreen extends ConsumerStatefulWidget {
  const PdfSettingsScreen({super.key});

  @override
  ConsumerState<PdfSettingsScreen> createState() => _PdfSettingsScreenState();
}

class _PdfSettingsScreenState extends ConsumerState<PdfSettingsScreen> {
  final _pixKeyController = TextEditingController();
  final _pdfFooterTextController = TextEditingController();
  final _pdfTermsAndConditionsController = TextEditingController();
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
      _pixKeyController.text = profile.pixKey ?? '';
      _pdfFooterTextController.text = profile.pdfFooterText ?? '';
      _pdfTermsAndConditionsController.text =
          profile.pdfTermsAndConditions ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pixKeyController.dispose();
    _pdfFooterTextController.dispose();
    _pdfTermsAndConditionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(profileRepositoryProvider);
    await repo.saveProfile(
      pixKey: _pixKeyController.text.trim(),
      pdfFooterText: _pdfFooterTextController.text.trim(),
      pdfTermsAndConditions: _pdfTermsAndConditionsController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackBar.show(context, 'Configurações do PDF salvas.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações do PDF')),
      body: _loading
          ? const AppLoading()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  'Chave PIX, rodapé customizado, termos e condições.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
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
