import '../database/database.dart';
import '../database/enums.dart';

/// Grandezas derivadas a partir da geometria bruta do cômodo.
///
/// Fórmulas do CLAUDE.md:
/// - area_piso = comprimento × largura
/// - area_teto = comprimento × largura
/// - perimetro = 2 × (comprimento + largura)
/// - area_parede = perimetro × altura − Σ(área dos vãos)
/// - perimetro_util = perimetro − Σ(largura das portas)
/// - volume = area_piso × espessura
class RoomDerivedQuantities {
  const RoomDerivedQuantities({
    required this.floorAreaSqM,
    required this.ceilingAreaSqM,
    required this.perimeterMeters,
    required this.wallAreaSqM,
    required this.effectivePerimeterMeters,
    required this.totalOpeningsAreaSqM,
  });

  final double floorAreaSqM;
  final double ceilingAreaSqM;
  final double perimeterMeters;
  final double wallAreaSqM;
  final double effectivePerimeterMeters;
  final double totalOpeningsAreaSqM;

  factory RoomDerivedQuantities.fromMeasurement({
    required double lengthMeters,
    required double widthMeters,
    required double heightMeters,
    required List<MeasurementOpening> openings,
  }) {
    final floorArea = lengthMeters * widthMeters;
    final ceilingArea = floorArea;
    final perimeter = 2 * (lengthMeters + widthMeters);

    double openingsArea = 0;
    double doorsWidth = 0;

    for (final op in openings) {
      final area = op.widthMeters * op.heightMeters;
      openingsArea += area;
      if (op.type == OpeningType.door) {
        doorsWidth += op.widthMeters;
      }
    }

    final grossWallArea = perimeter * heightMeters;
    final netWallArea = (grossWallArea - openingsArea).clamp(0.0, double.infinity);
    final effectivePerimeter = (perimeter - doorsWidth).clamp(0.0, double.infinity);

    return RoomDerivedQuantities(
      floorAreaSqM: floorArea,
      ceilingAreaSqM: ceilingArea,
      perimeterMeters: perimeter,
      wallAreaSqM: netWallArea,
      effectivePerimeterMeters: effectivePerimeter,
      totalOpeningsAreaSqM: openingsArea,
    );
  }
}
