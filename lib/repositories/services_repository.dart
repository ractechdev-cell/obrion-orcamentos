import 'package:drift/drift.dart';
import '../database/database.dart';
import '../database/enums.dart';

/// Repositório de Serviços (Lista de Preços) — camada de acesso a dados.
/// Permite o CRUD local para a lista de preços do profissional.
class ServicesRepository {
  ServicesRepository(this._db);

  final AppDatabase _db;

  /// Retorna Stream ativa de todos os serviços (não deletados) ordenados por nome.
  Stream<List<Service>> watchAll() {
    return (_db.select(_db.services)
          ..where((s) => s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .watch();
  }

  /// Busca um serviço pelo ID.
  Future<Service?> getById(String id) {
    return (_db.select(_db.services)..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// Cria um novo serviço na lista de preços.
  Future<Service> create({
    required String name,
    required ServiceUnit unit,
    int? defaultPriceCents,
    bool includesMaterial = false,
    String? defaultNote,
  }) {
    final now = DateTime.now();
    return _db.into(_db.services).insertReturning(
          ServicesCompanion.insert(
            name: name,
            unit: unit,
            defaultPriceCents: Value(defaultPriceCents),
            includesMaterial: Value(includesMaterial),
            defaultNote: Value(defaultNote),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  /// Atualiza as propriedades de um serviço.
  /// Cada campo usa `Value<T>` (não `T?` cru) para distinguir "não mexer
  /// neste campo" de "limpar o campo" (`Value(null)`) — ver mesma nota em
  /// `ClientsRepository.update`.
  Future<bool> update({
    required String id,
    Value<String> name = const Value.absent(),
    Value<ServiceUnit> unit = const Value.absent(),
    Value<int?> defaultPriceCents = const Value.absent(),
    Value<bool> includesMaterial = const Value.absent(),
    Value<String?> defaultNote = const Value.absent(),
  }) async {
    final now = DateTime.now();
    final companion = ServicesCompanion(
      name: name,
      unit: unit,
      defaultPriceCents: defaultPriceCents,
      includesMaterial: includesMaterial,
      defaultNote: defaultNote,
      updatedAt: Value(now),
    );
    final count = await (_db.update(_db.services)..where((s) => s.id.equals(id))).write(companion);
    return count > 0;
  }

  /// Exclusão lógica (soft delete).
  Future<bool> softDelete(String id) async {
    final count = await (_db.update(_db.services)..where((s) => s.id.equals(id)))
        .write(ServicesCompanion(deletedAt: Value(DateTime.now())));
    return count > 0;
  }

  /// Reajusta em massa o preço padrão de todos os serviços com preço já
  /// definido — ver docs/POSICIONAMENTO_E_FEATURES_APP1.md, Parte 4, item
  /// 4 ("material subiu → um botão atualiza a lista toda"). Serviços com
  /// preço em branco ficam intocados (continuam sem sugerir valor — ver
  /// CLAUDE.md, "nunca sugerir preço"). Mesmo arredondamento meio-pra-cima
  /// usado em `budget_calculations.dart`.
  Future<void> bulkAdjustPrices(double percent) async {
    final services = await (_db.select(_db.services)..where((s) => s.deletedAt.isNull())).get();
    final now = DateTime.now();
    final toAdjust = services.where((s) => s.defaultPriceCents != null).toList();
    if (toAdjust.isEmpty) return;

    await _db.batch((batch) {
      for (final service in toAdjust) {
        final adjusted = (service.defaultPriceCents! * (1 + percent / 100)).round();
        batch.update(
          _db.services,
          ServicesCompanion(
            defaultPriceCents: Value(adjusted),
            updatedAt: Value(now),
          ),
          where: (s) => s.id.equals(service.id),
        );
      }
    });
  }

  /// Busca serviços contendo o termo no nome.
  Future<List<Service>> search(String query) {
    final term = '%$query%';
    return (_db.select(_db.services)
          ..where((s) => s.deletedAt.isNull() & s.name.like(term))
          ..orderBy([(s) => OrderingTerm.asc(s.name)]))
        .get();
  }

  /// Pre-popula a tabela de serviços com sugestões iniciais com preço em branco (nulo)
  /// de acordo com a regra de negócio do Obrion MVP (ver CLAUDE.md).
  /// Só insere o que ainda não existe, para não duplicar se o usuário tocar
  /// no botão mais de uma vez.
  ///
  /// [trades] filtra a lista pelo(s) ofício(s) do perfil — ver
  /// docs/POSICIONAMENTO_E_FEATURES_APP1.md, "camada de ofício": antes o
  /// botão despejava os 23 serviços de todos os ofícios juntos, mesmo pra
  /// quem só faz um. Vazio (perfil sem ofício informado) mantém o
  /// comportamento antigo — insere tudo, nunca deixa o botão sem efeito.
  Future<void> populateDefaultServices({Set<Trade> trades = const {}}) async {
    final now = DateTime.now();
    final existingNames = (await (_db.select(_db.services)
          ..where((s) => s.deletedAt.isNull())
          ..addColumns([_db.services.name]))
        .get())
        .map((row) => row.name)
        .toSet();

    final allDefaults = [
      _def('Alvenaria de bloco', ServiceUnit.squareMeter, Trade.mason),
      _def('Reboco de parede', ServiceUnit.squareMeter, Trade.mason),
      _def('Chapisco', ServiceUnit.squareMeter, Trade.mason),
      _def('Contrapiso', ServiceUnit.squareMeter, Trade.mason),
      _def('Demolição', ServiceUnit.squareMeter, Trade.mason),
      _def('Pintura acrílica (2 demãos)', ServiceUnit.squareMeter, Trade.painter),
      _def('Aplicação de massa corrida', ServiceUnit.squareMeter, Trade.painter),
      _def('Pintura de portas (madeira)', ServiceUnit.unit, Trade.painter),
      _def('Forro de gesso plaquinha', ServiceUnit.squareMeter, Trade.plasterer),
      _def('Forro de gesso acartonado (drywall)', ServiceUnit.squareMeter, Trade.plasterer),
      _def('Moldura de gesso', ServiceUnit.linearMeter, Trade.plasterer),
      _def('Assentamento de piso cerâmico', ServiceUnit.squareMeter, Trade.tiler),
      _def('Assentamento de porcelanato', ServiceUnit.squareMeter, Trade.tiler),
      _def('Assentamento de revestimento de parede', ServiceUnit.squareMeter, Trade.tiler),
      _def('Instalação de rodapé', ServiceUnit.linearMeter, Trade.tiler),
      _def('Instalação de ponto elétrico', ServiceUnit.point, Trade.electrician),
      _def('Passagem de cabo elétrico', ServiceUnit.linearMeter, Trade.electrician),
      _def('Instalação de luminária/spot', ServiceUnit.unit, Trade.electrician),
      _def('Instalação de padrão de entrada', ServiceUnit.lumpSum, Trade.electrician),
      _def('Ponto de água fria/quente', ServiceUnit.point, Trade.plumber),
      _def('Ponto de esgoto', ServiceUnit.point, Trade.plumber),
      _def('Instalação de bacia sanitária', ServiceUnit.unit, Trade.plumber),
      _def('Instalação de torneira/misturador', ServiceUnit.unit, Trade.plumber),
    ];

    final defaults =
        trades.isEmpty ? allDefaults : allDefaults.where((d) => trades.contains(d.trade)).toList();
    final missing = defaults.where((d) => !existingNames.contains(d.name)).toList();
    if (missing.isEmpty) return;

    await _db.batch((batch) {
      batch.insertAll(
        _db.services,
        missing.map((d) => ServicesCompanion.insert(
              name: d.name,
              unit: d.unit,
              defaultPriceCents: const Value(null),
              includesMaterial: const Value(false),
              createdAt: Value(now),
              updatedAt: Value(now),
            )),
      );
    });
  }

  _DefaultService _def(String name, ServiceUnit unit, Trade trade) =>
      _DefaultService(name, unit, trade);
}

class _DefaultService {
  _DefaultService(this.name, this.unit, this.trade);
  final String name;
  final ServiceUnit unit;
  final Trade trade;
}
