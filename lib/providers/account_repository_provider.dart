import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/account_repository.dart';
import 'database_provider.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AccountRepository(db);
});
