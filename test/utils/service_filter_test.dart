import 'package:flutter_test/flutter_test.dart';
import 'package:orcamentos/database/database.dart';
import 'package:orcamentos/database/enums.dart';
import 'package:orcamentos/utils/service_filter.dart';

Service _service({required String id, required String name, String? category}) {
  final now = DateTime.now();
  return Service(
    id: id,
    name: name,
    unit: ServiceUnit.squareMeter,
    defaultPriceCents: null,
    includesMaterial: false,
    defaultNote: null,
    category: category,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}

void main() {
  final services = [
    _service(id: '1', name: 'Pintura de parede', category: 'Pintura'),
    _service(id: '2', name: 'Aplicação de massa corrida', category: 'Pintura'),
    _service(id: '3', name: 'Reboco de parede', category: 'Alvenaria'),
    _service(id: '4', name: 'Serviço avulso'),
  ];

  test('distinctServiceCategories retorna categorias únicas, ordenadas, ignorando nulo/vazio', () {
    expect(distinctServiceCategories(services), ['Alvenaria', 'Pintura']);
  });

  test('filterServices sem filtro nenhum retorna tudo', () {
    expect(filterServices(services, query: '').length, 4);
  });

  test('filterServices filtra por nome, sem diferenciar maiúsculas', () {
    final result = filterServices(services, query: 'PAREDE');
    expect(result.map((s) => s.id), ['1', '3']);
  });

  test('filterServices filtra por categoria', () {
    final result = filterServices(services, query: '', category: 'Pintura');
    expect(result.map((s) => s.id), ['1', '2']);
  });

  test('filterServices combina nome e categoria', () {
    final result = filterServices(services, query: 'parede', category: 'Alvenaria');
    expect(result.map((s) => s.id), ['3']);
  });
}
