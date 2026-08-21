import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/clients_repository.dart';
import 'database_provider.dart';

final clientsRepositoryProvider = Provider<ClientsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ClientsRepository(db);
});
