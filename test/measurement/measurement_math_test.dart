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

  group('volume m³', () {
    final room = RoomDerivedQuantities.fromMeasurement(
      lengthMeters: 4.0,
      widthMeters: 5.0,
      heightMeters: 2.7,
      openings: [],
    );

    test('área × espessura em metros = volume', () {
      // 4 × 5 = 20 m²; espessura 0.05 m → 1 m³ (exemplo da sprint).
      expect(room.floorAreaSqM, 20.0);
      expect(room.volumeCubicMeters(0.05), closeTo(1.0, 0.0001));
    });

    test('espessura em cm é convertida no caller antes da derivada', () {
      // 5 cm = 0.05 m. A matemática pura recebe sempre metros.
      const thicknessCm = 5.0;
      const thicknessM = thicknessCm / 100;
      expect(room.volumeCubicMeters(thicknessM), closeTo(1.0, 0.0001));
    });

    test('espessura decimal', () {
      // 20 m² × 0.075 m = 1.5 m³.
      expect(room.volumeCubicMeters(0.075), closeTo(1.5, 0.0001));
    });

    test('espessura zero → volume zero', () {
      expect(room.volumeCubicMeters(0), 0.0);
    });

    test('espessura negativa → volume zero (sem vazar negativo)', () {
      expect(room.volumeCubicMeters(-0.05), 0.0);
    });

    test('precisão — multiplicação em double com epsilons', () {
      // 20 m² × 0.033 m = 0.66 m³ (tolerância de representação binária).
      expect(room.volumeCubicMeters(0.033), closeTo(0.66, 0.0001));
    });
  });
}
