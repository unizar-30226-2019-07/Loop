import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:selit/widgets/items/item_tile.dart';
import 'package:selit/widgets/items/item_tile_vertical.dart';
import 'package:selit/util/api/item_request.dart';
import 'package:selit/class/item_class.dart';
import 'dart:async';

/// Listado de productos en venta, junto con una barra de búsqueda y una pantalla
/// de filtros para seleccionar qué productos ver/cómo ordenarlos.
/// Es posible colocar la vista en modo 1 columna o modo 2 columnas.
class ItemList extends StatefulWidget {
  @override
  _ItemList createState() => _ItemList();
}

class _ItemList extends State<ItemList> {

  /// Lista de items a mostrar en la vista
  List<ItemClass> _items = <ItemClass>[];
  /// Número de columnas a mostrar en la vista
  int _selectedColumns = 1;

  /// Lista con la descripción de los filtros que se están aplicando
  List<String> _filters = [
    'Precio: 50-100€',
    'Ubicación: 1-100km',
    'Ordenación: caro a barato'
  ];
  final _styleFilters = TextStyle(fontSize: 14.0, color: Colors.white);
  final _styleTitleProductos = TextStyle(fontSize: 22.0, color: Colors.white, fontWeight: FontWeight.bold);
  static final _styleNothing =
      const TextStyle(fontSize: 20.0, color: Colors.grey);

  /// Icono 'x'
  IconData _times = FontAwesomeIcons.times;

  // TODO temporal - Color rojo oscuro similar al empleado en los tabs (registro/perfil)
  // mover a temas o a otro lugar
  final _blendColor = Color.alphaBlend(
      Color(0x552B2B2B), Color(0xFFC0392B));

  /// Prueba para cargar fotos de cervezas
  @override
  void initState() {
    super.initState();
    listenForItems();
  }

  void listenForItems() async {
    final Stream<ItemClass> stream = await ItemRequest.getItems();
    stream.listen((ItemClass item) => setState(() => _items.add(item)));
  }

  /// Llamado al pulsar en la 'x' de un filtro
  void _onFilterTapped(int filterIndex) {
    print('Tapeado en el filtro $filterIndex');
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
              child: TextField(
                onSubmitted: (value) {
                  print(value);
                },
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey[100],
                  hintText: "Buscar un producto",
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
    final _filterVerticalSize = 35.0; // pixeles de altura de un tag
    return Container(
      margin: EdgeInsets.symmetric(vertical: 7.0),
      height: _filterVerticalSize,
      child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 15.0),
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          itemBuilder: (BuildContext context, int i) {
            return Container(
              margin: EdgeInsets.only(right: 10.0), // margen con otros filtros
              child: ClipRRect(
                borderRadius: new BorderRadius.circular(12.0),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 9.0), // padding dentro del filtro
                  height: _filterVerticalSize,
                  color: _blendColor,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () => _onFilterTapped(i),
                        child: Icon(_times, size: 13.0, color: Colors.grey[300]),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 5.0),
                        child: Text(_filters[i],
                            style: _styleFilters, textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  /// Título de la lista (productos) + ordenación en una columna o dos
  Widget _buildBottomMenu() {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
      child: Row(
        children: <Widget>[
          Expanded(child: Text('Productos en venta', style: _styleTitleProductos)),
          GestureDetector(
            onTap: () => setState(() { _selectedColumns = 1; }),
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: Icon(FontAwesomeIcons.thLarge, color: _selectedColumns == 1 ? Colors.grey[200] : Colors.grey[500])
            ),
          ),
          GestureDetector(
            onTap: () => setState(() { _selectedColumns = 2; }),
            child: Container(
              padding: EdgeInsets.all(5.0),
              child: Icon(FontAwesomeIcons.thList, color: _selectedColumns == 2 ? Colors.grey[200] : Colors.grey[500])
            ),
          ),
        ],
      ),
    );
  }

  /// Menú izquierdo de filtros
  Widget _buildFilterDrawer() {
    return Drawer(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: SafeArea(child: Text('Filtros, ordenacion...') // TODO completar
            ),
      ),
    );
  }

  /// Lista de productos en venta (1 o 2 columnas)
  Widget _buildProductList(int numColumns) {
    if (_items.isEmpty) {
      // No hay items/productos para mostrar
      return SizedBox.expand( // expandir horizontalmente
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.not_interested, color: Colors.grey, size: 65.0),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Text('Nada por aquí...', style: _styleNothing),
            )
          ],
        )
      );
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
        color: Theme.of(context).primaryColor,
        child: SafeArea(
          child: Column(
            children: <Widget>[
              _buildTopMenu(),
              _buildFilters(),
              _buildBottomMenu(),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment(0.1, -1.0),
                        end: Alignment(-0.1, 1.0),
                        stops: [
                          0.1, 0.1
                        ],
                        colors: [
                          Theme.of(context).primaryColor,
                          Colors.grey[100],
                        ]),
                  ),
                  child: _buildProductList(_selectedColumns),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: _buildFilterDrawer(),
    );
  }
}
