import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_service.dart';
import '../budget/budget_calculations.dart';
import '../database/database.dart';
import '../review/review_service.dart';
import '../database/enums.dart';
import '../pdf/budget_share_service.dart';
import '../providers/budgets_repository_provider.dart';
import '../providers/clients_repository_provider.dart';
import '../providers/payments_repository_provider.dart';
import '../providers/profile_repository_provider.dart';
import '../providers/services_repository_provider.dart';
import '../repositories/budgets_repository.dart';
import '../theme/app_semantic_colors.dart';
import '../utils/currency_format.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_currency_input.dart';
import '../widgets/app_date_picker.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_number_input.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/app_text_field.dart';
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

String formatCents(int cents) => formatCurrencyBrl(cents);

class BudgetFormScreen extends ConsumerStatefulWidget {
  const BudgetFormScreen({super.key, required this.clientId, this.budgetId});

  final String clientId;
  final String? budgetId;

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  /// Acima disso, confirma antes de adicionar o item — ver
  /// docs/ANALISE_CONCORRENCIA_E_ESCOPO.md, Parte 5, item 17: evidência
  /// real de um item de 619 m² aceito num concorrente sem nenhum aviso.
  /// Sem histórico de preços suficiente pra uma baseline estatística por
  /// serviço, um teto fixo é a versão simples e generalizável do "confere?".
  static const _highValueThresholdCents = 1000000; // R$ 10.000,00

  String? _budgetId;

  @override
  void initState() {
    super.initState();
    _budgetId = widget.budgetId;
    if (_budgetId == null) {
      AnalyticsService.trackEvent('create_budget');
      _createDraft();
    }
  }

  Future<void> _createDraft() async {
    final repo = ref.read(budgetsRepositoryProvider);
    final budget = await repo.create(clientId: widget.clientId);
    AnalyticsService.trackEvent('budget_created');
    if (mounted) {
      setState(() => _budgetId = budget.id);
    }
  }

  Future<void> _pickService(BuildContext context) async {
    final servicesRepo = ref.read(servicesRepositoryProvider);
    final services = await servicesRepo.watchAll().first;
    if (!context.mounted) return;

    // "Item avulso" sempre disponível, mesmo com a Lista de Preços vazia —
    // sem isso, o "+" virava um beco sem saída (só uma mensagem, sem botão
    // nenhum) pra quem ainda não cadastrou nenhum serviço.
    const customItemSentinel = 'custom';
    final selected = await showModalBottomSheet<Object>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
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
                          padding: EdgeInsets.all(24),
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

  /// `true` se pode adicionar direto; se o total passar do teto, pede
  /// confirmação antes — ver `_highValueThresholdCents`.
  Future<bool> _confirmIfHighValue(BuildContext context, {required double quantity, required int unitPriceCents}) async {
    final totalCents = BudgetItemCalculation.itemTotalCents(quantity: quantity, unitPriceCents: unitPriceCents);
    if (totalCents <= _highValueThresholdCents) return true;
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Confere?',
      message: 'Esse item soma ${formatCurrencyBrl(totalCents)}. Confere a quantidade e o preço antes de adicionar?',
      confirmLabel: 'Confere, adicionar',
    );
    return confirmed == true;
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
                    AppSnackBar.show(
                      context,
                      'Informe quantidade e preço válidos.',
                      variant: AppSnackBarVariant.warning,
                    );
                    return;
                  }
                  final ok = await _confirmIfHighValue(context, quantity: quantity, unitPriceCents: priceCents!);
                  if (!ok) return;
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

  /// Item que não está (ainda) na Lista de Preços — descrição livre em
  /// vez de escolher um serviço pré-cadastrado.
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
              Text('Item avulso', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              AppTextField(
                controller: descriptionController,
                label: 'Descrição',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ServiceUnit>(
                initialValue: unit,
                decoration: const InputDecoration(labelText: 'Unidade'),
                items: ServiceUnit.values
                    .map((u) => DropdownMenuItem(value: u, child: Text(serviceUnitLabel(u))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setSheetState(() => unit = val);
                },
              ),
              const SizedBox(height: 16),
              AppNumberInput(
                label: 'Quantidade (${serviceUnitLabel(unit)})',
                controller: quantityController,
              ),
              const SizedBox(height: 16),
              AppCurrencyInput(
                label: 'Preço unitário (R\$)',
                onChangedCents: (cents) => priceCents = cents,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Adicionar item',
                onPressed: () async {
                  final description = descriptionController.text.trim();
                  final quantity = double.tryParse(quantityController.text.replaceAll(',', '.'));
                  if (description.isEmpty || quantity == null || quantity <= 0 || priceCents == null) {
                    AppSnackBar.show(
                      context,
                      'Informe descrição, quantidade e preço válidos.',
                      variant: AppSnackBarVariant.warning,
                    );
                    return;
                  }
                  final ok = await _confirmIfHighValue(context, quantity: quantity, unitPriceCents: priceCents!);
                  if (!ok) return;
                  final repo = ref.read(budgetsRepositoryProvider);
                  await repo.addItem(
                    _budgetId!,
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
              const SizedBox(height: 16),
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

  /// Registra um pagamento recebido (ver CLAUDE.md, "controle de
  /// pagamentos" — semente do plano Pro).
  Future<void> _registerPayment(BuildContext context) async {
    final notesController = TextEditingController();
    int? amountCents;

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
            Text('Registrar pagamento', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            AppCurrencyInput(
              label: 'Valor recebido (R\$)',
              onChangedCents: (cents) => amountCents = cents,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: notesController,
              label: 'Observação (opcional)',
              hint: 'Ex.: entrada, parcela 2',
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Registrar',
              onPressed: () async {
                if (amountCents == null || amountCents! <= 0) {
                  AppSnackBar.show(
                    context,
                    'Informe um valor válido.',
                    variant: AppSnackBarVariant.warning,
                  );
                  return;
                }
                final notes = notesController.text.trim();
                await ref.read(paymentsRepositoryProvider).create(
                      budgetId: _budgetId!,
                      amountCents: amountCents!,
                      notes: notes.isEmpty ? null : notes,
                    );
                AnalyticsService.trackEvent('payment_registered');
                if (context.mounted) {
                  AppSnackBar.show(context, 'Pagamento registrado.');
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _removePayment(Payment payment) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Remover pagamento',
      message: 'Remover o registro de ${formatCents(payment.amountCents)}?',
      isDestructive: true,
    );
    if (confirmed == true) {
      await ref.read(paymentsRepositoryProvider).softDelete(payment.id);
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

  Future<void> _editDetails(Budget budget) async {
    final notesController = TextEditingController(text: budget.notes ?? '');
    final jobDescriptionController = TextEditingController(text: budget.jobDescription ?? '');
    DateTime? validUntil = budget.validUntil;

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
              Text('Detalhes do orçamento', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Descrição da obra (opcional)',
                hint: 'O que vai ser feito, resumido — aparece no PDF acima dos itens',
                controller: jobDescriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Observações',
                hint: 'Condições de pagamento, prazo, garantia',
                controller: notesController,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              AppDatePicker(
                label: 'Válido até',
                value: validUntil,
                onChanged: (date) => setSheetState(() => validUntil = date),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Salvar',
                onPressed: () async {
                  final repo = ref.read(budgetsRepositoryProvider);
                  final notes = notesController.text.trim();
                  final jobDescription = jobDescriptionController.text.trim();
                  await repo.updateDetails(
                    _budgetId!,
                    notes: notes.isEmpty ? null : notes,
                    validUntil: validUntil,
                    jobDescription: jobDescription.isEmpty ? null : jobDescription,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
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

  Future<void> _shareBudget(BuildContext context, BudgetWithItems data) async {
    final format = await AppBottomSheet.showActions<BudgetShareFormat>(
      context,
      title: 'Compartilhar orçamento',
      actions: const [
        AppBottomSheetAction(
          label: 'Como PDF',
          value: BudgetShareFormat.pdf,
          icon: Icons.picture_as_pdf_outlined,
        ),
        AppBottomSheetAction(
          label: 'Como imagem',
          value: BudgetShareFormat.image,
          icon: Icons.image_outlined,
        ),
      ],
    );
    if (format == null || !context.mounted) return;

    final clientsRepo = ref.read(clientsRepositoryProvider);
    final profileRepo = ref.read(profileRepositoryProvider);

    final client = await clientsRepo.getById(data.budget.clientId);
    if (client == null) return;
    final professional = await profileRepo.getProfile();

    if (format == BudgetShareFormat.pdf) {
      await BudgetShareService.shareAsPdf(data: data, client: client, professional: professional);
    } else {
      await BudgetShareService.shareAsImage(data: data, client: client, professional: professional);
    }
    final formatParam = format == BudgetShareFormat.pdf ? 'pdf' : 'imagem';
    AnalyticsService.trackEvent('pdf_generated', {'format': formatParam});
    // Nota: a folha de compartilhamento do sistema (share_plus) não informa
    // qual app o usuário escolheu — não dá pra registrar o parâmetro
    // `channel` (whatsapp/email/outro) pedido no CLAUDE.md com os dados
    // disponíveis hoje.
    AnalyticsService.trackEvent('budget_shared', {'format': formatParam});
    // Momento de sucesso: acabou de compartilhar um orçamento de verdade.
    unawaited(ReviewService.requestReviewIfAvailable());

    if (data.budget.status == BudgetStatus.draft) {
      final repo = ref.read(budgetsRepositoryProvider);
      await repo.updateStatus(_budgetId!, BudgetStatus.sent);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_budgetId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final repo = ref.watch(budgetsRepositoryProvider);

    return StreamBuilder<BudgetWithItems?>(
      stream: repo.watchById(_budgetId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Orçamento')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data!;
        final budget = data.budget;
        final totals = data.totals;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Orçamento'),
            actions: [
              if (data.items.isNotEmpty)
                IconButton(
                  onPressed: () => _shareBudget(context, data),
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Compartilhar orçamento',
                ),
              IconButton(
                onPressed: () => _editDetails(budget),
                icon: const Icon(Icons.notes_outlined),
                tooltip: 'Detalhes',
              ),
              IconButton(
                onPressed: () => _pickService(context),
                icon: const Icon(Icons.add),
                tooltip: 'Adicionar item',
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: data.items.isEmpty
                    ? const Center(child: Text('Toque em + para adicionar itens.'))
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          for (final item in data.items) ...[
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
                                  IconButton(
                                    onPressed: () => _removeItem(item),
                                    icon: const Icon(Icons.delete_outline, size: 20),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          if (data.payments.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Text('Pagamentos recebidos', style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            for (final payment in data.payments) ...[
                              AppCard(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(formatCents(payment.amountCents)),
                                          Text(
                                            [
                                              '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}',
                                              if (payment.notes != null && payment.notes!.isNotEmpty) payment.notes!,
                                            ].join(' · '),
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removePayment(payment),
                                      icon: const Icon(Icons.delete_outline, size: 20),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ],
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
                    if (data.items.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recebido', style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            formatCents(data.totalPaidCents),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.semanticColors.success,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => _registerPayment(context),
                            child: const Text('Registrar pagamento'),
                          ),
                          Text(
                            'Pendente: ${formatCents(data.pendingCents)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
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
          ),
        );
      },
    );
  }
}
