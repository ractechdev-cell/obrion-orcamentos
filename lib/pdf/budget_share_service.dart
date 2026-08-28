import 'dart:typed_data';

import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database.dart';
import '../repositories/budgets_repository.dart';
import '../repositories/profile_repository.dart';
import 'budget_pdf_generator.dart';
import 'receipt_pdf_generator.dart';

/// Formato de compartilhamento do orçamento — usado também como parâmetro
/// do evento de analytics `pdf_generated` (ver CLAUDE.md).
enum BudgetShareFormat { pdf, image }

/// Compartilhamento do orçamento via folha do sistema, em PDF ou como
/// imagem (ver CLAUDE.md, nota sobre WhatsApp: `wa.me` não anexa arquivo
/// — o usuário escolhe o app/contato na folha de compartilhamento nativa;
/// e nota P4 da análise: muitos clientes finais abrem imagem no WhatsApp
/// e ignoram PDF).
class BudgetShareService {
  const BudgetShareService._();

  static Future<void> shareAsPdf({
    required BudgetWithItems data,
    required Client client,
    required ProfessionalProfile professional,
    int? budgetNumber,
    Project? project,
  }) async {
    final bytes = await _generateBytes(
      data: data,
      client: client,
      professional: professional,
      budgetNumber: budgetNumber,
      project: project,
    );

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'application/pdf', name: 'orcamento.pdf'),
        ],
        fileNameOverrides: ['orcamento.pdf'],
        text: 'Segue o orçamento em anexo.',
      ),
    );
  }

  /// Compartilha a primeira página do orçamento como PNG — pensado pra
  /// quem abre imagem no WhatsApp sem pensar e ignora anexo em PDF.
  static Future<void> shareAsImage({
    required BudgetWithItems data,
    required Client client,
    required ProfessionalProfile professional,
    int? budgetNumber,
    Project? project,
  }) async {
    final bytes = await _generateBytes(
      data: data,
      client: client,
      professional: professional,
      budgetNumber: budgetNumber,
      project: project,
    );

    final pages = Printing.raster(bytes, pages: [0], dpi: 150);
    final firstPage = await pages.first;
    final png = await firstPage.toPng();

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(png, mimeType: 'image/png', name: 'orcamento.png'),
        ],
        fileNameOverrides: ['orcamento.png'],
        text: 'Segue o orçamento em anexo.',
      ),
    );
  }

  /// Recibo do valor recebido até agora — reaproveita [ReceiptPdfGenerator]
  /// (motor reduzido do orçamento) e o mesmo mecanismo de compartilhamento
  /// via folha do sistema.
  static Future<void> shareReceipt({
    required Client client,
    required ProfessionalProfile professional,
    required int amountCents,
    required DateTime date,
    String? note,
  }) async {
    final doc = await ReceiptPdfGenerator.generate(
      client: client,
      professional: professional,
      amountCents: amountCents,
      date: date,
      note: note,
    );
    final bytes = await doc.save();

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(bytes, mimeType: 'application/pdf', name: 'recibo.pdf'),
        ],
        fileNameOverrides: ['recibo.pdf'],
        text: 'Segue o recibo em anexo.',
      ),
    );
  }

  static Future<Uint8List> _generateBytes({
    required BudgetWithItems data,
    required Client client,
    required ProfessionalProfile professional,
    int? budgetNumber,
    Project? project,
  }) async {
    final doc = await BudgetPdfGenerator.generate(
      data: data,
      client: client,
      professional: professional,
      budgetNumber: budgetNumber,
      project: project,
    );
    return doc.save();
  }
}
