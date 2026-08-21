import 'package:drift/drift.dart';

import '../enums.dart';
import 'entity_mixin.dart';
import 'projects_table.dart';

/// Ambiente medido dentro de uma obra. Guarda **geometria bruta**
/// (comprimento, largura, altura) — nunca "a área" como campo único, pois
/// cada ofício deriva uma grandeza diferente do mesmo cômodo. Ver
/// CLAUDE.md, "Medição guarda geometria bruta, não 'a área'", e a
/// derivação implementada em `lib/measurement/measurement_math.dart`.
///
/// Medidas continuam `double` — ao contrário de dinheiro, aqui a precisão
/// de ponto flutuante é irrelevante (ver regra de engenharia do CLAUDE.md).
class Measurements extends Table with EntityMixin {
  TextColumn get projectId => text().references(Projects, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  RealColumn get lengthMeters => real()();
  RealColumn get widthMeters => real()();
  RealColumn get heightMeters => real()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Vão (porta ou janela) de um ambiente medido — usado para derivar
/// `area_parede` e `perimetro_util`. Ver CLAUDE.md, fórmulas de derivação.
class MeasurementOpenings extends Table with EntityMixin {
  TextColumn get measurementId => text().references(Measurements, #id)();
  TextColumn get type => textEnum<OpeningType>()();
  RealColumn get widthMeters => real()();
  RealColumn get heightMeters => real()();

  @override
  Set<Column> get primaryKey => {id};
}
