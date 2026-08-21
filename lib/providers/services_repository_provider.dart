import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/services_repository.dart';
import 'database_provider.dart';

final servicesRepositoryProvider = Provider<ServicesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ServicesRepository(db);
});

final servicesStreamProvider = StreamProvider((ref) {
  final repo = ref.watch(servicesRepositoryProvider);
  return repo.watchAll();
});
