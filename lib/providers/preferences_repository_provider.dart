import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/preferences_repository.dart';
import 'database_provider.dart';

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PreferencesRepository(db);
});
