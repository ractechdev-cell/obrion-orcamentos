import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/measurements_repository.dart';
import 'database_provider.dart';

final measurementsRepositoryProvider = Provider<MeasurementsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return MeasurementsRepository(db);
});
