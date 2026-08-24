import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/database/enums.dart';
import 'package:orcamentos/repositories/profile_repository.dart';

void main() {
  late AppDatabase database;
  late ProfileRepository repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = ProfileRepository(database);
  });

  tearDown(() => database.close());

  test('getProfile returns empty trades before anything is saved', () async {
    final profile = await repository.getProfile();
    expect(profile.trades, isEmpty);
  });

  test('saveProfile persists multiple trades and getProfile round-trips them', () async {
    await repository.saveProfile(trades: {Trade.painter, Trade.mason});

    final profile = await repository.getProfile();
    expect(profile.trades, {Trade.painter, Trade.mason});
  });

  test('saveProfile without trades does not erase a previously saved selection', () async {
    await repository.saveProfile(trades: {Trade.electrician});
    await repository.saveProfile(name: 'João');

    final profile = await repository.getProfile();
    expect(profile.trades, {Trade.electrician});
    expect(profile.name, 'João');
  });
}
