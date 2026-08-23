import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/payments_repository.dart';
import 'database_provider.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PaymentsRepository(db);
});
