/// Lista de filtros empleada para la comunicación entre ItemList e ItemListDrawer
/// Contiene todos los filtros posibles a aplicar sobre el listado de objetos
class FilterListClass {

  // Nombres mostrar en el menú del drawer y burbujas de filtros
  static final List<String> categoryNames = [
    'Todas las categorías',
    'Coches',
    'Informática'
  ];
  static final List<String> typeNames = [
    'Venta y subasta',
    'Solo ventas',
    'Solo subastas'
  ];
  static final List<String> orderNames = [
    'Distancia (asc)',
    'Distancia (desc)',
    'Precio (asc)',
    'Precio (desc)'
  ];
  List<String> getCategoryNames() => categoryNames;
  List<String> getTypeNames() => typeNames;
  List<String> getOrderNames() => orderNames;

  // Valores mínimo y máximo absoluto para los sliders de precio/distancia
  static final double absMinPrice = 0.0;
  static final double absMaxPrice = 100.0;
  static final double absMinDistance = 0.0;
  static final double absMaxDistance = 10000.0;
  double getAbsMinPrice() => absMinPrice;
  double getAbsMaxPrice() => absMaxPrice;
  double getAbsMinDistance() => absMinDistance;
  double getAbsMaxDistance() => absMaxDistance;

  // Funciones auxiliares para mostrar el precio y distancia
  // (diferentes a las de ItemListDrawer)

  // Mostrar el precio como "40"
  final _formatPrecio = (double precio) => '${precio.toStringAsFixed(0)}';
  // Mostrar la distancia como "200m" o "1.5km"
  final _formatDistancia = (double distancia) => distancia < 1000
      ? '${distancia.toStringAsFixed(0)}m'
      : '${(distancia / 1000).toStringAsFixed(1)}km';

  // Filtros actuales
  String searchQuery = "";
  double minPrice = absMinPrice;
  double maxPrice = absMaxPrice;
  double minDistance = absMinDistance;
  double maxDistance = absMaxDistance;
  int categoryId = 0;
  int typeId = 0;
  int orderId = 0;

  // Al modificar un filtro, llamar al callback para dibujar las burbujas
  Function drawCallback;

  FilterListClass(this.drawCallback);

  void resetPrice() {
    minPrice = absMinPrice;
    maxPrice = absMaxPrice;
    drawCallback();
  }

  void resetDistance() {
    minDistance = absMinDistance;
    maxDistance = absMaxDistance;
    drawCallback();
  }

  void resetCategory() {
    categoryId = 0;
    drawCallback();
  }

  void resetType() {
    typeId = 0;
    drawCallback();
  }

  void resetOrder() {
    orderId = 0;
    drawCallback();
  }

  /// Añadir un filtro
  void addFilter(
      {String newSearchQuery,
      double newMinPrice,
      double newMaxPrice,
      double newMinDistance,
      double newMaxDistance,
      int newCategoryId,
      int newTypeId,
      int newOrderId}) {


    // Precio y distancia solo se actualizan de dos en dos
    if (newMinPrice != null && newMaxPrice != null) {
      assert(newMinPrice >= absMinPrice && newMaxPrice <= absMaxPrice);
      this.minPrice = newMinPrice;
      this.maxPrice = newMaxPrice;
    }
    if (newMinDistance != null && newMaxDistance != null) {
      assert(newMinDistance >= absMinDistance && newMaxDistance <= absMaxDistance);
      this.minDistance = newMinDistance;
      this.maxDistance = newMaxDistance;
    }
    // Asegurar valores válidos para los filtros
    assert(newCategoryId == null || (newCategoryId >= 0 && newCategoryId < categoryNames.length));
    assert(newTypeId == null || (newTypeId >= 0 && newTypeId < typeNames.length));
    assert(newOrderId == null || (newOrderId >= 0 && newOrderId < orderNames.length));
    this.searchQuery = newSearchQuery ?? this.searchQuery;
    this.categoryId = newCategoryId ?? this.categoryId;
    this.typeId = newTypeId ?? this.typeId;
    this.orderId = newOrderId ?? this.orderId;

    // Actualizar los dibujos con los valores actualizados
    drawCallback();
  }

  List<Map<String, dynamic>> getFiltersList() {
    List<Map<String, dynamic>> filters = new List<Map<String, dynamic>>();
    if (categoryId != 0) {
      filters.add({
        'name': '${categoryNames[categoryId]}',
        'callback': resetCategory
      });
    }
    if (typeId != 0) {
      filters.add(
          {'name': '${typeNames[typeId]}', 'callback': resetType});
    }
    if (minPrice > absMinPrice || maxPrice < absMaxPrice) {
      filters.add({
        'name':
            'Precio: ${_formatPrecio(minPrice)}-${_formatPrecio(maxPrice)} €',
        'callback': resetPrice
      });
    }
    if (minDistance > absMinDistance || maxDistance < absMaxDistance) {
      filters.add({
        'name':
            'Distancia: ${_formatDistancia(minDistance)}-${_formatDistancia(maxDistance)}',
        'callback': resetDistance
      });
    }
    if (orderId != 0) {
      filters.add({
        'name':
            'Ordenar por: ${orderNames[orderId]}',
        'callback': resetOrder
      });
    }
    return filters;
  }
}
