import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/database.dart';
import '../repositories/budgets_repository.dart';
import '../repositories/profile_repository.dart';
import 'budget_pdf_content.dart';

/// Gera o PDF de um orçamento — o produto que chega ao cliente final (ver
/// CLAUDE.md, "Golden test do PDF": quebra de layout é quebra de
/// reputação do usuário). O texto exibido vem de [BudgetPdfContent]
/// (testável sem renderizar/rasterizar nada); esta classe só monta a
/// aparência visual em cima desse conteúdo. O rodapé "Feito com Obrion"
/// é canal de aquisição projetado, não marca d'água acidental.
class BudgetPdfGenerator {
  const BudgetPdfGenerator._();

  static Future<pw.Document> generate({
    required BudgetWithItems data,
    required Client client,
    required ProfessionalProfile professional,
    int? budgetNumber,
  }) async {
    final doc = pw.Document();
    final content = BudgetPdfContent.fromData(
      data: data,
      client: client,
      professional: professional,
      budgetNumber: budgetNumber,
    );
    final logo = await _loadLogo(professional.logoPath);

    doc.addPage(
      pw.MultiPage(
        // Pinta o fundo da página de branco explicitamente — sem isso a
        // página fica transparente, e o PNG gerado por "compartilhar como
        // imagem" (Printing.raster) herda essa transparência. No WhatsApp
        // com tema escuro isso vira um fundo preto atrás de texto preto:
        // o cabeçalho da tabela ainda aparecia (tem fundo cinza próprio),
        // mas as linhas de item ficavam invisíveis.
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: PdfColors.white),
          ),
        ),
        header: (context) => _buildHeader(content, logo),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 16),
          _buildClientInfo(content),
          if (content.jobDescription != null) ...[
            pw.SizedBox(height: 16),
            pw.Text('Projeto / Obra', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(content.jobDescription!),
          ],
          pw.SizedBox(height: 24),
          _buildItemsTable(content.items),
          pw.SizedBox(height: 16),
          _buildTotals(content),
          if (content.notes != null) ...[
            pw.SizedBox(height: 24),
            pw.Text('Observações', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text(content.notes!),
          ],
          pw.SizedBox(height: 40),
          _buildSignatures(content),
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

  static pw.Widget _buildHeader(BudgetPdfContent content, pw.MemoryImage? logo) {
    // Linha de contato: telefone · email, ou só um deles.
    final contactParts = [
      if (content.professionalPhone != null) content.professionalPhone!,
      if (content.professionalEmail != null) content.professionalEmail!,
    ];
    final contactLine = contactParts.isEmpty ? null : contactParts.join(' · ');

    final budgetTitle = content.budgetNumber != null
        ? 'Orçamento nº ${content.budgetNumber}'
        : 'Orçamento';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logo != null) ...[
              pw.Container(height: 48, width: 48, child: pw.Image(logo, fit: pw.BoxFit.contain)),
              pw.SizedBox(width: 12),
            ],
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    content.professionalName,
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                  if (contactLine != null)
                    pw.Text(contactLine, style: const pw.TextStyle(fontSize: 10)),
                  if (content.professionalDocument != null)
                    pw.Text(content.professionalDocument!, style: const pw.TextStyle(fontSize: 10)),
                  if (content.professionalAddress != null)
                    pw.Text(content.professionalAddress!, style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.Text(
              budgetTitle,
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
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

  static pw.Widget _buildClientInfo(BudgetPdfContent content) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Cliente', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(content.clientName),
            if (content.clientDocument != null) pw.Text('CPF/CNPJ: ${content.clientDocument}'),
            if (content.clientPhone != null) pw.Text(content.clientPhone!),
            if (content.clientAddress != null) pw.Text(content.clientAddress!),
          ],
        ),
        pw.Text('Data: ${content.dateFormatted}'),
      ],
    );
  }

  static pw.Widget _buildItemsTable(List<BudgetPdfItemLine> items) {
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
              _cell(item.quantityAndUnit, align: pw.TextAlign.right),
              _cell(item.unitPriceFormatted, align: pw.TextAlign.right),
              _cell(item.totalFormatted, align: pw.TextAlign.right),
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

  /// Duas linhas de assinatura (profissional + contratante), sem CPF/CNPJ
  /// — Obrion não guarda esse dado hoje, fica pra outra frente. Transforma
  /// o orçamento num mini-contrato (ver
  /// docs/ANALISE_CONCORRENCIA_E_ESCOPO.md, Parte 5, item 9). **Não
  /// confundir** com assinatura digital ICP-Brasil: é só uma linha em
  /// branco pra assinar à mão, sem validade jurídica de assinatura
  /// eletrônica qualificada.
  static pw.Widget _buildSignatures(BudgetPdfContent content) {
    return pw.Row(
      children: [
        pw.Expanded(child: _buildSignatureLine(content.professionalName)),
        pw.SizedBox(width: 32),
        pw.Expanded(
          child: _buildSignatureLine(
            content.clientName,
            label: 'Contratante',
            document: content.clientDocument,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSignatureLine(String name, {String? label, String? document}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(height: 1, color: PdfColors.grey600),
        pw.SizedBox(height: 4),
        pw.Text(name, style: const pw.TextStyle(fontSize: 10)),
        if (label != null)
          pw.Text(label, style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        if (document != null)
          pw.Text('CPF/CNPJ: $document', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 8),
        pw.Text('Data: ___/___/___', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
      ],
    );
  }

  static pw.Widget _buildTotals(BudgetPdfContent content) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('Subtotal: '),
            pw.Text(content.subtotalFormatted),
          ],
        ),
        if (content.discountFormatted != null)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Desconto: '),
              pw.Text('- ${content.discountFormatted}'),
            ],
          ),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('Total: ', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.Text(
              content.totalFormatted,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}
