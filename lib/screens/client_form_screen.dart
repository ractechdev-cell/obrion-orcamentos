import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/clients_repository_provider.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_field.dart';
import 'budgets_screen.dart';

/// Formulário de cliente — cria um novo ou edita um existente, conforme
/// [clientId] seja nulo ou não.
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
  bool _loading = true;

  bool get _isEditing => widget.clientId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadClient();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadClient() async {
    final repository = ref.read(clientsRepositoryProvider);
    final client = await repository.getById(widget.clientId!);
    if (!mounted) return;
    if (client != null) {
      _nameController.text = client.name;
      _phoneController.text = client.phone ?? '';
      _addressController.text = client.address ?? '';
      _notesController.text = client.notes ?? '';
    }
    setState(() => _loading = false);
  }

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
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    final address = _addressController.text.trim().isEmpty ? null : _addressController.text.trim();
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    if (_isEditing) {
      await repository.update(
        id: widget.clientId!,
        name: Value(name),
        phone: Value(phone),
        address: Value(address),
        notes: Value(notes),
      );
      if (mounted) {
        AppSnackBar.show(context, 'Cliente atualizado.');
        Navigator.of(context).pop();
      }
    } else {
      final client = await repository.create(name: name, phone: phone, address: address, notes: notes);
      // Continua direto pro orçamento — criar o cliente sozinho não
      // completa a promessa da Home ("Comece um orçamento novo"); sem
      // isso a pessoa fica sem saber que "Orçamentos" existe escondido
      // no menu do cliente (ver CLAUDE.md, princípio 5, fricção mínima).
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => BudgetsScreen(clientId: client.id)),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Editar cliente' : 'Novo cliente')),
      body: _loading
          ? const AppLoading()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Nome',
                    validator: requiredValidator('o nome'),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _phoneController,
                    label: 'Telefone',
                    keyboardType: TextInputType.phone,
                    validator: phoneValidator,
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
                    label: _isEditing ? 'Salvar alterações' : 'Salvar cliente',
                    loading: _saving,
                    onPressed: _saving ? null : _save,
                  ),
                ],
              ),
            ),
    );
  }
}
