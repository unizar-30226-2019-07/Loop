import 'package:flutter/material.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:selit/screens/items/item_list.dart';
import 'package:selit/class/items/filter_list_class.dart';

/// Listado de filtros de la lista de items, diseñado para acompañar
/// a [ItemList]. Permite seleccionar precio y distancia con sliders, y
/// categoría, tipo de venta (venta, subasta o ambas) y ordenación con botones.
class ItemListDrawer extends StatefulWidget {
  final FilterListClass _filterManager;
  ItemListDrawer(this._filterManager);

  @override
  _ItemListDrawerState createState() => _ItemListDrawerState(_filterManager);
}

class _ItemListDrawerState extends State<ItemListDrawer> {

  /// Color más oscuro que el rojo principal
  final _blendColor = Color.alphaBlend(Color(0x552B2B2B), Color(0xFFC0392B));

  /// Texto que acompaña a los sliders de busqueda
  static final _styleTextSliders =
      TextStyle(fontSize: 17.0, color: Colors.grey[200]);

  /// Botones para seleccionar categoría y ordenaciónc
  static final _styleFilterButton =
      TextStyle(fontSize: 18.0, color: Colors.black);

  /// Títulos "¿Qué estás buscando?" (también para el alertdialog)
  static final _styleTitle = TextStyle(
      fontSize: 22.0,
      color: Colors.white,
      fontWeight: FontWeight.bold);

  /// Texto del título del alertdialog
  static final _styleDialogTitle = TextStyle(
      fontSize: 19.0,
      color: Colors.white,
      fontWeight: FontWeight.bold);

  /// Texto de los botones del alertdialog, para cuando esta seleccionado y no
  static final _styleDialogButtonsUnselected =
      TextStyle(fontSize: 20.0, color: Colors.white);
  static final _styleDialogButtonsSelected =
      TextStyle(fontSize: 20.0, color: Colors.black);

  FilterListClass _filterManager;

  // Constructor
  _ItemListDrawerState(this._filterManager);

  /// Actualizar valores de precio
  void _updatePrice(double lower, double upper) {
    print('Precio: $lower - $upper');
    setState(
        () => _filterManager.addFilter(newMinPrice: lower, newMaxPrice: upper));
  }

  /// Actualizar valores de distancia
  void _updateLocation(double lower, double upper) {
    print('Distancia: $lower - $upper');
    setState(() =>
        _filterManager.addFilter(newMinDistance: lower, newMaxDistance: upper));
  }

  /// Seleccionar nueva categoría
  void _updateCategoria(int index) {
    print('Categoria: $index');
    setState(() => _filterManager.addFilter(newCategoryId: index));
  }

  /// Seleccionar nuevo tipo: venta, subasta o ambas
  void _updateTipoVenta(int index) {
    print('Tipo: $index');
    setState(() => _filterManager.addFilter(newTypeId: index));
  }

  /// Ordenacion por precio, localizacion...
  void _updateOrdenacion(int index) {
    print('Ordenacion: $index');
    setState(() => _filterManager.addFilter(newOrderId: index));
  }

  /// Botón para categorías, venta y subasta u ordenación. Botón que, al pulsarlo,
  /// muestra un cuadro de diálogo con título [title] y opciones [items]. Al seleccionar
  /// un item de la lista, llama a la función [callback] con el item seleccionado
  Widget _buildRadioButton(
      List<String> items, int selected, String title, Function callback) {
    // Crear la lista con las opciones a elegir
    List<Widget> buttonOptions = [];
    for (var i = 0; i < items.length; i++) {
      buttonOptions.add(SizedBox.fromSize(
          size: Size(double.infinity, 50.0),
          child: Container(
              margin: EdgeInsets.all(2),
              child: FlatButton(
                color: selected == i ? Colors.grey[200] : _blendColor,
                child: Text(items[i],
                    style: selected == i
                        ? _styleDialogButtonsSelected
                        : _styleDialogButtonsUnselected),
                onPressed: () {
                  callback(i);
                  Navigator.of(context).pop();
                },
              ))));
    }

    // Diálogo a mostrar cuando se pulsa el boton
    AlertDialog dialog = AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: _blendColor, width: 2.0),
          borderRadius: BorderRadius.circular(10.0)),
      title: Text(title, style: _styleDialogTitle),
      content: Column(mainAxisSize: MainAxisSize.min, children: buttonOptions),
    );

    return RaisedButton(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(items[selected], style: _styleFilterButton),
          ),
          Icon(FontAwesomeIcons.chevronRight, color: Colors.black, size: 16.0),
        ],
      ),
      color: Colors.grey[200],
      onPressed: () =>
          showDialog(context: context, builder: (context) => dialog),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[50], width: 2.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  /// Menú izquierdo de filtros
  @override
  Widget build(BuildContext context) {
    // Estilo para los sliders
    final _sliderThemeData = SliderTheme.of(context).copyWith(
      activeTrackColor: Colors.grey[50], // linea activa
      inactiveTrackColor: _blendColor, // linea inactiva
      thumbColor: Colors.white, // dos botones a los lados
      overlayColor: Colors.white54, // al pulsar un boton
      valueIndicatorColor: Colors.grey[50], // indicador de xx €
      valueIndicatorTextStyle:
          TextStyle(color: Colors.black),
      activeTickMarkColor: Colors.transparent,
    );

    // Mostrar el precio como "40 €"
    final _formatPrecio = (double precio) => '${precio.toStringAsFixed(0)} €';
    // Mostrar la distancia como "200 m" o "1.5 km"
    final _formatDistancia = (double distancia) => distancia < 1000
        ? '${distancia.toStringAsFixed(0)} m'
        : '${(distancia / 1000).toStringAsFixed(1)} km';

    final _wPrecioSlider = Column(
      children: <Widget>[
        SliderTheme(
          data: _sliderThemeData,
          child: RangeSlider(
            min: _filterManager.getAbsMinPrice(),
            max: _filterManager.getAbsMaxPrice(),
            lowerValue: _filterManager.minPrice,
            upperValue: _filterManager.maxPrice,
            divisions: (_filterManager.getAbsMaxPrice() -
                    _filterManager.getAbsMinPrice())
                .toInt(),
            showValueIndicator: true,
            valueIndicatorFormatter: (i, value) => _formatPrecio(value),
            onChanged: (double newLowerValue, double newUpperValue) {
              setState(() {
                _filterManager.minPrice = newLowerValue;
                _filterManager.maxPrice = newUpperValue;
              });
            },
            onChangeEnd: _updatePrice,
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
                child: Text(_formatPrecio(_filterManager.minPrice),
                    style: _styleTextSliders, textAlign: TextAlign.left)),
            Expanded(
                child: Text(_formatPrecio(_filterManager.maxPrice),
                    style: _styleTextSliders, textAlign: TextAlign.end)),
          ],
        ),
      ],
    );

    final _wDistanciaSlider = Column(
      children: <Widget>[
        SliderTheme(
          data: _sliderThemeData,
          child: RangeSlider(
            min: _filterManager.getAbsMinDistance(),
            max: _filterManager.getAbsMaxDistance(),
            lowerValue: _filterManager.minDistance,
            upperValue: _filterManager.maxDistance,
            divisions: (_filterManager.getAbsMaxDistance() -
                    _filterManager.getAbsMinDistance()) ~/
                100, // Incrementar la distancia cada 100 metros
            showValueIndicator: true,
            valueIndicatorFormatter: (i, value) => _formatDistancia(value),
            onChanged: (double newLowerValue, double newUpperValue) {
              setState(() {
                _filterManager.minDistance = newLowerValue;
                _filterManager.maxDistance = newUpperValue;
              });
            },
            onChangeEnd: _updateLocation,
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
                child: Text(_formatDistancia(_filterManager.minDistance),
                    style: _styleTextSliders, textAlign: TextAlign.left)),
            Expanded(
                child: Text(_formatDistancia(_filterManager.maxDistance),
                    style: _styleTextSliders, textAlign: TextAlign.end)),
          ],
        ),
      ],
    );

    return Drawer(
      child: Container(
        color: Theme.of(context).primaryColor,
        child: SafeArea(
          child: SizedBox.expand(
            child: Container(
              padding: EdgeInsets.only(
                  left: 15.0, right: 20.0, top: 20.0, bottom: 20.0),
              child: ListView(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Text('¿Qué estás buscando?', style: _styleTitle),
                  ),
                  Divider(color: Colors.grey[300]),
                  _buildRadioButton(
                      _filterManager.getCategoryNames(),
                      _filterManager.categoryId,
                      'Selecciona una categoría',
                      _updateCategoria),
                  _buildRadioButton(
                      _filterManager.getTypeNames(),
                      _filterManager.typeId,
                      'Selecciona el tipo',
                      _updateTipoVenta),
                  Container(
                    margin: EdgeInsets.only(top: 15.0, bottom: 5.0),
                    child: Text('Precio', style: _styleTitle),
                  ),
                  _wPrecioSlider,
                  Container(
                    margin: EdgeInsets.only(top: 15.0, bottom: 5.0),
                    child: Text('Distancia', style: _styleTitle),
                  ),
                  _wDistanciaSlider,
                  Container(
                    margin: EdgeInsets.only(top: 15.0, bottom: 5.0),
                    child: Text('Ordenar por', style: _styleTitle),
                  ),
                  _buildRadioButton(_filterManager.getOrderNames(),
                      _filterManager.orderId, 'Ordenar por', _updateOrdenacion),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
