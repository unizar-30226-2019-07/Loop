import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:selit/screens/items/item_list_drawer.dart';
import 'package:selit/widgets/items/item_tile.dart';
import 'package:selit/widgets/items/item_tile_vertical.dart';
import 'package:selit/util/api/item_request.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/class/items/filter_list_class.dart';
import 'dart:async';

/// Listado de productos en venta, junto con una barra de búsqueda y una pantalla
/// de filtros para seleccionar qué productos ver/cómo ordenarlos.
/// Es posible colocar la vista en modo 1 columna o modo 2 columnas.
class ItemList extends StatefulWidget {
  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  /// Lista de items a mostrar en la vista
  List<ItemClass> _items = <ItemClass>[];

  /// Número de columnas a mostrar en la vista
  int _selectedColumns = 1;

  /// Texto de los filtros (precio, ubicacion, ordenacion)
  static final _styleFilters =
      TextStyle(fontSize: 14.0, color: Colors.white);

  /// Titulos: 'Productos en venta'
  static final _styleTitle = TextStyle(
      fontSize: 22.0,
      color: Colors.white,
      fontWeight: FontWeight.bold);

  /// Texto de 'Nada por aquí...'
  static final _styleNothing =
      const TextStyle(fontSize: 20.0, color: Colors.grey);
  static final _styleSearchBar = TextStyle(fontSize: 16.0);

  /// Color más oscuro que el rojo principal
  final _blendColor = Color.alphaBlend(Color(0x552B2B2B), Color(0xFFC0392B));

  /// Controlador de filtros, medio de comunicación entre ItemList e ItemListDrawer
  /// Para mas información, ver [FilterListClass]
  FilterListClass _filterManager;

  /// Lista de filtros (burbujas) para la parte superior de la pantalla
  Widget _filterList;

  /// Actualizar lista de filtros [_filterList] (función callback para FilterListClass)
  void _updateFilters() {
    List<Map<String, dynamic>> _filters = _filterManager.getFiltersList();

    setState(() {
      _filterList = Container(
          margin: EdgeInsets.symmetric(vertical: 7.0),
          height: _filters.length > 0 ? 35.0 : 0.0,
          child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (BuildContext context, int i) {
                return Container(
                  margin:
                      EdgeInsets.only(right: 10.0), // margen con otros filtros
                  child: ClipRRect(
                    borderRadius: new BorderRadius.circular(12.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 9.0), // padding dentro del filtro
                      height: 35.0,
                      color: _blendColor,
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                            onTap: _filters[i]['callback'],
                            child: Icon(FontAwesomeIcons.times,
                                size: 13.0, color: Colors.grey[300]),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Text(_filters[i]['name'],
                                style: _styleFilters,
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }));
    });
  }

  @override
  void initState() {
    super.initState();
    _filterManager = new FilterListClass(_updateFilters);
    listenForItems();
  }

  /// TODO Prueba para cargar fotos de cervezas
  void listenForItems() async {
    final Stream<ItemClass> stream = await ItemRequest.getItems();
    stream.listen((ItemClass item) => setState(() => _items.add(item)));
  }

  /// Menú superior: barra de búsquerda y botón para abrir el menú izquierdo de filtros
  Widget _buildTopMenu() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Builder(
              // Necesario para poder abrir el drawer desde aquí
              builder: (BuildContext context) => GestureDetector(
                    onTap: () => Scaffold.of(context).openDrawer(),
                    child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Icon(FontAwesomeIcons.slidersH,
                            size: 25.0, color: Colors.grey[100])),
                  )),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(right: 10.0),
              child: TextField( // TODO cambiar onSubmitted por onChanged? (igual son muchas peticiones)
                onSubmitted: (value) =>
                    _filterManager.addFilter(newSearchQuery: value),
                cursorColor: Theme.of(context).primaryColor,
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: "Buscar un producto",
                  hintStyle: _styleSearchBar,
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  prefixStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0, color: _blendColor),
                      borderRadius: BorderRadius.all(Radius.circular(30.0))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 2.0, color: _blendColor.withAlpha(150)),
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Lista horizontal de filtros + modo de ordenación
  Widget _buildFilters() {
    _updateFilters();
    return _filterList;
  }

  /// Título de la lista (productos) + ordenación en una columna o dos
  Widget _buildBottomMenu() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
      child: Row(
        children: <Widget>[
          Expanded(child: Text('Productos en venta', style: _styleTitle)),
          GestureDetector(
            onTap: () => setState(() {
                  _selectedColumns = 1;
                }),
            child: Container(
                padding: EdgeInsets.all(5.0),
                child: Icon(FontAwesomeIcons.thList,
                    color: _selectedColumns == 1
                        ? Colors.grey[200]
                        : Colors.grey[500])),
          ),
          GestureDetector(
            onTap: () => setState(() {
                  _selectedColumns = 2;
                }),
            child: Container(
                padding: EdgeInsets.all(5.0),
                child: Icon(FontAwesomeIcons.thLarge,
                    color: _selectedColumns == 2
                        ? Colors.grey[200]
                        : Colors.grey[500])),
          ),
        ],
      ),
    );
  }

  /// Lista de productos en venta (1 o 2 columnas)
  Widget _buildProductList(int numColumns) {
    if (_items.isEmpty) {
      // No hay items/productos para mostrar
      return SizedBox.expand(
          // expandir horizontalmente
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.not_interested, color: Colors.grey, size: 65.0),
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Text('Nada por aquí...', style: _styleNothing),
          )
        ],
      ));
    } else {
      if (numColumns == 1) {
        // Vista de objetos en una columna
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          itemCount: _items.length,
          itemBuilder: (context, index) => ItemTile(_items[index]),
        );
      } else {
        // Vista de objetos en dos columnas (StaggeredGridView, importado)
        return StaggeredGridView.countBuilder(
          crossAxisCount: 2,
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          itemCount: _items.length,
          itemBuilder: (context, index) => ItemTileVertical(_items[index]),
          staggeredTileBuilder: (index) => StaggeredTile.fit(1),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment(0.15, -1.0),
              end: Alignment(-0.15, 1.0),
              stops: [
                0.4,
                0.4
              ],
              colors: [
                Theme.of(context).primaryColor,
                Colors.grey[100],
              ]),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildTopMenu(),
              _buildFilters(),
              _buildBottomMenu(),
              Expanded(
                child: Container(
                  child: _buildProductList(_selectedColumns),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: ItemListDrawer(_filterManager),
    );
  }
}
