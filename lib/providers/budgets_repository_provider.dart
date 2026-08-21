import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/budgets_repository.dart';
import 'database_provider.dart';

final budgetsRepositoryProvider = Provider<BudgetsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BudgetsRepository(db);
});
