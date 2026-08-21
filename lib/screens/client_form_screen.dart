import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/clients_repository_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// Formulário de cliente — criação/edição simples, ainda sem routing de
/// detalhe/edição separado para acelerar a Fase 1.
class ClientFormScreen extends ConsumerStatefulWidget {
  const ClientFormScreen({super.key, this.clientId});

  final String? clientId;

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repository = ref.read(clientsRepositoryProvider);
    await repository.create(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo cliente')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Nome',
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _phoneController,
              label: 'Telefone',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _addressController,
              label: 'Endereço da obra',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _notesController,
              label: 'Observações',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Salvar cliente',
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
