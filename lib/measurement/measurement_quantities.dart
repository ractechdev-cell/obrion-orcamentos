import '../database/enums.dart';
import 'measurement_math.dart';

/// Grandeza derivada de um cômodo medido que pode virar a quantidade de
/// um item de orçamento — a ponte medição → orçamento que evita redigitar
/// o número na mão (docs/POSICIONAMENTO_E_FEATURES_APP1.md, Parte 4,
/// item 3).
///
/// Vive num arquivo único (não duplicado nas telas) para o mesmo m²/m³
/// se comportar igual no wizard de orçamento e no formulário de gestão.
enum MeasurementQuantity {
  wallArea,
  floorArea,
  ceilingArea,
  perimeter,
  effectivePerimeter,
  /// Só faz sentido para serviços com unidade m³ (contrapiso, concreto) —
  /// precisa da espessura (`measurementQuantityValue` exige
  /// `slabThicknessMeters`).
  volume,
}

/// Rótulo em português da grandeza, exibido no seletor "Qual grandeza?".
String measurementQuantityLabel(MeasurementQuantity quantity) {
  switch (quantity) {
    case MeasurementQuantity.wallArea:
      return 'Área de parede';
    case MeasurementQuantity.floorArea:
      return 'Área de piso';
    case MeasurementQuantity.ceilingArea:
      return 'Área de teto';
    case MeasurementQuantity.perimeter:
      return 'Perímetro';
    case MeasurementQuantity.effectivePerimeter:
      return 'Perímetro útil';
    case MeasurementQuantity.volume:
      return 'Volume';
  }
}

/// Valor em metros/metros quadrados/metros cúbicos da grandeza, pronto
/// para virar a quantidade do item. Volume ignora negativa de espessura
/// (a matemática pura já o zera — ver `RoomDerivedQuantities`).
double measurementQuantityValue(
  MeasurementQuantity quantity,
  RoomDerivedQuantities derived, {
  double slabThicknessMeters = 0,
}) {
  switch (quantity) {
    case MeasurementQuantity.wallArea:
      return derived.wallAreaSqM;
    case MeasurementQuantity.floorArea:
      return derived.floorAreaSqM;
    case MeasurementQuantity.ceilingArea:
      return derived.ceilingAreaSqM;
    case MeasurementQuantity.perimeter:
      return derived.perimeterMeters;
    case MeasurementQuantity.effectivePerimeter:
      return derived.effectivePerimeterMeters;
    case MeasurementQuantity.volume:
      return derived.volumeCubicMeters(slabThicknessMeters);
  }
}

/// Grandeza que corresponde à unidade do serviço selecionado — m² do
/// quadrado de parede, piso e teto; metro linear de perímetros; m³ de
/// volume (exige espessura, pedida no fluxo). Unidades "un/ponto/diária/
/// verba" não têm medição por trás e não oferecem a ponte.
List<MeasurementQuantity> measurementQuantityOptions(ServiceUnit unit) {
  switch (unit) {
    case ServiceUnit.squareMeter:
      return const [
        MeasurementQuantity.wallArea,
        MeasurementQuantity.floorArea,
        MeasurementQuantity.ceilingArea,
      ];
    case ServiceUnit.linearMeter:
      return const [
        MeasurementQuantity.perimeter,
        MeasurementQuantity.effectivePerimeter,
      ];
    case ServiceUnit.cubicMeter:
      return const [MeasurementQuantity.volume];
    case ServiceUnit.unit:
    case ServiceUnit.point:
    case ServiceUnit.dailyRate:
    case ServiceUnit.lumpSum:
      return const [];
  }
}