import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/profile_repository.dart';
import 'database_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProfileRepository(db);
});
