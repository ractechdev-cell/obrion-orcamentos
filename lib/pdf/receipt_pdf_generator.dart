import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/database.dart';
import '../repositories/profile_repository.dart';
import 'budget_pdf_content.dart';

/// Gera o recibo de um orçamento — motor de PDF reduzido em relação a
/// [BudgetPdfGenerator]: cabeçalho, cliente, valor recebido e data, sem a
/// tabela de itens completa (ver docs/POSICIONAMENTO_E_FEATURES_APP1.md,
/// Parte 4, item 10 — "mesmo motor de PDF, casa com a tabela `payments`
/// que já está construída"). Reaproveita os mesmos formatadores de
/// `budget_pdf_content.dart` (nunca duplica a regra de formatação de
/// moeda/data) e a mesma correção de fundo branco explícito do gerador de
/// orçamento (sem isso, "compartilhar como imagem" sai transparente).
class ReceiptPdfGenerator {
  const ReceiptPdfGenerator._();

  static Future<pw.Document> generate({
    required Client client,
    required ProfessionalProfile professional,
    required int amountCents,
    required DateTime date,
    String? note,
  }) async {
    final doc = pw.Document();
    final professionalName =
        (professional.name?.isNotEmpty ?? false) ? professional.name! : 'Recibo';

    doc.addPage(
      pw.Page(
        // Mesma correção de fundo branco explícito do orçamento (ver
        // `BudgetPdfGenerator.generate`) — sem isso a página sai
        // transparente, e "compartilhar como imagem" vira fundo preto
        // atrás de texto preto em apps com tema escuro (ex.: WhatsApp).
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: PdfColors.white),
          ),
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(professionalName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            if ((professional.phone?.isNotEmpty ?? false) || (professional.email?.isNotEmpty ?? false))
              pw.Text(
                [
                  if (professional.phone?.isNotEmpty ?? false) professional.phone!,
                  if (professional.email?.isNotEmpty ?? false) professional.email!,
                ].join(' · '),
                style: const pw.TextStyle(fontSize: 10),
              ),
            if (professional.document?.isNotEmpty ?? false)
              pw.Text(professional.document!, style: const pw.TextStyle(fontSize: 10)),
            if (professional.address?.isNotEmpty ?? false)
              pw.Text(professional.address!, style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.SizedBox(height: 24),
            pw.Text('Recibo', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Text('Recebi de ${client.name} a quantia de:'),
            if (client.document?.isNotEmpty ?? false)
              pw.Text('CPF/CNPJ: ${client.document}', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 8),
            pw.Text(
              formatCurrencyForPdf(amountCents),
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            if (note != null && note.isNotEmpty) ...[
              pw.Text(note),
              pw.SizedBox(height: 16),
            ],
            pw.Text('Data: ${formatDateForPdf(date)}'),
            pw.SizedBox(height: 40),
            pw.Container(width: 220, height: 1, color: PdfColors.grey600),
            pw.SizedBox(height: 4),
            pw.Text(professionalName, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );

    return doc;
  }
}
