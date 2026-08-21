import '../database/enums.dart';

/// Rótulo em português da unidade de serviço — usado tanto na Lista de
/// Preços quanto no Orçamento, para não duplicar o texto em duas telas.
String serviceUnitLabel(ServiceUnit unit) {
  switch (unit) {
    case ServiceUnit.squareMeter:
      return 'm²';
    case ServiceUnit.linearMeter:
      return 'm';
    case ServiceUnit.cubicMeter:
      return 'm³';
    case ServiceUnit.unit:
      return 'un';
    case ServiceUnit.point:
      return 'ponto';
    case ServiceUnit.dailyRate:
      return 'diária';
    case ServiceUnit.lumpSum:
      return 'verba';
  }
}
