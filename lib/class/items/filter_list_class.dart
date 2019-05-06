/// Lista de filtros empleada para la comunicación entre ItemList e ItemListDrawer
/// Contiene todos los filtros posibles a aplicar sobre el listado de objetos
class FilterListClass {
  /// Nombres de categorías empleados por la API
  /// Mapa (nombre de API) -> (nombre en la aplicación)
  /// NOTA: Ambos nombres son iguales, pero es importante diferenciar
  /// los nombres de la API con los nombres de la aplicación
  static final Map<String, String> categoryNames = {
    'Automoción': 'Automoción',
    'Informática': 'Informática',
    'Moda': 'Moda',
    'Deporte y ocio': 'Deporte y ocio',
    'Videojuegos': 'Videojuegos',
    'Libros y música': 'Libros y música',
    'Hogar y jardín': 'Hogar y jardín',
    'Foto y audio': 'Foto y audio',
  };
  static final List<String> typeNames = [
    'En venta',
    'Subastas'
  ];
  static final List<String> orderNames = [
    'Más cercanos',
    'Más baratos',
    'Más caros',
    'Novedades'
  ];

  // Valores para los sliders de precio y distancia
  // El valor seleccionado no es el mismo que el mostrado
  // ejemplo: priceRange[3] = 30 euros máximo
  static final List<double> priceRange = List<double>()
    ..addAll(List.generate(2, (i) => i * 5.0)) // 0, 5
    ..addAll(List.generate(8, (i) => (i + 2) * 5.0)) // 10-50
    ..addAll(List.generate(6, (i) => (i + 5) * 10.0)) // 60-100
    ..addAll(List.generate(5, (i) => (i + 1) * 50.0 + 100.0)) // 150-300
    ..addAll(List.generate(7, (i) => (i + 1) * 100.0 + 300.0)) // 300-1000
    ..addAll(List.generate(3, (i) => (i + 1) * 2000.0)) // 2000-8000
    ..addAll(List.generate(3, (i) => (i + 1) * 10000.0)); // 10000-30000
  static final int absMaxPriceIndex = priceRange.length;
  static final List<double> distanceRange = List<double>()
    ..addAll(List.generate(9, (i) => (i + 1) * 1000.0))
    ..addAll(List.generate(5, (i) => (i + 1) * 10000.0))
    ..addAll(List.generate(2, (i) => (i + 1) * 100000.0));
  static final int absMaxDistanceIndex = distanceRange.length;

  // Mostrar el precio como "40"
  final _formatPrecio = (int i) => '${priceRange[i].toStringAsFixed(0)}';
  // Mostrar la distancia como "200m" o "1.5km"
  final _formatDistancia =
      (int i) => '${(distanceRange[i] / 1000).toStringAsFixed(1)}km';

  // Filtros actuales
  String searchQuery = "";
  int minPriceIndex = 0;
  int maxPriceIndex = absMaxPriceIndex - 1;
  int maxDistanceIndex = absMaxDistanceIndex - 1;
  int categoryId = 0;
  int typeId = 0;
  int orderId = 0;

  // Al modificar un filtro, llamar al callback para dibujar las burbujas
  // y actualizar los datos de la lista
  Function callback;

  FilterListClass(this.callback);

  void resetPrice() {
    minPriceIndex = 0;
    maxPriceIndex = absMaxPriceIndex - 1;
    callback();
  }

  void resetDistance() {
    maxDistanceIndex = absMaxDistanceIndex - 1;
    callback();
  }

  void resetCategory() {
    categoryId = 0;
    callback();
  }

  void resetType() {
    typeId = 0;
    callback();
  }

  void resetOrder() {
    orderId = 0;
    callback();
  }

  /// Añadir un filtro (cualquier parámetro no null se añade a los filtros)
  void addFilter(
      {String newSearchQuery,
      int newMinPrice,
      int newMaxPrice,
      int newMaxDistance,
      int newCategoryId,
      int newTypeId,
      int newOrderId}) {
    // Precio y distancia solo se actualizan de dos en dos
    if (newMinPrice != null && newMaxPrice != null) {
      assert(newMinPrice >= 0 && newMaxPrice <= absMaxPriceIndex);
      this.minPriceIndex = newMinPrice;
      this.maxPriceIndex = newMaxPrice;
    }
    if (newMaxDistance != null) {
      assert(newMaxDistance >= 0 && newMaxDistance < absMaxDistanceIndex);
      this.maxDistanceIndex = newMaxDistance;
    }
    // Asegurar valores válidos para los filtros
    assert(newCategoryId == null ||
        (newCategoryId >= 0 && newCategoryId < categoryNames.length));
    assert(
        newTypeId == null || (newTypeId >= 0 && newTypeId < typeNames.length));
    assert(newOrderId == null ||
        (newOrderId >= 0 && newOrderId < orderNames.length));
    this.searchQuery = newSearchQuery ?? this.searchQuery;
    this.categoryId = newCategoryId ?? this.categoryId;
    this.typeId = newTypeId ?? this.typeId;
    this.orderId = newOrderId ?? this.orderId;

    // Actualizar los dibujos con los valores actualizados
    callback();
  }

  /// Obtener los filtros como una lista, empleado para las "burbujas"
  /// de la parte superior de [ItemList]
  List<Map<String, dynamic>> getFiltersList() {
    List<Map<String, dynamic>> filters = new List<Map<String, dynamic>>();
    if (categoryId != 0) {
      filters.add(
          {'name': '${categoryNames.values.toList()[categoryId - 1]}', 'callback': resetCategory});
    }
    if (typeId != 0) {
      filters.add({'name': '${typeNames[typeId]}', 'callback': resetType});
    }
    if (minPriceIndex > 0 || maxPriceIndex < absMaxPriceIndex - 1) {
      filters.add({
        'name':
            'Precio: ${_formatPrecio(minPriceIndex)}-${_formatPrecio(maxPriceIndex)} €',
        'callback': resetPrice
      });
    }
    if (maxDistanceIndex < absMaxDistanceIndex - 1) {
      filters.add({
        'name': 'Distancia: Hasta ${_formatDistancia(maxDistanceIndex)}',
        'callback': resetDistance
      });
    }
    if (orderId != 0) {
      filters.add({
        'name': 'Ordenar por: ${orderNames[orderId]}',
        'callback': resetOrder
      });
    }
    return filters;
  }

  /// Obtener los filtros como un mapa, empleado para las requests en [ItemRequest].
  Map<String, String> getFiltersMap() {
    Map<String, String> map = new Map<String, String>();
    // SearchQuery
    if (searchQuery != null && searchQuery.isNotEmpty)
      map.putIfAbsent("search", () => searchQuery);
    // Tipos: venta o subasta
    if (typeId == 0) map.putIfAbsent("type", () => "sale");
    if (typeId == 1) map.putIfAbsent("type", () => "auction");
    // Precio
    map.putIfAbsent("priceFrom", () => priceRange[minPriceIndex].toString());
    map.putIfAbsent("priceTo", () => priceRange[maxPriceIndex].toString());
    // Distancia
    map.putIfAbsent("distance", () => (distanceRange[maxDistanceIndex] ~/ 1000).toString());
    // Categoria
    if (categoryId != 0)
      map.putIfAbsent("category", () => categoryNames.keys.toList()[categoryId - 1]);
    // Ordenación
    final _sortList = [
      'distance ASC',
      'price ASC',
      'price DESC',
      'published DESC'
    ];
    map.putIfAbsent("\$sort", () => _sortList[orderId]);
    return map;
  }
}
