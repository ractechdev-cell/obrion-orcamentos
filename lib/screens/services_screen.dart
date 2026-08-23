import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_service.dart';
import '../database/database.dart';
import '../database/enums.dart';
import '../providers/services_repository_provider.dart';
import '../utils/validators.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_currency_input.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_empty_state.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_field.dart';
import 'service_unit_label.dart';

/// Tela de Lista de Preços (Serviços) — funcionalidade central do MVP.
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  String _query = '';
  bool _populating = false;


  Future<void> _populateDefaults(BuildContext context) async {
    setState(() => _populating = true);
    try {
      final repo = ref.read(servicesRepositoryProvider);
      await repo.populateDefaultServices();
      if (context.mounted) {
        AppSnackBar.show(context, 'Lista padrão carregada com sucesso!');
      }
    } finally {
      if (mounted) setState(() => _populating = false);
    }
  }

  void _showForm(BuildContext context, {Service? service}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _ServiceFormSheet(service: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(servicesRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Preços'),
        actions: [
          TextButton.icon(
            onPressed: _populating ? null : () => _populateDefaults(context),
            icon: const Icon(Icons.playlist_add, size: 20),
            label: const Text('Sugestões'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        tooltip: 'Novo serviço',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              label: 'Buscar serviço',
              hint: 'Ex: Reboco, pintura...',
              onChanged: (val) => setState(() => _query = val),
              prefixIcon: const Icon(Icons.search),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Service>>(
              stream: repo.watchAll(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const AppError(message: 'Erro ao carregar lista de preços.');
                }
                if (!snapshot.hasData) {
                  return const AppLoading();
                }
                // Filtro client-side — mantém reatividade
                final allServices = snapshot.data!;
                final services = _query.isEmpty
                    ? allServices
                    : allServices.where((s) => s.name.toLowerCase().contains(_query.toLowerCase())).toList();

                if (services.isEmpty) {
                  return AppEmptyState(
                    message: 'Nenhum serviço cadastrado.',
                    actionLabel: 'Carregar sugestões padrão',
                    onAction: () => _populateDefaults(context),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: services.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final s = services[index];
                    final priceText = s.defaultPriceCents != null
                        ? 'R\$ ${(s.defaultPriceCents! / 100).toStringAsFixed(2).replaceAll('.', ',')}'
                        : 'Preço não definido';

                    return AppCard(
                      onTap: () => _showForm(context, service: s),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(
                                  'Unidade: ${serviceUnitLabel(s.unit)} • $priceText',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceFormSheet extends ConsumerStatefulWidget {
  const _ServiceFormSheet({this.service});

  final Service? service;

  @override
  ConsumerState<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends ConsumerState<_ServiceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;
  late ServiceUnit _unit;
  int? _priceCents;
  bool _includesMaterial = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _noteController = TextEditingController(text: widget.service?.defaultNote ?? '');
    _unit = widget.service?.unit ?? ServiceUnit.squareMeter;
    _priceCents = widget.service?.defaultPriceCents;
    _includesMaterial = widget.service?.includesMaterial ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repo = ref.read(servicesRepositoryProvider);

    if (widget.service == null) {
      await repo.create(
        name: _nameController.text.trim(),
        unit: _unit,
        defaultPriceCents: _priceCents,
        includesMaterial: _includesMaterial,
        defaultNote: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );
      AnalyticsService.trackEvent('price_list_item_created');
    } else {
      await repo.update(
        id: widget.service!.id,
        name: Value(_nameController.text.trim()),
        unit: Value(_unit),
        defaultPriceCents: Value(_priceCents),
        includesMaterial: Value(_includesMaterial),
        defaultNote: Value(_noteController.text.trim().isEmpty ? null : _noteController.text.trim()),
      );
    }

    if (mounted) {
      AppSnackBar.show(context, 'Serviço salvo.');
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    if (widget.service == null) return;
    final confirmed = await AppDialog.confirm(
      context,
      isDestructive: true,
      title: 'Excluir serviço?',
      message: 'Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
    );
    if (confirmed == true) {
      final repo = ref.read(servicesRepositoryProvider);
      await repo.softDelete(widget.service!.id);
      if (mounted) {
        AppSnackBar.show(context, 'Serviço excluído.', variant: AppSnackBarVariant.destructive);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.service == null ? 'Novo Serviço' : 'Editar Serviço',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                label: 'Nome do serviço',
                validator: requiredValidator('o nome'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ServiceUnit>(
                initialValue: _unit,
                decoration: const InputDecoration(labelText: 'Unidade de medida'),
                items: ServiceUnit.values.map((u) {
                  return DropdownMenuItem(
                    value: u,
                    child: Text(serviceUnitLabel(u)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _unit = val);
                },
              ),
              const SizedBox(height: 16),
              AppCurrencyInput(
                initialValueCents: _priceCents,
                label: 'Preço padrão (R\$)',
                onChangedCents: (cents) => setState(() => _priceCents = cents),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Inclui material'),
                value: _includesMaterial,
                onChanged: (val) => setState(() => _includesMaterial = val ?? false),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              AppTextField(
                controller: _noteController,
                label: 'Observação padrão',
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.service != null) ... [
                    IconButton(
                      onPressed: _delete,
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                      tooltip: 'Excluir serviço',
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: AppButton(
                      label: 'Salvar',
                      loading: _saving,
                      onPressed: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

