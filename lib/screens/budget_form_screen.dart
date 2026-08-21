import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/database.dart';
import '../database/enums.dart';
import '../providers/budgets_repository_provider.dart';
import '../providers/services_repository_provider.dart';
import '../repositories/budgets_repository.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_currency_input.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_number_input.dart';
import 'service_unit_label.dart';

String statusLabel(BudgetStatus status) {
  switch (status) {
    case BudgetStatus.draft:
      return 'Rascunho';
    case BudgetStatus.sent:
      return 'Enviado';
    case BudgetStatus.accepted:
      return 'Aceito';
    case BudgetStatus.declined:
      return 'Recusado';
  }
}

String formatCents(int cents) {
  final reais = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $reais';
}

class BudgetFormScreen extends ConsumerStatefulWidget {
  const BudgetFormScreen({super.key, required this.clientId, this.budgetId});

  final String clientId;
  final String? budgetId;

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  String? _budgetId;

  @override
  void initState() {
    super.initState();
    _budgetId = widget.budgetId;
    if (_budgetId == null) {
      _createDraft();
    }
  }

  Future<void> _createDraft() async {
    final repo = ref.read(budgetsRepositoryProvider);
    final budget = await repo.create(clientId: widget.clientId);
    if (mounted) {
      setState(() => _budgetId = budget.id);
    }
  }

  Future<void> _pickService(BuildContext context) async {
    final servicesRepo = ref.read(servicesRepositoryProvider);
    final services = await servicesRepo.watchAll().first;
    if (!context.mounted) return;

    final selected = await showModalBottomSheet<Service>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: services.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Nenhum serviço cadastrado.\nCadastre na Lista de Preços primeiro.',
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
      ),
    );

    if (selected != null && context.mounted) {
      await _showAddItemSheet(context, selected);
    }
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
              const SizedBox(height: 16),
              AppNumberInput(
                label: 'Quantidade (${serviceUnitLabel(service.unit)})',
                controller: quantityController,
              ),
              const SizedBox(height: 16),
              AppCurrencyInput(
                label: 'Preço unitário (R\$)',
                initialValueCents: priceCents,
                onChangedCents: (cents) => priceCents = cents,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Adicionar item',
                onPressed: () async {
                  final quantity = double.tryParse(quantityController.text.replaceAll(',', '.'));
                  if (quantity == null || quantity <= 0 || priceCents == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Informe quantidade e preço válidos.')),
                    );
                    return;
                  }
                  final repo = ref.read(budgetsRepositoryProvider);
                  await repo.addItem(
                    _budgetId!,
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

  Future<void> _editDiscount(int currentDiscountCents) async {
    int? newDiscount = currentDiscountCents;
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Desconto', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            AppCurrencyInput(
              label: 'Valor do desconto (R\$)',
              initialValueCents: currentDiscountCents == 0 ? null : currentDiscountCents,
              onChangedCents: (cents) => newDiscount = cents,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Salvar',
              onPressed: () async {
                final repo = ref.read(budgetsRepositoryProvider);
                await repo.updateDiscount(_budgetId!, newDiscount ?? 0);
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _advanceStatus(BudgetStatus current) async {
    final next = switch (current) {
      BudgetStatus.draft => BudgetStatus.sent,
      BudgetStatus.sent => BudgetStatus.accepted,
      BudgetStatus.accepted => BudgetStatus.accepted,
      BudgetStatus.declined => BudgetStatus.declined,
    };
    if (next != current) {
      final repo = ref.read(budgetsRepositoryProvider);
      await repo.updateStatus(_budgetId!, next);
    }
  }

  Future<void> _declineStatus() async {
    final repo = ref.read(budgetsRepositoryProvider);
    await repo.updateStatus(_budgetId!, BudgetStatus.declined);
  }

  @override
  Widget build(BuildContext context) {
    if (_budgetId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final repo = ref.watch(budgetsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamento'),
        actions: [
          IconButton(
            onPressed: () => _pickService(context),
            icon: const Icon(Icons.add),
            tooltip: 'Adicionar item',
          ),
        ],
      ),
      body: StreamBuilder<BudgetWithItems?>(
        stream: repo.watchById(_budgetId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          final budget = data.budget;
          final totals = data.totals;

          return Column(
            children: [
              Expanded(
                child: data.items.isEmpty
                    ? const Center(child: Text('Toque em + para adicionar itens.'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: data.items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = data.items[index];
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
                                        style: Theme.of(context).textTheme.bodySmall,
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal'),
                        Text(formatCents(totals.subtotalCents)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => _editDiscount(budget.discountCents),
                          child: const Text('Desconto'),
                        ),
                        Text('- ${formatCents(totals.discountCents)}'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: Theme.of(context).textTheme.titleLarge),
                        Text(
                          formatCents(totals.totalCents),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Status: ${statusLabel(budget.status)}',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        if (budget.status == BudgetStatus.draft || budget.status == BudgetStatus.sent)
                          AppButton(
                            label: budget.status == BudgetStatus.draft ? 'Marcar como enviado' : 'Marcar como aceito',
                            onPressed: () => _advanceStatus(budget.status),
                            variant: AppButtonVariant.secondary,
                          ),
                        if (budget.status == BudgetStatus.sent) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _declineStatus,
                            icon: const Icon(Icons.close),
                            tooltip: 'Marcar como recusado',
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
