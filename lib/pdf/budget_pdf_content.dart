import '../database/database.dart';
import '../repositories/budgets_repository.dart';
import '../repositories/profile_repository.dart';
import '../screens/service_unit_label.dart';
import '../utils/currency_format.dart';

/// Formata centavos como "R$ 1.234,56". Formatação para R$ só na borda de
/// apresentação — o dado continua `int` centavos até aqui (ver CLAUDE.md).
String formatCurrencyForPdf(int cents) => formatCurrencyBrl(cents);

String formatDateForPdf(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

/// Uma linha da tabela de itens, já formatada para exibição.
class BudgetPdfItemLine {
  const BudgetPdfItemLine({
    required this.description,
    required this.quantityAndUnit,
    required this.unitPriceFormatted,
    required this.totalFormatted,
  });

  final String description;
  final String quantityAndUnit;
  final String unitPriceFormatted;
  final String totalFormatted;
}

/// Todo o texto que aparece no PDF do orçamento, já formatado — separado
/// da montagem visual (`BudgetPdfGenerator`) para poder testar "a
/// informação certa está indo pro PDF" sem depender de renderizar/
/// rasterizar nada (ver CLAUDE.md, "Golden test do PDF": rasterização real
/// só funciona com host de plataforma — dispositivo/emulador via
/// `integration_test` —, não no `flutter test` comum).
class BudgetPdfContent {
  const BudgetPdfContent({
    required this.professionalName,
    required this.professionalPhone,
    required this.professionalDocument,
    required this.clientName,
    required this.clientPhone,
    required this.clientAddress,
    required this.clientDocument,
    required this.dateFormatted,
    required this.items,
    required this.subtotalFormatted,
    required this.discountFormatted,
    required this.totalFormatted,
    required this.notes,
    required this.jobDescription,
  });

  factory BudgetPdfContent.fromData({
    required BudgetWithItems data,
    required Client client,
    required ProfessionalProfile professional,
  }) {
    final totals = data.totals;
    return BudgetPdfContent(
      professionalName: (professional.name?.isNotEmpty ?? false) ? professional.name! : 'Orçamento',
      professionalPhone: professional.phone?.isNotEmpty ?? false ? professional.phone : null,
      professionalDocument: professional.document?.isNotEmpty ?? false ? professional.document : null,
      clientName: client.name,
      clientPhone: client.phone?.isNotEmpty ?? false ? client.phone : null,
      clientAddress: client.address?.isNotEmpty ?? false ? client.address : null,
      clientDocument: client.document?.isNotEmpty ?? false ? client.document : null,
      dateFormatted: formatDateForPdf(data.budget.createdAt),
      items: [
        for (final item in data.items)
          BudgetPdfItemLine(
            description: item.description,
            quantityAndUnit: '${item.quantity} ${serviceUnitLabel(item.unit)}',
            unitPriceFormatted: formatCurrencyForPdf(item.unitPriceCents),
            totalFormatted: formatCurrencyForPdf(item.totalCents),
          ),
      ],
      subtotalFormatted: formatCurrencyForPdf(totals.subtotalCents),
      discountFormatted: totals.discountCents > 0 ? formatCurrencyForPdf(totals.discountCents) : null,
      totalFormatted: formatCurrencyForPdf(totals.totalCents),
      notes: (data.budget.notes?.isNotEmpty ?? false) ? data.budget.notes : null,
      jobDescription:
          (data.budget.jobDescription?.isNotEmpty ?? false) ? data.budget.jobDescription : null,
    );
  }

  final String professionalName;
  final String? professionalPhone;
  final String? professionalDocument;
  final String clientName;
  final String? clientPhone;
  final String? clientAddress;
  final String? clientDocument;
  final String dateFormatted;
  final List<BudgetPdfItemLine> items;
  final String subtotalFormatted;
  final String? discountFormatted;
  final String totalFormatted;
  final String? notes;
  final String? jobDescription;
}
