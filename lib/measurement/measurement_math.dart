import '../database/database.dart';
import '../database/enums.dart';

/// Converte a entrada de espessura (em centímetros, a unidade que se fala
/// em obra) para metros — a unidade que as fórmulas usam. `null` quando o
/// valor é vazio, zero ou negativo (inválido pra camada).
double? centimetersToMeters(double? centimeters) {
  if (centimeters == null || centimeters <= 0) return null;
  return centimeters / 100;
}

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

  /// Volume para uma espessura de camada — `area_piso × espessura`.
  ///
  /// A espessura não é uma propriedade do cômodo: o mesmo cômodo pode
  /// servir pra um contrapiso de 5cm ou 10cm, então ela entra aqui como
  /// parâmetro da capa do serviço (m³), nunca persistida na medição.
  /// Mantém a matemática pura (sem UI): espessura não-negativa; negativa
  /// (erro de digitação no formulário) resulta em volume 0 em vez de
  /// valor negativo que vazaria pro orçamento.
  double volumeCubicMeters(double slabThicknessMeters) {
    final slab = slabThicknessMeters < 0 ? 0.0 : slabThicknessMeters;
    return floorAreaSqM * slab;
  }

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
