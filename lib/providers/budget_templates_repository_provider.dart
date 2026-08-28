import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/budget_templates_repository.dart';
import 'database_provider.dart';

final budgetTemplatesRepositoryProvider = Provider<BudgetTemplatesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BudgetTemplatesRepository(db);
});
