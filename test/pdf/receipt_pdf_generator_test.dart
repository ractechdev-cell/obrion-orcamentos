import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/pdf/receipt_pdf_generator.dart';
import 'package:orcamentos/repositories/clients_repository.dart';
import 'package:orcamentos/repositories/profile_repository.dart';

void main() {
  test('generates non-empty PDF bytes for a receipt', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final clientsRepo = ClientsRepository(database);
    final client = await clientsRepo.create(name: 'Cliente Teste', phone: '11999999999');

    final doc = await ReceiptPdfGenerator.generate(
      client: client,
      professional: const ProfessionalProfile(name: 'Fulano', phone: '11888888888'),
      amountCents: 43750,
      date: DateTime(2026, 8, 24),
      note: 'Reforma da cozinha.',
    );

    final bytes = await doc.save();
    expect(bytes, isNotEmpty);
  });

  test('generates a receipt even without a note', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final clientsRepo = ClientsRepository(database);
    final client = await clientsRepo.create(name: 'Cliente Teste');

    final doc = await ReceiptPdfGenerator.generate(
      client: client,
      professional: const ProfessionalProfile(),
      amountCents: 10000,
      date: DateTime(2026, 8, 24),
    );

    final bytes = await doc.save();
    expect(bytes, isNotEmpty);
  });
}
