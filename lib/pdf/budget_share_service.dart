import 'package:share_plus/share_plus.dart';

import '../database/database.dart';
import '../repositories/budgets_repository.dart';
import '../repositories/profile_repository.dart';
import 'budget_pdf_generator.dart';

/// Compartilhamento do orçamento em PDF via folha do sistema (ver
/// CLAUDE.md, nota sobre WhatsApp: `wa.me` não anexa arquivo — o usuário
/// escolhe o app/contato na folha de compartilhamento nativa).
class BudgetShareService {
  const BudgetShareService._();

  static Future<void> shareAsPdf({
    required BudgetWithItems data,
    required Client client,
    required ProfessionalProfile professional,
  }) async {
    final doc = await BudgetPdfGenerator.generate(
      data: data,
      client: client,
      professional: professional,
    );
    final bytes = await doc.save();

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
}
