import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/profile_repository_provider.dart';
import '../../theme/app_spacing.dart';
import '../../utils/input_formatters.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loading.dart';
import '../../widgets/app_snackbar.dart';
import '../../widgets/app_text_field.dart';

/// Sub-tela de Ajustes — nome, telefone, e-mail, documento e endereço do
/// profissional, usados no cabeçalho do PDF de orçamento. Aberta a partir
/// do menu de Ajustes (padrão de navegação por sub-tela, não card
/// expandido inline — ver conversa 01/09/2026).
class ProfessionalProfileScreen extends ConsumerStatefulWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  ConsumerState<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState
    extends ConsumerState<ProfessionalProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _documentController = TextEditingController();
  final _addressController = TextEditingController();
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
      _nameController.text = profile.name ?? '';
      _phoneController.text = profile.phone ?? '';
      _emailController.text = profile.email ?? '';
      _documentController.text = profile.document ?? '';
      _addressController.text = profile.address ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _documentController.dispose();
    _addressController.dispose();
    super.dispose();
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
    );
    if (!mounted) return;
    setState(() => _saving = false);
    AppSnackBar.show(context, 'Perfil salvo.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil Profissional')),
      body: _loading
          ? const AppLoading()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(
                  'Estas informações aparecerão no cabeçalho do seu orçamento em PDF.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
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
