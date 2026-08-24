import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/clients_repository_provider.dart';
import '../theme/app_spacing.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_field.dart';
import 'client_detail_screen.dart';

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
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _documentController = TextEditingController();
  final _streetController = TextEditingController();
  final _streetNumberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  bool _saving = false;
  bool _loading = true;
  bool _detailsExpanded = false;

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
      _emailController.text = client.email ?? '';
      _addressController.text = client.address ?? '';
      _notesController.text = client.notes ?? '';
      _documentController.text = client.document ?? '';
      _streetController.text = client.street ?? '';
      _streetNumberController.text = client.streetNumber ?? '';
      _neighborhoodController.text = client.neighborhood ?? '';
    }
    setState(() {
      _loading = false;
      // Já vem aberto se estiver editando um cliente que já tem algum
      // desses dados — senão a pessoa acha que perdeu o que preencheu.
      _detailsExpanded = [
        _addressController,
        _notesController,
        _documentController,
        _streetController,
        _streetNumberController,
        _neighborhoodController,
      ].any((c) => c.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _documentController.dispose();
    _streetController.dispose();
    _streetNumberController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repository = ref.read(clientsRepositoryProvider);
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim();
    final email = _emailController.text.trim().isEmpty ? null : _emailController.text.trim();
    final address = _addressController.text.trim().isEmpty ? null : _addressController.text.trim();
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();
    final document = _documentController.text.trim().isEmpty ? null : _documentController.text.trim();
    final street = _streetController.text.trim().isEmpty ? null : _streetController.text.trim();
    final streetNumber =
        _streetNumberController.text.trim().isEmpty ? null : _streetNumberController.text.trim();
    final neighborhood =
        _neighborhoodController.text.trim().isEmpty ? null : _neighborhoodController.text.trim();

    if (_isEditing) {
      await repository.update(
        id: widget.clientId!,
        name: Value(name),
        phone: Value(phone),
        email: Value(email),
        address: Value(address),
        notes: Value(notes),
        document: Value(document),
        street: Value(street),
        streetNumber: Value(streetNumber),
        neighborhood: Value(neighborhood),
      );
      if (mounted) {
        AppSnackBar.show(context, 'Cliente atualizado.');
        Navigator.of(context).pop();
      }
    } else {
      final client = await repository.create(
        name: name,
        phone: phone,
        email: email,
        address: address,
        notes: notes,
        document: document,
        street: street,
        streetNumber: streetNumber,
        neighborhood: neighborhood,
      );
      // Continua direto pro histórico do cliente — criar o cliente sozinho
      // não completa a promessa da Home ("Comece um orçamento novo"); sem
      // isso a pessoa fica sem saber que dá pra criar orçamento por ali
      // (ver CLAUDE.md, princípio 5, fricção mínima).
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ClientDetailScreen(client: client)),
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
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Nome',
                    validator: requiredValidator('o nome'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _phoneController,
                    label: 'Telefone',
                    keyboardType: TextInputType.phone,
                    validator: phoneValidator,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Com telefone, dá pra chamar o cliente no WhatsApp direto da ficha.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    controller: _emailController,
                    label: 'E-mail (opcional)',
                    keyboardType: TextInputType.emailAddress,
                    validator: optionalEmailValidator,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Cabeçalho colapsável controlado à mão (em vez de
                  // `ExpansionTile`) — pra garantir que a seta de
                  // expandir/recolher sempre apareça, sem depender do
                  // ícone padrão do widget.
                  InkWell(
                    onTap: () => setState(() => _detailsExpanded = !_detailsExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Adicionar endereço e mais detalhes'),
                                Text(
                                  'Opcional',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: _detailsExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.keyboard_arrow_down),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_detailsExpanded) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _documentController,
                      label: 'CPF/CNPJ (opcional)',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: AppTextField(
                            controller: _streetController,
                            label: 'Rua',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          flex: 1,
                          child: AppTextField(
                            controller: _streetNumberController,
                            label: 'Número',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _neighborhoodController,
                      label: 'Bairro',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _addressController,
                      label: 'Complemento / referência da obra',
                      hint: 'Ponto de referência, apartamento, etc.',
                      maxLines: 2,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _notesController,
                      label: 'Observações',
                      maxLines: 3,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
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
