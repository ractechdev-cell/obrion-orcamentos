import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/database/enums.dart';
import 'package:orcamentos/measurement/measurement_math.dart';

void main() {
  test('derives floor, ceiling, perimeter and wall area correctly', () {
    final result = RoomDerivedQuantities.fromMeasurement(
      lengthMeters: 4.0,
      widthMeters: 3.0,
      heightMeters: 2.7,
      openings: [],
    );

    expect(result.floorAreaSqM, 12.0);
    expect(result.ceilingAreaSqM, 12.0);
    expect(result.perimeterMeters, 14.0);
    expect(result.wallAreaSqM, 14.0 * 2.7); // 37.8
    expect(result.effectivePerimeterMeters, 14.0);
    expect(result.totalOpeningsAreaSqM, 0.0);
  });

  test('subtracts openings from wall area and door widths from perimeter', () {
    final result = RoomDerivedQuantities.fromMeasurement(
      lengthMeters: 4.0,
      widthMeters: 3.0,
      heightMeters: 2.7,
      openings: [
        // Porta: 0.8 x 2.1 = 1.68 m²
        MeasurementOpening(
          id: '1',
          measurementId: 'm1',
          type: OpeningType.door,
          widthMeters: 0.8,
          heightMeters: 2.1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        // Janela: 1.2 x 1.0 = 1.2 m²
        MeasurementOpening(
          id: '2',
          measurementId: 'm1',
          type: OpeningType.window,
          widthMeters: 1.2,
          heightMeters: 1.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
    );

    // Vãos total: 1.68 + 1.2 = 2.88 m²
    expect(result.totalOpeningsAreaSqM, closeTo(2.88, 0.001));

    // Parede bruta = 37.8 m²; Parede líquida = 37.8 - 2.88 = 34.92 m²
    expect(result.wallAreaSqM, closeTo(34.92, 0.001));

    // Perímetro útil = 14.0 - 0.8 (porta) = 13.2 m
    expect(result.effectivePerimeterMeters, closeTo(13.2, 0.001));
  });
}
