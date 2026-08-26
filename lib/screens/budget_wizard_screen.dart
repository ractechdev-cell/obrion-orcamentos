import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_service.dart';
import '../database/database.dart';
import '../database/enums.dart';
import '../measurement/measurement_math.dart';
import '../pdf/budget_share_service.dart';
import '../providers/budgets_repository_provider.dart';
import '../providers/clients_repository_provider.dart';
import '../providers/measurements_repository_provider.dart';
import '../providers/profile_repository_provider.dart';
import '../providers/services_repository_provider.dart';
import '../repositories/budgets_repository.dart';
import '../repositories/clients_repository.dart';
import '../repositories/measurements_repository.dart';
import '../review/review_service.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_currency_input.dart';
import '../widgets/app_date_picker.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_number_input.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_field.dart';
import 'budget_form_screen.dart';
import 'service_unit_label.dart';

/// Wizard de criação de orçamento — substitui o formulário monolítico de
/// 1200+ linhas por um fluxo guiado de 4 etapas conforme a seção 6 do
/// `docs/ROADMAP_UX_UI_E_FEATURES_APP1.md`.
///
/// **Quando usar:** criação de orçamento novo (budgetId == null).
/// **Edição continua** no `BudgetFormScreen` existente (budgetId != null).
///
/// Etapas:
/// 1. **Serviços** — adicionar itens do catálogo, avulso, usar medição
/// 2. **Condições** — descrição da obra, validade, observações, desconto
/// 3. **Revisão** — resumo com cliente, itens, totais
/// 4. **Envio** — compartilhar PDF/imagem/WhatsApp, marcar como enviado
class BudgetWizardScreen extends ConsumerStatefulWidget {
  const BudgetWizardScreen({super.key, required this.clientId});

  final String clientId;

  @override
  ConsumerState<BudgetWizardScreen> createState() => _BudgetWizardScreenState();
}

class _BudgetWizardScreenState extends ConsumerState<BudgetWizardScreen> {
  final _pageController = PageController();
  String? _budgetId;
  int _currentStep = 0;

  static const _stepLabels = ['Serviços', 'Condições', 'Revisão', 'Envio'];

  @override
  void initState() {
    super.initState();
    _createDraft();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _createDraft() async {
    final repo = ref.read(budgetsRepositoryProvider);
    final budget = await repo.create(clientId: widget.clientId);
    AnalyticsService.trackEvent('create_budget');
    AnalyticsService.trackEvent('budget_created');
    if (mounted) setState(() => _budgetId = budget.id);
  }

  void _nextStep() {
    if (_currentStep < _stepLabels.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int step) {
    if (step >= 0 && step < _stepLabels.length) {
      _pageController.jumpToPage(step);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_budgetId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo orçamento'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancelar',
          onPressed: () async {
            final confirmed = await AppDialog.confirm(
              context,
              title: 'Cancelar orçamento?',
              message: 'O rascunho será descartado.',
              isDestructive: true,
            );
            if (confirmed == true && context.mounted) {
              final repo = ref.read(budgetsRepositoryProvider);
              await repo.softDelete(_budgetId!);
              if (context.mounted) Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          _WizardStepIndicator(
            currentStep: _currentStep,
            labels: _stepLabels,
            onStepTap: _goToStep,
          ),
          const Divider(height: 1),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _ServicesStep(
                  budgetId: _budgetId!,
                  onNext: _nextStep,
                ),
                _ConditionsStep(
                  budgetId: _budgetId!,
                  onNext: _nextStep,
                  onBack: _previousStep,
                ),
                _ReviewStep(
                  budgetId: _budgetId!,
                  clientId: widget.clientId,
                  onNext: _nextStep,
                  onBack: _previousStep,
                ),
                _SendStep(
                  budgetId: _budgetId!,
                  clientId: widget.clientId,
                  onBack: _previousStep,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Indicador de etapas
// ---------------------------------------------------------------------------

class _WizardStepIndicator extends StatelessWidget {
  const _WizardStepIndicator({
    required this.currentStep,
    required this.labels,
    required this.onStepTap,
  });

  final int currentStep;
  final List<String> labels;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: i <= currentStep
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ),
            GestureDetector(
              onTap: i <= currentStep ? () => onStepTap(i) : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: i <= currentStep
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    child: Text(
                      '${i + 1}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: i <= currentStep
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    labels[i],
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: i <= currentStep
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Etapa 1: Serviços
// ---------------------------------------------------------------------------

class _ServicesStep extends ConsumerStatefulWidget {
  const _ServicesStep({
    required this.budgetId,
    required this.onNext,
  });

  final String budgetId;
  final VoidCallback onNext;

  @override
  ConsumerState<_ServicesStep> createState() => _ServicesStepState();
}

class _ServicesStepState extends ConsumerState<_ServicesStep> {
  static const _compactButtonStyle = ButtonStyle(
    visualDensity: VisualDensity.compact,
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(budgetsRepositoryProvider);

    return StreamBuilder<BudgetWithItems?>(
      stream: repo.watchById(widget.budgetId),
      builder: (context, snapshot) {
        final data = snapshot.data;
        final items = data?.items ?? [];

        return Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.playlist_add_outlined,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Adicione os serviços',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Toque em + pra adicionar serviços do catálogo\nou criar um item avulso',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return AppCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.description),
                                    Text(
                                      '${item.quantity} ${serviceUnitLabel(item.unit)} × ${formatCents(item.unitPriceCents)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatCents(item.totalCents),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              IconButton(
                                onPressed: () => _removeItem(item),
                                icon: const Icon(Icons.delete_outline, size: 20),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${items.length} ${items.length == 1 ? 'item' : 'itens'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (data != null && data.totals.discountCents > 0)
                        Text(
                          'Desconto: -${formatCents(data.totals.discountCents)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (data != null)
                        Text(
                          'Total: ${formatCents(data.totals.totalCents)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      if (data != null && data.totals.subtotalCents > 0)
                        FilledButton.tonalIcon(
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.percent_outlined, size: 18),
                          label: const Text('Desconto'),
                          onPressed: () => _editDiscount(
                            context,
                            data.budget.discountCents,
                            data.totals.subtotalCents,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
                  ),
                  IconButton(
                    onPressed: () => _pickService(context),
                    icon: const Icon(Icons.add),
                    tooltip: 'Adicionar item',
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  FilledButton(
                    onPressed: items.isNotEmpty ? widget.onNext : null,
                    child: const Text('Próximo'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickService(BuildContext context) async {
    final servicesRepo = ref.read(servicesRepositoryProvider);
    final services = await servicesRepo.watchAll().first;
    if (!context.mounted) return;

    const customItemSentinel = 'custom';
    final selected = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: (MediaQuery.of(context).size.height * 0.6).clamp(400.0, 700.0),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_note_outlined),
                title: const Text('Item avulso'),
                subtitle: const Text('Descrição livre, fora da lista de preços'),
                onTap: () => Navigator.of(context).pop(customItemSentinel),
              ),
              const Divider(height: 1),
              Expanded(
                child: services.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'Nenhum serviço na Lista de Preços ainda.\nUse "Item avulso" acima ou cadastre um serviço na aba Preços.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final s = services[index];
                          return ListTile(
                            title: Text(s.name),
                            subtitle: Text(serviceUnitLabel(s.unit)),
                            onTap: () => Navigator.of(context).pop(s),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!context.mounted || selected == null) return;
    if (selected == customItemSentinel) {
      await _showAddCustomItemSheet(context);
    } else if (selected is Service) {
      await _showAddItemSheet(context, selected);
    }
  }

  Future<double?> _pickMeasurementQuantity(
    BuildContext context,
    ServiceUnit unit,
  ) async {
    final options = _measurementOptionsForUnit(unit);
    if (options.isEmpty) return null;

    final measurementsRepo = ref.read(measurementsRepositoryProvider);
    final clientId = context
        .findAncestorStateOfType<_BudgetWizardScreenState>()
        ?.widget
        .clientId;
    if (clientId == null) return null;

    final projects =
        await measurementsRepo.watchProjectsByClient(clientId).first;
    final allMeasurements = <MeasurementWithDetails>[];
    for (final project in projects) {
      allMeasurements.addAll(
        await measurementsRepo.watchByProject(project.id).first,
      );
    }

    if (!context.mounted) return null;
    if (allMeasurements.isEmpty) {
      AppSnackBar.show(
        context,
        'Nenhuma medição cadastrada pra esse cliente ainda.',
        variant: AppSnackBarVariant.warning,
      );
      return null;
    }

    MeasurementWithDetails? chosen = allMeasurements.first;
    if (allMeasurements.length > 1) {
      chosen = await showModalBottomSheet<MeasurementWithDetails>(
        context: context,
        showDragHandle: true,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Qual medição?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final m in allMeasurements)
                ListTile(
                  title: Text(m.measurement.name),
                  onTap: () => Navigator.of(context).pop(m),
                ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      );
      if (chosen == null || !context.mounted) return null;
    }

    final derived = RoomDerivedQuantities.fromMeasurement(
      lengthMeters: chosen.measurement.lengthMeters,
      widthMeters: chosen.measurement.widthMeters,
      heightMeters: chosen.measurement.heightMeters,
      openings: chosen.openings,
    );

    if (!context.mounted) return null;
    return showModalBottomSheet<double>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Qual grandeza?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final option in options)
              ListTile(
                title: Text(_measurementQuantityLabel(option)),
                trailing: Text(
                  _measurementQuantityValue(option, derived).toStringAsFixed(2),
                ),
                onTap: () => Navigator.of(context)
                    .pop(_measurementQuantityValue(option, derived)),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddItemSheet(BuildContext context, Service service) async {
    final quantityController = TextEditingController();
    int? priceCents = service.defaultPriceCents;
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(service.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              AppNumberInput(
                label: 'Quantidade (${serviceUnitLabel(service.unit)})',
                controller: quantityController,
              ),
              if (_measurementOptionsForUnit(service.unit).isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    style: _compactButtonStyle,
                    icon: const Icon(Icons.straighten_outlined, size: 18),
                    label: const Text('Usar medição'),
                    onPressed: () async {
                      final value = await _pickMeasurementQuantity(
                        context,
                        service.unit,
                      );
                      if (value != null) {
                        quantityController.text = value.toStringAsFixed(2);
                      }
                    },
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppCurrencyInput(
                label: 'Preço unitário (R\$)',
                initialValueCents: priceCents,
                onChangedCents: (cents) => priceCents = cents,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Adicionar item',
                onPressed: () async {
                  final quantity = double.tryParse(
                    quantityController.text.replaceAll(',', '.'),
                  );
                  if (quantity == null || quantity <= 0 || priceCents == null) {
                    AppSnackBar.show(
                      context,
                      'Informe quantidade e preço válidos.',
                      variant: AppSnackBarVariant.warning,
                    );
                    return;
                  }
                  final repo = ref.read(budgetsRepositoryProvider);
                  await repo.addItem(
                    widget.budgetId,
                    BudgetItemInput(
                      description: service.name,
                      unit: service.unit,
                      quantity: quantity,
                      unitPriceCents: priceCents!,
                      includesMaterial: service.includesMaterial,
                    ),
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddCustomItemSheet(BuildContext context) async {
    final descriptionController = TextEditingController();
    final quantityController = TextEditingController();
    var unit = ServiceUnit.squareMeter;
    int? priceCents;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
              Text(
                'Item avulso',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: descriptionController,
                label: 'Descrição',
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<ServiceUnit>(
                initialValue: unit,
                decoration: const InputDecoration(labelText: 'Unidade'),
                items: ServiceUnit.values
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(serviceUnitLabel(u)),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setSheetState(() => unit = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppNumberInput(
                label: 'Quantidade (${serviceUnitLabel(unit)})',
                controller: quantityController,
              ),
              if (_measurementOptionsForUnit(unit).isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    style: _compactButtonStyle,
                    icon: const Icon(Icons.straighten_outlined, size: 18),
                    label: const Text('Usar medição'),
                    onPressed: () async {
                      final value = await _pickMeasurementQuantity(
                        context,
                        unit,
                      );
                      if (value != null) {
                        quantityController.text = value.toStringAsFixed(2);
                      }
                    },
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppCurrencyInput(
                label: 'Preço unitário (R\$)',
                onChangedCents: (cents) => priceCents = cents,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Adicionar item',
                onPressed: () async {
                  final description = descriptionController.text.trim();
                  final quantity = double.tryParse(
                    quantityController.text.replaceAll(',', '.'),
                  );
                  if (description.isEmpty ||
                      quantity == null ||
                      quantity <= 0 ||
                      priceCents == null) {
                    AppSnackBar.show(
                      context,
                      'Informe descrição, quantidade e preço válidos.',
                      variant: AppSnackBarVariant.warning,
                    );
                    return;
                  }
                  final repo = ref.read(budgetsRepositoryProvider);
                  await repo.addItem(
                    widget.budgetId,
                    BudgetItemInput(
                      description: description,
                      unit: unit,
                      quantity: quantity,
                      unitPriceCents: priceCents!,
                    ),
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editDiscount(
    BuildContext context,
    int currentDiscountCents,
    int subtotalCents,
  ) async {
    var isPercent = false;
    int? newDiscount = currentDiscountCents;
    final percentController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
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
              Text('Desconto', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Valor fixo')),
                  ButtonSegment(value: true, label: Text('Percentual')),
                ],
                selected: {isPercent},
                onSelectionChanged: (selection) =>
                    setSheetState(() => isPercent = selection.first),
              ),
              const SizedBox(height: AppSpacing.md),
              if (isPercent)
                AppNumberInput(
                  label: 'Desconto (%)',
                  controller: percentController,
                )
              else
                AppCurrencyInput(
                  label: 'Valor do desconto (R\$)',
                  initialValueCents: currentDiscountCents == 0
                      ? null
                      : currentDiscountCents,
                  onChangedCents: (cents) => newDiscount = cents,
                ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Salvar',
                onPressed: () async {
                  if (isPercent) {
                    final percent = double.tryParse(
                      percentController.text.replaceAll(',', '.'),
                    );
                    newDiscount = percent == null
                        ? 0
                        : (subtotalCents * percent / 100).round();
                  }
                  final repo = ref.read(budgetsRepositoryProvider);
                  await repo.updateDiscount(widget.budgetId, newDiscount ?? 0);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeItem(BudgetItem item) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Remover item',
      message: 'Remover "${item.description}" do orçamento?',
      isDestructive: true,
    );
    if (confirmed == true) {
      final repo = ref.read(budgetsRepositoryProvider);
      await repo.removeItem(item.id);
    }
  }
}

// ---------------------------------------------------------------------------
// Etapa 2: Condições
// ---------------------------------------------------------------------------

class _ConditionsStep extends ConsumerStatefulWidget {
  const _ConditionsStep({
    required this.budgetId,
    required this.onNext,
    required this.onBack,
  });

  final String budgetId;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  ConsumerState<_ConditionsStep> createState() => _ConditionsStepState();
}

class _ConditionsStepState extends ConsumerState<_ConditionsStep> {
  final _notesController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  DateTime? _validUntil;
  bool _loaded = false;

  @override
  void dispose() {
    _notesController.dispose();
    _jobDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadBudget() async {
    if (_loaded) return;
    final repo = ref.read(budgetsRepositoryProvider);
    final data = await repo.watchById(widget.budgetId).first;
    if (data == null || !mounted) return;
    _notesController.text = data.budget.notes ?? '';
    _jobDescriptionController.text = data.budget.jobDescription ?? '';
    _validUntil = data.budget.validUntil;
    setState(() => _loaded = true);
  }

  Future<void> _saveAndNext() async {
    final repo = ref.read(budgetsRepositoryProvider);
    final notes = _notesController.text.trim();
    final jobDescription = _jobDescriptionController.text.trim();
    await repo.updateDetails(
      widget.budgetId,
      notes: notes.isEmpty ? null : notes,
      validUntil: _validUntil,
      jobDescription: jobDescription.isEmpty ? null : jobDescription,
    );
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadBudget(),
      builder: (context, _) {
        if (!_loaded) return const Center(child: CircularProgressIndicator());

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(
              'Detalhes do orçamento',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tudo opcional. Preencha só o que fizer sentido.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: 'Descrição da obra',
              hint: 'O que vai ser feito na obra, resumido — aparece no PDF enviado',
              controller: _jobDescriptionController,
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Observações',
              hint: 'Ex: pagamento em 2x, prazo de 15 dias, garantia de 6 meses',
              controller: _notesController,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.md),
            AppDatePicker(
              label: 'Válido até',
              value: _validUntil,
              onChanged: (date) => setState(() => _validUntil = date),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Text('Voltar'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _saveAndNext,
                  child: const Text('Próximo'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Etapa 3: Revisão
// ---------------------------------------------------------------------------

class _ReviewStep extends ConsumerWidget {
  const _ReviewStep({
    required this.budgetId,
    required this.clientId,
    required this.onNext,
    required this.onBack,
  });

  final String budgetId;
  final String clientId;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(budgetsRepositoryProvider);
    final clientsRepo = ref.read(clientsRepositoryProvider);

    return StreamBuilder<BudgetWithItems?>(
      stream: repo.watchById(budgetId),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final budget = data.budget;
        final totals = data.totals;

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Text(
                    'Revise seu orçamento',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildClientSection(context, clientsRepo),
                  const SizedBox(height: AppSpacing.md),
                  if (budget.jobDescription != null &&
                      budget.jobDescription!.isNotEmpty) ...[
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Descrição da obra',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(budget.jobDescription!),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Text(
                    'Serviços (${data.items.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final item in data.items)
                    AppCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.description),
                                Text(
                                  '${item.quantity} ${serviceUnitLabel(item.unit)} × ${formatCents(item.unitPriceCents)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatCents(item.totalCents),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  AppCard(
                    child: Column(
                      children: [
                        _reviewRow(context, 'Subtotal', formatCents(totals.subtotalCents)),
                        if (totals.discountCents > 0) ...[
                          const SizedBox(height: AppSpacing.xs),
                          _reviewRow(
                            context,
                            'Desconto',
                            '- ${formatCents(totals.discountCents)}',
                            color: context.semanticColors.warning,
                          ),
                        ],
                        const Divider(),
                        _reviewRow(
                          context,
                          'Total',
                          formatCents(totals.totalCents),
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                  if (budget.notes != null && budget.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Observações',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(budget.notes!),
                        ],
                      ),
                    ),
                  ],
                  if (budget.validUntil != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Válido até ${budget.validUntil!.day.toString().padLeft(2, '0')}/'
                      '${budget.validUntil!.month.toString().padLeft(2, '0')}/'
                      '${budget.validUntil!.year}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: onBack,
                    child: const Text('Voltar'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: data.items.isNotEmpty ? onNext : null,
                    child: const Text('Gerar orçamento'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildClientSection(BuildContext context, ClientsRepository clientsRepo) {
    return FutureBuilder<Client?>(
      future: clientsRepo.getById(clientId),
      builder: (context, snapshot) {
        final client = snapshot.data;
        if (client == null) return const SizedBox.shrink();
        return AppCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  client.name[0].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (client.phone != null && client.phone!.isNotEmpty)
                      Text(
                        client.phone!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reviewRow(
    BuildContext context,
    String label,
    String value, {
    bool bold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontSize: bold ? 18 : null,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Etapa 4: Envio
// ---------------------------------------------------------------------------

class _SendStep extends ConsumerStatefulWidget {
  const _SendStep({
    required this.budgetId,
    required this.clientId,
    required this.onBack,
  });

  final String budgetId;
  final String clientId;
  final VoidCallback onBack;

  @override
  ConsumerState<_SendStep> createState() => _SendStepState();
}

class _SendStepState extends ConsumerState<_SendStep> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (!_sent) ...[
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Orçamento pronto!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Escolha como mandar pro cliente.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Enviar como PDF',
            icon: Icons.picture_as_pdf_outlined,
            onPressed: () => _share(BudgetShareFormat.pdf),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Enviar como imagem',
            icon: Icons.image_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: () => _share(BudgetShareFormat.image),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              OutlinedButton(
                onPressed: widget.onBack,
                child: const Text('Voltar'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _skipAndFinish(),
                child: const Text('Depois eu envio'),
              ),
            ],
          ),
        ] else ...[
          Icon(
            Icons.mark_email_read_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Orçamento enviado!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pronto! O orçamento foi enviado.\nAcompanhe se o cliente respondeu na aba Orçamentos.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Concluir',
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          ),
        ],
      ],
    );
  }

  Future<void> _share(BudgetShareFormat format) async {
    final repo = ref.read(budgetsRepositoryProvider);
    final clientsRepo = ref.read(clientsRepositoryProvider);
    final profileRepo = ref.read(profileRepositoryProvider);

    final data = await repo.watchById(widget.budgetId).first;
    final client = await clientsRepo.getById(widget.clientId);
    if (data == null || client == null || !context.mounted) return;

    final professional = await profileRepo.getProfile();

    if (format == BudgetShareFormat.pdf) {
      await BudgetShareService.shareAsPdf(
        data: data,
        client: client,
        professional: professional,
      );
    } else {
      await BudgetShareService.shareAsImage(
        data: data,
        client: client,
        professional: professional,
      );
    }

    final formatParam = format == BudgetShareFormat.pdf ? 'pdf' : 'imagem';
    AnalyticsService.trackEvent('pdf_generated', {'format': formatParam});
    AnalyticsService.trackEvent('budget_shared', {'format': formatParam});
    unawaited(ReviewService.requestReviewIfAvailable());

    await repo.updateStatus(widget.budgetId, BudgetStatus.sent);

    if (mounted) setState(() => _sent = true);
  }

  Future<void> _skipAndFinish() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

// ---------------------------------------------------------------------------
// Helpers (mesmos do budget_form_screen, reaproveitados)
// ---------------------------------------------------------------------------

enum _MeasurementQuantity {
  wallArea,
  floorArea,
  ceilingArea,
  perimeter,
  effectivePerimeter,
}

String _measurementQuantityLabel(_MeasurementQuantity q) => switch (q) {
      _MeasurementQuantity.wallArea => 'Área de parede',
      _MeasurementQuantity.floorArea => 'Área de piso',
      _MeasurementQuantity.ceilingArea => 'Área de teto',
      _MeasurementQuantity.perimeter => 'Perímetro',
      _MeasurementQuantity.effectivePerimeter => 'Perímetro útil',
    };

double _measurementQuantityValue(
  _MeasurementQuantity q,
  RoomDerivedQuantities d,
) =>
    switch (q) {
      _MeasurementQuantity.wallArea => d.wallAreaSqM,
      _MeasurementQuantity.floorArea => d.floorAreaSqM,
      _MeasurementQuantity.ceilingArea => d.ceilingAreaSqM,
      _MeasurementQuantity.perimeter => d.perimeterMeters,
      _MeasurementQuantity.effectivePerimeter => d.effectivePerimeterMeters,
    };

List<_MeasurementQuantity> _measurementOptionsForUnit(ServiceUnit unit) =>
    switch (unit) {
      ServiceUnit.squareMeter => const [
          _MeasurementQuantity.wallArea,
          _MeasurementQuantity.floorArea,
          _MeasurementQuantity.ceilingArea,
        ],
      ServiceUnit.linearMeter => const [
          _MeasurementQuantity.perimeter,
          _MeasurementQuantity.effectivePerimeter,
        ],
      _ => const [],
    };
