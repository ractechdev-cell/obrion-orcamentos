import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/budget/budget_calculations.dart';
import 'package:orcamentos/database/enums.dart';
import 'package:orcamentos/measurement/measurement_math.dart';
import 'package:orcamentos/measurement/measurement_quantities.dart';

void main() {
  group('cm → m (borda de entrada do volume)', () {
    test('5 cm → 0.05 m', () {
      expect(centimetersToMeters(5), closeTo(0.05, 0.0001));
    });
    test('10.5 cm → 0.105 m', () {
      expect(centimetersToMeters(10.5), closeTo(0.105, 0.0001));
    });
    test('zero → null', () {
      expect(centimetersToMeters(0), isNull);
    });
    test('negativo → null', () {
      expect(centimetersToMeters(-2), isNull);
    });
    test('nulo → null', () {
      expect(centimetersToMeters(null), isNull);
    });
  });

  group('labels das grandezas', () {
    test('todos os rótulos em português', () {
      for (final (quantity, label) in [
        (MeasurementQuantity.wallArea, 'Área de parede'),
        (MeasurementQuantity.floorArea, 'Área de piso'),
        (MeasurementQuantity.ceilingArea, 'Área de teto'),
        (MeasurementQuantity.perimeter, 'Perímetro'),
        (MeasurementQuantity.effectivePerimeter, 'Perímetro útil'),
        (MeasurementQuantity.volume, 'Volume'),
      ]) {
        expect(measurementQuantityLabel(quantity), label);
      }
    });
  });
  final room = RoomDerivedQuantities.fromMeasurement(
    lengthMeters: 4.0,
    widthMeters: 5.0,
    heightMeters: 2.7,
    openings: const [],
  );

  group('measurementQuantityOptions por unidade', () {
    test('m³ oferece volume', () {
      expect(
        measurementQuantityOptions(ServiceUnit.cubicMeter),
        [MeasurementQuantity.volume],
      );
    });
    test('m² oferece parede/piso/teto', () {
      expect(
        measurementQuantityOptions(ServiceUnit.squareMeter),
        [
          MeasurementQuantity.wallArea,
          MeasurementQuantity.floorArea,
          MeasurementQuantity.ceilingArea,
        ],
      );
    });
    test('m linear oferece perímetros', () {
      expect(
        measurementQuantityOptions(ServiceUnit.linearMeter),
        [
          MeasurementQuantity.perimeter,
          MeasurementQuantity.effectivePerimeter,
        ],
      );
    });
    test('un/ponto/diária/verba não oferecem medição', () {
      for (final unit in [
        ServiceUnit.unit,
        ServiceUnit.point,
        ServiceUnit.dailyRate,
        ServiceUnit.lumpSum,
      ]) {
        expect(measurementQuantityOptions(unit), isEmpty, reason: '$unit');
      }
    });
  });

  group('measurementQuantityValue', () {
    test('volume usa a espessura fornecida', () {
      // 20 m² × 0.05 m = 1 m³.
      expect(
        measurementQuantityValue(
          MeasurementQuantity.volume,
          room,
          slabThicknessMeters: 0.05,
        ),
        closeTo(1.0, 0.0001),
      );
    });

    test('volume com espessura zero (default) é zero', () {
      expect(
        measurementQuantityValue(MeasurementQuantity.volume, room),
        0.0,
      );
    });
  });

  group('m³ → item de orçamento', () {
    test('quantidade derivada do volume alimenta o item', () {
      // 4×5, contrapiso de 5 cm → 1 m³; R$ 50,00/m³ → R$ 50,00.
      final quantity = room.volumeCubicMeters(0.05);
      expect(
        BudgetItemCalculation.itemTotalCents(
          quantity: quantity,
          unitPriceCents: 5000,
        ),
        5000,
      );
    });

    test('arredondamento meio pra cima de volume × preço', () {
      // 20 m² × 0.03 m = 0.6 m³; R$ 10,05/m³ → 0.6 × 1005 = 603 centavos.
      final quantity = room.volumeCubicMeters(0.03);
      expect(
        BudgetItemCalculation.itemTotalCents(
          quantity: quantity,
          unitPriceCents: 1005,
        ),
        603,
      );
    });

    test('volume ligado ao total do orçamento', () {
      // Orçamento com um único item m³: subtotal = total.
      final quantity = room.volumeCubicMeters(0.05);
      final totals = BudgetTotals.fromItems(
        items: [
          BudgetLineItem(quantity: quantity, unitPriceCents: 5000),
        ],
      );
      expect(totals.subtotalCents, 5000);
      expect(totals.totalCents, 5000);
    });
  });
}