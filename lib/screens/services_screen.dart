import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_service.dart';
import '../database/database.dart';
import '../database/enums.dart';
import '../providers/profile_repository_provider.dart';
import '../providers/services_repository_provider.dart';
import '../theme/app_spacing.dart';
import '../utils/currency_format.dart';
import '../utils/service_filter.dart';
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
  String? _selectedCategory;
  bool _populating = false;


  Future<void> _bulkAdjustPrices(BuildContext context) async {
    final controller = TextEditingController();
    final percent = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Reajustar preços', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
                'Muda o preço de todos os serviços que já têm valor. Use número negativo pra reduzir.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Reajuste (%)',
              hint: 'Ex: 10 ou -5',
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Aplicar',
              onPressed: () {
                final value = double.tryParse(controller.text.replaceAll(',', '.'));
                Navigator.of(context).pop(value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );

    if (percent == null || percent == 0) return;
    final repo = ref.read(servicesRepositoryProvider);
    await repo.bulkAdjustPrices(percent);
    if (context.mounted) {
      AppSnackBar.show(context, 'Preços reajustados em ${percent > 0 ? '+' : ''}${percent.toStringAsFixed(1)}%.');
    }
  }

  Future<void> _populateDefaults(BuildContext context) async {
    setState(() => _populating = true);
    try {
      final repo = ref.read(servicesRepositoryProvider);
      final profile = await ref.read(profileRepositoryProvider).getProfile();
      await repo.populateDefaultServices(trades: profile.trades);
      if (context.mounted) {
        final message = profile.trades.isEmpty
            ? 'Lista padrão carregada com sucesso!'
            : 'Lista padrão do seu ofício carregada com sucesso!';
        AppSnackBar.show(context, message);
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
            onPressed: () => _bulkAdjustPrices(context),
            icon: const Icon(Icons.percent_outlined, size: 20),
            label: const Text('Reajustar'),
          ),
          TextButton.icon(
            onPressed: _populating ? null : () => _populateDefaults(context),
            icon: const Icon(Icons.playlist_add, size: 20),
            label: const Text('Sugestões'),
          ),
          const SizedBox(width: AppSpacing.xs),
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
            padding: const EdgeInsets.all(AppSpacing.md),
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
                final categories = distinctServiceCategories(allServices);
                final services = filterServices(allServices, query: _query, category: _selectedCategory);

                return Column(
                  children: [
                    if (categories.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            children: [
                              ChoiceChip(
                                label: const Text('Todas'),
                                selected: _selectedCategory == null,
                                onSelected: (_) => setState(() => _selectedCategory = null),
                              ),
                              for (final category in categories) ...[
                                const SizedBox(width: AppSpacing.xs),
                                ChoiceChip(
                                  label: Text(category),
                                  selected: _selectedCategory == category,
                                  onSelected: (_) => setState(() => _selectedCategory = category),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    Expanded(child: _buildList(context, services)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Service> services) {
    if (services.isEmpty) {
      if (_query.isNotEmpty || _selectedCategory != null) {
        return AppEmptyState(
          message: _query.isNotEmpty
              ? 'Nenhum serviço encontrado para "$_query".'
              : 'Nenhum serviço na categoria "$_selectedCategory".',
        );
      }
      return AppEmptyState(
        message: 'Você ainda não tem serviços na sua lista de preços.\n\n'
            'Carregue os sugeridos para o seu ofício ou adicione o seu, '
            'para montar orçamentos em poucos toques.',
        actionLabel: 'Carregar sugestões padrão',
        onAction: () => _populateDefaults(context),
        secondaryActionLabel: 'Adicionar serviço',
        onSecondaryAction: () => _showForm(context),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: services.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final s = services[index];
        final priceText =
            s.defaultPriceCents != null ? formatCurrencyBrl(s.defaultPriceCents!) : 'Preço não definido';
        final subtitle = [
          if (s.category != null && s.category!.trim().isNotEmpty) s.category!.trim(),
          'Unidade: ${serviceUnitLabel(s.unit)}',
          priceText,
        ].join(' • ');

        return AppCard(
          onTap: () => _showForm(context, service: s),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        );
      },
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
  late final TextEditingController _categoryController;
  late ServiceUnit _unit;
  int? _priceCents;
  bool _includesMaterial = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _noteController = TextEditingController(text: widget.service?.defaultNote ?? '');
    _categoryController = TextEditingController(text: widget.service?.category ?? '');
    _unit = widget.service?.unit ?? ServiceUnit.squareMeter;
    _priceCents = widget.service?.defaultPriceCents;
    _includesMaterial = widget.service?.includesMaterial ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final repo = ref.read(servicesRepositoryProvider);

    final category = _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim();

    if (widget.service == null) {
      await repo.create(
        name: _nameController.text.trim(),
        unit: _unit,
        defaultPriceCents: _priceCents,
        includesMaterial: _includesMaterial,
        defaultNote: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        category: category,
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
        category: Value(category),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
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
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _nameController,
                label: 'Nome do serviço',
                validator: requiredValidator('o nome'),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _categoryController,
                label: 'Categoria (opcional)',
                hint: 'Ex: Pintura, Elétrica...',
              ),
              const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.md),
              AppCurrencyInput(
                initialValueCents: _priceCents,
                label: 'Preço padrão (R\$)',
                onChangedCents: (cents) => setState(() => _priceCents = cents),
              ),
              const SizedBox(height: AppSpacing.sm),
              CheckboxListTile(
                title: const Text('Inclui material'),
                value: _includesMaterial,
                onChanged: (val) => setState(() => _includesMaterial = val ?? false),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                controller: _noteController,
                label: 'Observação padrão',
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  if (widget.service != null) ... [
                    IconButton(
                      onPressed: _delete,
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                      tooltip: 'Excluir serviço',
                    ),
                    const SizedBox(width: AppSpacing.sm),
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

