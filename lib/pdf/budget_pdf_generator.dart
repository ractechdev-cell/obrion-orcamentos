import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/database.dart';
import '../repositories/budgets_repository.dart';
import '../repositories/profile_repository.dart';
import '../screens/service_unit_label.dart';

/// Formata centavos como "R$ 1.234,56". Formatação para R$ só na borda de
/// apresentação — o dado continua `int` centavos até aqui (ver CLAUDE.md).
String _formatCurrency(int cents) {
  final reais = cents ~/ 100;
  final centavos = (cents % 100).abs().toString().padLeft(2, '0');
  final reaisFormatted = reais.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );
  return 'R\$ $reaisFormatted,$centavos';
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

/// Gera o PDF de um orçamento — o produto que chega ao cliente final (ver
/// CLAUDE.md, "Golden test do PDF": quebra de layout é quebra de
/// reputação do usuário). O rodapé "Feito com Obrion" é canal de
/// aquisição projetado, não marca d'água acidental.
class BudgetPdfGenerator {
  const BudgetPdfGenerator._();

  static Future<pw.Document> generate({
    required BudgetWithItems data,
    required Client client,
    required ProfessionalProfile professional,
  }) async {
    final doc = pw.Document();
    final totals = data.totals;
    final logo = await _loadLogo(professional.logoPath);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(professional, logo),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 16),
          _buildClientInfo(client, data.budget.createdAt),
          pw.SizedBox(height: 24),
          _buildItemsTable(data.items),
          pw.SizedBox(height: 16),
          _buildTotals(totals.subtotalCents, totals.discountCents, totals.totalCents),
          if (data.budget.notes != null && data.budget.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            pw.Text('Observações', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(data.budget.notes!),
          ],
        ],
      ),
    );

    return doc;
  }

  /// Lê a logo do disco, se o profissional tiver uma configurada. Falha
  /// silenciosamente (retorna null) se o arquivo não existir mais —
  /// o PDF nunca pode travar por causa de um asset opcional.
  static Future<pw.MemoryImage?> _loadLogo(String? logoPath) async {
    if (logoPath == null || logoPath.isEmpty) return null;
    final file = File(logoPath);
    if (!await file.exists()) return null;
    return pw.MemoryImage(await file.readAsBytes());
  }

  static pw.Widget _buildHeader(ProfessionalProfile professional, pw.MemoryImage? logo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logo != null) ...[
              pw.Container(height: 40, width: 40, child: pw.Image(logo, fit: pw.BoxFit.contain)),
              pw.SizedBox(width: 12),
            ],
            pw.Text(
              (professional.name?.isNotEmpty ?? false) ? professional.name! : 'Orçamento',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        if (professional.phone?.isNotEmpty ?? false)
          pw.Text(professional.phone!, style: const pw.TextStyle(fontSize: 11)),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    return pw.Column(
      children: [
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Feito com Obrion — obrion.app',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildClientInfo(Client client, DateTime createdAt) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Cliente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(client.name),
            if (client.phone?.isNotEmpty ?? false) pw.Text(client.phone!),
            if (client.address?.isNotEmpty ?? false) pw.Text(client.address!),
          ],
        ),
        pw.Text('Data: ${_formatDate(createdAt)}'),
      ],
    );
  }

  static pw.Widget _buildItemsTable(List<BudgetItem> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1.5),
        3: pw.FlexColumnWidth(1.5),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cell('Descrição', bold: true),
            _cell('Qtd.', bold: true, align: pw.TextAlign.right),
            _cell('Preço unit.', bold: true, align: pw.TextAlign.right),
            _cell('Total', bold: true, align: pw.TextAlign.right),
          ],
        ),
        for (final item in items)
          pw.TableRow(
            children: [
              _cell(item.description),
              _cell('${item.quantity} ${serviceUnitLabel(item.unit)}', align: pw.TextAlign.right),
              _cell(_formatCurrency(item.unitPriceCents), align: pw.TextAlign.right),
              _cell(_formatCurrency(item.totalCents), align: pw.TextAlign.right),
            ],
          ),
      ],
    );
  }

  static pw.Widget _cell(String text, {bool bold = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );
  }

  static pw.Widget _buildTotals(int subtotalCents, int discountCents, int totalCents) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('Subtotal: '),
            pw.Text(_formatCurrency(subtotalCents)),
          ],
        ),
        if (discountCents > 0)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Desconto: '),
              pw.Text('- ${_formatCurrency(discountCents)}'),
            ],
          ),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('Total: ', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text(
              _formatCurrency(totalCents),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
