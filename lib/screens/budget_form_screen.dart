import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_service.dart';
import '../database/database.dart';
import '../measurement/measurement_quantities.dart';
import '../review/review_service.dart';
import '../database/enums.dart';
import '../pdf/budget_share_service.dart';
import '../providers/budget_templates_repository_provider.dart';
import '../providers/budgets_repository_provider.dart';
import '../providers/clients_repository_provider.dart';
import '../providers/home_refresh_provider.dart';
import '../providers/measurements_repository_provider.dart';
import '../providers/payments_repository_provider.dart';
import '../providers/profile_repository_provider.dart';
import '../providers/services_repository_provider.dart';
import '../repositories/budgets_repository.dart';
import '../theme/app_semantic_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/currency_format.dart';
import '../utils/measurement_flow.dart';
import '../utils/quantity_format.dart';
import '../widgets/app_bottom_sheet.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_currency_input.dart';
import '../widgets/app_date_picker.dart';
import '../widgets/app_dialog.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
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

/// Opções de grandeza por unidade, rótulos e valores são centralizadas em
/// `lib/measurement/measurement_quantities.dart` — incluindo o volume m³
/// (que passou a pedir a espessura no fluxo de "usar cômodo medido").
/// Este arquivo e o `budget_wizard_screen.dart` compartilham o mesmo
/// serviço, sem duplicação.

class BudgetFormScreen extends ConsumerStatefulWidget {
  const BudgetFormScreen({super.key, required this.clientId, this.budgetId});

  final String clientId;
  final String? budgetId;

  @override
  ConsumerState<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends ConsumerState<BudgetFormScreen> {
  /// Botões pequenos dentro do painel de totais (Desconto, Registrar
  /// pagamento, Emitir recibo) — visivelmente clicáveis (preenchidos/com
  /// borda, não texto solto), mas compactos pra caber lado a lado com o
  /// valor. Ver feedback de teste manual: os `TextButton` de antes
  /// pareciam "invisíveis".
  static const _compactButtonStyle = ButtonStyle(
    visualDensity: VisualDensity.compact,
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12)),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  String? _budgetId;

  /// "Orçamento nº N" — âncora de continuidade com a lista e com o
  /// `BudgetWizardScreen` (onde o rascunho foi montado): o número é o
  /// mesmo em todos os lugares, então o profissional reconhece que está
  /// no mesmo documento mesmo quando a tela muda (rascunho abre no
  /// wizard, enviado abre aqui).
  String? _budgetNumberLabel;

  @override
  void initState() {
    super.initState();
    _budgetId = widget.budgetId;
    if (_budgetId == null) {
      AnalyticsService.trackEvent('create_budget');
      _createDraft();
    } else {
      _loadBudgetNumber();
    }
  }

  Future<void> _loadBudgetNumber() async {
    final id = _budgetId;
    if (id == null) return;
    final number = await ref.read(budgetsRepositoryProvider).getBudgetNumber(id);
    if (mounted) setState(() => _budgetNumberLabel = 'Orçamento nº $number');
  }

  Future<void> _createDraft() async {
    final repo = ref.read(budgetsRepositoryProvider);
    final budget = await repo.create(clientId: widget.clientId);
    AnalyticsService.trackEvent('budget_created');
    if (mounted) {
      setState(() => _budgetId = budget.id);
    }
    _loadBudgetNumber();
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
          height: (MediaQuery.of(context).size.height * 0.6).clamp(400.0, 700.0),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_note_outlined),
                title: const Text('Item avulso'),
                subtitle: const Text(
                  'Descrição livre, fora da lista de preços',
                ),
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
              if (measurementQuantityOptions(service.unit).isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    style: _compactButtonStyle,
                    icon: const Icon(Icons.straighten_outlined, size: 18),
                    label: const Text('Usar cômodo medido'),
                    onPressed: () async {
                      final value = await pickMeasurementQuantity(
                        context,
                        ref,
                        clientId: widget.clientId,
                        unit: service.unit,
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
              if (measurementQuantityOptions(unit).isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    style: _compactButtonStyle,
                    icon: const Icon(Icons.straighten_outlined, size: 18),
                    label: const Text('Usar cômodo medido'),
                    onPressed: () async {
                      final value = await pickMeasurementQuantity(
                        context,
                        ref,
                        clientId: widget.clientId,
                        unit: unit,
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
              const SizedBox(height: AppSpacing.md),
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
            Text(
              'Registrar pagamento',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCurrencyInput(
              label: 'Valor recebido (R\$)',
              onChangedCents: (cents) => amountCents = cents,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: notesController,
                label: 'Observação',
                hint: 'Ex: entrada, 2ª parcela',
            ),
            const SizedBox(height: AppSpacing.lg),
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
                await ref
                    .read(paymentsRepositoryProvider)
                    .create(
                      budgetId: _budgetId!,
                      amountCents: amountCents!,
                      notes: notes.isEmpty ? null : notes,
                    );
                AnalyticsService.trackEvent('payment_registered');
                // Recebidos/Aguardando/Aprovados na Home dependem de
                // pagamentos — sem isso a Home só atualizava na próxima
                // vez que o app fosse reaberto (ver `homeRefreshProvider`).
                ref.read(homeRefreshProvider.notifier).bump();
                if (context.mounted) {
                  AppSnackBar.show(context, 'Pagamento registrado.');
                  Navigator.of(context).pop();
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
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
      ref.read(homeRefreshProvider.notifier).bump();
    }
  }

  Future<void> _editDiscount(
    int currentDiscountCents,
    int subtotalCents,
  ) async {
    // Só `discountCents` é persistido (regra "dinheiro é int em centavos" —
    // ver CLAUDE.md); percentual é só o modo de entrada, convertido pra
    // centavos no momento de salvar, mesmo arredondamento meio-pra-cima já
    // usado em `budget_calculations.dart`.
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
                  await repo.updateDiscount(_budgetId!, newDiscount ?? 0);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editDetails(Budget budget) async {
    final notesController = TextEditingController(text: budget.notes ?? '');
    final jobDescriptionController = TextEditingController(
      text: budget.jobDescription ?? '',
    );
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
              Text(
                'Detalhes do orçamento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Descrição da obra',
                hint: 'O que vai ser feito, resumido — aparece no PDF',
                controller: jobDescriptionController,
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Observações',
                hint: 'Condições de pagamento, prazo, garantia',
                controller: notesController,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.md),
              AppDatePicker(
                label: 'Válido até',
                value: validUntil,
                onChanged: (date) => setSheetState(() => validUntil = date),
              ),
              const SizedBox(height: AppSpacing.lg),
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
                    jobDescription: jobDescription.isEmpty
                        ? null
                        : jobDescription,
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
      // Aguardando/Aprovados na Home dependem do status do orçamento.
      ref.read(homeRefreshProvider.notifier).bump();
    }
  }

  Future<void> _declineStatus() async {
    final repo = ref.read(budgetsRepositoryProvider);
    await repo.updateStatus(_budgetId!, BudgetStatus.declined);
    ref.read(homeRefreshProvider.notifier).bump();
  }

  /// Recibo de um pagamento específico — cada pagamento parcial gera seu
  /// próprio recibo, não o total acumulado do orçamento. Ver
  /// docs/POSICIONAMENTO_E_FEATURES_APP1.md, Parte 4, item 10.
  Future<void> _emitReceipt(
    BuildContext context,
    BudgetWithItems data,
    Payment payment,
  ) async {
    final clientsRepo = ref.read(clientsRepositoryProvider);
    final profileRepo = ref.read(profileRepositoryProvider);

    final client = await clientsRepo.getById(data.budget.clientId);
    if (client == null || !context.mounted) return;
    final professional = await profileRepo.getProfile();

    await BudgetShareService.shareReceipt(
      client: client,
      professional: professional,
      amountCents: payment.amountCents,
      date: payment.createdAt,
      note: payment.notes ?? data.budget.jobDescription,
    );
    AnalyticsService.trackEvent('pdf_generated', {'format': 'recibo'});
  }

  /// `BudgetsRepository.duplicate` já existia, mas não tinha nenhum
  /// caminho na UI desde que `budgets_screen.dart` foi removido — dado
  /// como "alto uso real" no CLAUDE.md, mas ficou órfão nesse meio tempo.
  Future<void> _duplicateBudget(BuildContext context) async {
    final repo = ref.read(budgetsRepositoryProvider);
    final newBudget = await repo.duplicate(_budgetId!);
    if (!context.mounted) return;
    AppSnackBar.show(context, 'Orçamento duplicado como rascunho.');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BudgetFormScreen(
          clientId: newBudget.clientId,
          budgetId: newBudget.id,
        ),
      ),
    );
  }

  /// Salva os itens/condições deste orçamento como modelo reutilizável —
  /// ver docs/ROADMAP_UX_UI_E_FEATURES_APP1.md, seção 14. Snapshot no
  /// momento do toque; editar o orçamento depois não muda o modelo.
  Future<void> _saveAsTemplate(BuildContext context, BudgetWithItems data) async {
    if (data.items.isEmpty) {
      AppSnackBar.show(
        context,
        'Adicione ao menos um item antes de salvar como modelo.',
        variant: AppSnackBarVariant.warning,
      );
      return;
    }

    final nameController = TextEditingController();
    final name = await showModalBottomSheet<String>(
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
            Text(
              'Salvar como modelo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Os itens e condições deste orçamento ficam salvos pra você '
              'usar de novo em outro cliente.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: nameController,
              label: 'Nome do modelo',
              hint: 'Ex: Pintura residencial',
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Salvar modelo',
              onPressed: () {
                final value = nameController.text.trim();
                if (value.isEmpty) {
                  AppSnackBar.show(
                    context,
                    'Dê um nome pro modelo.',
                    variant: AppSnackBarVariant.warning,
                  );
                  return;
                }
                Navigator.of(context).pop(value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );

    if (name == null || !context.mounted) return;
    await ref.read(budgetTemplatesRepositoryProvider).createFromBudget(
          budgetId: _budgetId!,
          name: name,
        );
    if (context.mounted) {
      AppSnackBar.show(context, 'Modelo "$name" salvo.');
    }
  }

  /// Exclusão lógica, com confirmação — orçamento carrega trabalho de
  /// medição e negociação, e um toque errado no menu não pode custar isso.
  /// Mesmo padrão de confirmação usado pra excluir cliente e medição.
  Future<void> _deleteBudget(BuildContext context) async {
    final confirmed = await AppDialog.confirm(
      context,
      isDestructive: true,
      title: 'Excluir orçamento?',
      message: 'Os itens e pagamentos registrados nele saem junto. '
          'Esta ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
    );
    if (confirmed != true || !context.mounted) return;

    await ref.read(budgetsRepositoryProvider).softDelete(_budgetId!);
    if (!context.mounted) return;
    AppSnackBar.show(
      context,
      'Orçamento excluído.',
      variant: AppSnackBarVariant.destructive,
    );
    Navigator.of(context).pop();
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
    final budgetsRepo = ref.read(budgetsRepositoryProvider);
    final measurementsRepo = ref.read(measurementsRepositoryProvider);

    final client = await clientsRepo.getById(data.budget.clientId);
    if (client == null) return;
    final professional = await profileRepo.getProfile();
    final budgetNumber = await budgetsRepo.getBudgetNumber(data.budget.id);
    
    Project? project;
    if (data.budget.projectId != null) {
      final projects = await measurementsRepo.watchProjectsByClient(data.budget.clientId).first;
      project = projects.where((p) => p.id == data.budget.projectId).firstOrNull;
    }

    final bool shared;
    try {
      shared = format == BudgetShareFormat.pdf
          ? await BudgetShareService.shareAsPdf(
              data: data,
              client: client,
              professional: professional,
              budgetNumber: budgetNumber,
              project: project,
            )
          : await BudgetShareService.shareAsImage(
              data: data,
              client: client,
              professional: professional,
              budgetNumber: budgetNumber,
              project: project,
            );
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          'Não consegui gerar ou compartilhar o orçamento. Tente novamente.',
          variant: AppSnackBarVariant.destructive,
        );
      }
      return;
    }

    // Folha de compartilhamento descartada: nada foi enviado — manter o
    // status atual e não contar no funil (ver auditoria P1).
    if (!shared) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          'Compartilhamento cancelado.',
          variant: AppSnackBarVariant.warning,
        );
      }
      return;
    }

    final formatParam = format == BudgetShareFormat.pdf ? 'pdf' : 'imagem';
    AnalyticsService.trackEvent('pdf_generated', {'format': formatParam});
    // `channel` é sempre 'outro': a folha de compartilhamento do sistema
    // (share_plus) não informa qual app o usuário escolheu — inventar
    // 'whatsapp' aqui seria dado falso no funil (ver APP_FACTORY_RULES.md §7).
    AnalyticsService.trackEvent('budget_shared', {
      'format': formatParam,
      'channel': 'outro',
    });
    // Momento de sucesso: acabou de compartilhar um orçamento de verdade.
    unawaited(ReviewService.requestReviewIfAvailable());

    if (data.budget.status == BudgetStatus.draft) {
      final repo = ref.read(budgetsRepositoryProvider);
      await repo.updateStatus(_budgetId!, BudgetStatus.sent);
    }
    // Sem isso, enviar pelo form deixava a Home (aguardando/aprovados)
    // desatualizada até o app reiniciar — o wizard já avisava, aqui não
    // (ver auditoria P2).
    ref.read(homeRefreshProvider.notifier).bump();
  }

  @override
  Widget build(BuildContext context) {
    if (_budgetId == null) {
      return const Scaffold(body: AppLoading());
    }

    final repo = ref.watch(budgetsRepositoryProvider);

    return StreamBuilder<BudgetWithItems?>(
      stream: repo.watchById(_budgetId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Orçamento')),
            body: const AppError(message: 'Falha ao carregar orçamento.'),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Orçamento')),
            body: const AppLoading(),
          );
        }
        final data = snapshot.data!;
        final budget = data.budget;
        final totals = data.totals;

        return Scaffold(
          appBar: AppBar(
            // O número unifica com a lista e com o wizard: mesmo documento
            // reconhecível mesmo mudando de tela.
            title: Text(_budgetNumberLabel ?? 'Orçamento'),
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
              PopupMenuButton<String>(
                tooltip: 'Mais ações',
                onSelected: (value) {
                  switch (value) {
                    case 'duplicate':
                      _duplicateBudget(context);
                    case 'save_template':
                      _saveAsTemplate(context, data);
                    case 'delete':
                      _deleteBudget(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: ListTile(
                      leading: Icon(Icons.copy_outlined),
                      title: Text('Duplicar orçamento'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'save_template',
                    child: ListTile(
                      leading: Icon(Icons.bookmark_add_outlined),
                      title: Text('Salvar como modelo'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      title: Text(
                        'Excluir orçamento',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: data.items.isEmpty
                    ? const Center(
                        child: Text('Toque em + para adicionar itens.'),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        children: [
                          for (final item in data.items) ...[
                            AppCard(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.description),
                                        Text(
                                          '${formatQuantity(item.quantity)} ${serviceUnitLabel(item.unit)} × ${formatCents(item.unitPriceCents)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    formatCents(item.totalCents),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium,
                                  ),
                                  IconButton(
                                    onPressed: () => _removeItem(item),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          if (data.payments.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Pagamentos recebidos',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            for (final payment in data.payments) ...[
                              AppCard(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            formatCents(payment.amountCents),
                                          ),
                                          Text(
                                            [
                                              '${payment.createdAt.day}/${payment.createdAt.month}/${payment.createdAt.year}',
                                              if (payment.notes != null &&
                                                  payment.notes!.isNotEmpty)
                                                payment.notes!,
                                            ].join(' · '),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _emitReceipt(context, data, payment),
                                      icon: const Icon(
                                        Icons.receipt_long_outlined,
                                        size: 20,
                                      ),
                                      tooltip: 'Emitir recibo deste pagamento',
                                    ),
                                    IconButton(
                                      onPressed: () => _removePayment(payment),
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                            ],
                          ],
                        ],
                      ),
              ),
              Container(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Resumo Financeiro',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                formatCents(totals.subtotalCents),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Desconto',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(color: context.semanticColors.success),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  IconButton(
                                    onPressed: () => _editDiscount(
                                      budget.discountCents,
                                      totals.subtotalCents,
                                    ),
                                    icon: const Icon(Icons.edit_outlined, size: 16),
                                    iconSize: 16,
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Editar desconto',
                                  ),
                                ],
                              ),
                              Text(
                                '- ${formatCents(totals.discountCents)}',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: context.semanticColors.success),
                              ),
                            ],
                          ),
                          const Divider(height: AppSpacing.md * 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                formatCents(totals.totalCents),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (data.items.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pagamento',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: data.pendingCents > 0
                                        ? Theme.of(context).colorScheme.errorContainer
                                        : Theme.of(context).colorScheme.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    data.pendingCents > 0 ? 'Pendente' : 'Pago',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: data.pendingCents > 0
                                          ? Theme.of(context).colorScheme.onErrorContainer
                                          : Theme.of(context).colorScheme.onTertiaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                                children: [
                                  const TextSpan(text: 'Restante a pagar: '),
                                  TextSpan(
                                    text: formatCents(data.pendingCents),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppButton(
                              label: 'Registrar Pagamento',
                              onPressed: () => _registerPayment(context),
                              icon: Icons.payments,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    if (budget.validUntil != null) ...[
                      Text(
                        'Válido até ${budget.validUntil!.day.toString().padLeft(2, '0')}/'
                        '${budget.validUntil!.month.toString().padLeft(2, '0')}/'
                        '${budget.validUntil!.year}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Row(
                      children: [
                        Text(
                          'Status:',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          statusLabel(budget.status),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (budget.status == BudgetStatus.draft ||
                        budget.status == BudgetStatus.sent) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: budget.status == BudgetStatus.draft
                                  ? 'Marcar como enviado'
                                  : 'Marcar como aceito',
                              onPressed: () => _advanceStatus(budget.status),
                              variant: AppButtonVariant.secondary,
                            ),
                          ),
                          if (budget.status == BudgetStatus.sent) ...[
                            const SizedBox(width: AppSpacing.sm),
                            IconButton(
                              onPressed: _declineStatus,
                              icon: const Icon(Icons.close),
                              tooltip: 'Marcar como recusado',
                            ),
                          ],
                        ],
                      ),
                    ],
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
