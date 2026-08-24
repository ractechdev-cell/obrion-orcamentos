import '../database/database.dart';

/// Categorias distintas em uso, ordenadas alfabeticamente — usado pra
/// montar os chips de filtro na Lista de Preços. Serviços sem categoria
/// (`null`/vazio) não aparecem aqui, só no filtro "Todas".
List<String> distinctServiceCategories(List<Service> services) {
  final categories = <String>{
    for (final s in services)
      if (s.category != null && s.category!.trim().isNotEmpty) s.category!.trim(),
  };
  final sorted = categories.toList()..sort();
  return sorted;
}

/// Filtra serviços por termo de busca (nome) e categoria selecionada —
/// função pura, separada da tela pra dar pra testar sem widget test.
/// `category == null` significa "Todas".
List<Service> filterServices(List<Service> services, {required String query, String? category}) {
  final normalizedQuery = query.trim().toLowerCase();
  return services.where((s) {
    final matchesQuery = normalizedQuery.isEmpty || s.name.toLowerCase().contains(normalizedQuery);
    final matchesCategory = category == null || s.category?.trim() == category;
    return matchesQuery && matchesCategory;
  }).toList();
}
