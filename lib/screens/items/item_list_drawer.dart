import 'package:flutter/material.dart';
import 'package:flutter_range_slider/flutter_range_slider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Listado de filtros de la lista de items, diseñado para acompañar
/// a [ItemList]. Permite seleccionar precio y distancia con sliders, y
/// categoría, tipo de venta (venta, subasta o ambas) y ordenación con botones.
class ItemListDrawer extends StatefulWidget {
  @override
  _ItemListDrawerState createState() => _ItemListDrawerState();
}

class _ItemListDrawerState extends State<ItemListDrawer> {
  // TODO temporal - Color rojo oscuro similar al empleado en los tabs (registro/perfil)
  // mover a temas o a otro lugar
  final _blendColor = Color.alphaBlend(Color(0x552B2B2B), Color(0xFFC0392B));

  /// Texto que acompaña a los sliders de busqueda
  static final _styleTextSliders =
      TextStyle(fontSize: 17.0, color: Colors.grey[200], fontFamily: 'Nunito');

  /// Botones para seleccionar categoría y ordenaciónc
  static final _styleFilterButton =
      TextStyle(fontSize: 18.0, color: Colors.black, fontFamily: 'Nunito');

  /// Títulos "¿Qué estás buscando?" (también para el alertdialog)
  static final _styleTitle = TextStyle(
      fontSize: 22.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontFamily: 'Nunito');

  /// Texto del título del alertdialog
  static final _styleDialogTitle = TextStyle(
      fontSize: 19.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontFamily: 'Nunito');

  /// Texto de los botones del alertdialog, para cuando esta seleccionado y no
  static final _styleDialogButtonsUnselected =
      TextStyle(fontSize: 20.0, color: Colors.white, fontFamily: 'Nunito');
  static final _styleDialogButtonsSelected =
      TextStyle(fontSize: 20.0, color: Colors.black, fontFamily: 'Nunito');

  /// Valores mínimo y máximo para el precio
  final _sliderPriceMin = 0.0;
  final _sliderPriceMax = 100.0;

  /// Valores mínimo y máximo para la localización
  final _sliderLocationMin = 100.0;
  final _sliderLocationMax = 100000.0;
  // TODO convertir el slider a escala logaritmica o reducir el limite

  /// Valores mínimo y máximo para el precio (actuales)
  double _sliderPriceLower = 0.0;
  double _sliderPriceUpper = 100.0;

  /// Valores mínimo y máximo para la (actuales)
  double _sliderLocationLower = 100.0;
  double _sliderLocationUpper = 100000.0;

  /// Categorías e indice de categoría seleccionado
  final _listCategorias = ['Todas las categorías', 'Coches', 'Informática'];
  int _selectedCategoria = 0;

  /// Tipos de venta e indice seleccionado
  final _listTipoVenta = ['Venta y subasta', 'Solo ventas', 'Solo subastas'];
  int _selectedTipoVenta = 0;

  /// Ordenaciones e indice seleccionado
  final _listOrdenacion = [
    'Distancia (asc)',
    'Distancia (desc)',
    'Precio (asc)',
    'Precio (desc)'
  ];
  int _selectedOrdenacion = 0;

  /// Actualizar valores de precio
  void _updatePrice(double lowerRange, double upperRange) {
    print('Precio: $lowerRange $upperRange');
  }

  /// Actualizar valores de distancia
  void _updateLocation(double lowerRange, double upperRange) {
    print('Distancia (m): $lowerRange $upperRange');
  }

  /// Seleccionar nueva categoría
  void _updateCategoria(int index) {
    print('Categoria: $index');
    setState(() {
      // acciones para seleccionar categoria index
      _selectedCategoria = index;
    });
  }

  /// Seleccionar nuevo tipo: venta, subasta o ambas
  void _updateTipoVenta(int index) {
    print('Tipo: $index');
    setState(() {
      // acciones para seleccionar tipo de venta
      _selectedTipoVenta = index;
    });
  }

  /// Ordenacion por precio, localizacion...
  void _updateOrdenacion(int index) {
    print('Ordenacion: $index');
    setState(() {
      // acciones para seleccionar ordenacion
      _selectedOrdenacion = index;
    });
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
          TextStyle(color: Colors.black, fontFamily: 'Nunito'),
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
            min: _sliderPriceMin,
            max: _sliderPriceMax,
            lowerValue: _sliderPriceLower,
            upperValue: _sliderPriceUpper,
            divisions: (_sliderPriceMax - _sliderPriceMin).toInt(),
            showValueIndicator: true,
            valueIndicatorFormatter: (i, value) => _formatPrecio(value),
            onChanged: (double newLowerValue, double newUpperValue) {
              setState(() {
                _sliderPriceLower = newLowerValue;
                _sliderPriceUpper = newUpperValue;
              });
            },
            onChangeEnd: _updatePrice,
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
                child: Text(_formatPrecio(_sliderPriceLower),
                    style: _styleTextSliders, textAlign: TextAlign.left)),
            Expanded(
                child: Text(_formatPrecio(_sliderPriceUpper),
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
            min: _sliderLocationMin,
            max: _sliderLocationMax,
            lowerValue: _sliderLocationLower,
            upperValue: _sliderLocationUpper,
            divisions: (_sliderLocationMax - _sliderLocationMin) ~/
                100, // Incrementar la distancia cada 100 metros
            showValueIndicator: true,
            valueIndicatorFormatter: (i, value) => _formatDistancia(value),
            onChanged: (double newLowerValue, double newUpperValue) {
              setState(() {
                _sliderLocationLower = newLowerValue;
                _sliderLocationUpper = newUpperValue;
              });
            },
            onChangeEnd: _updateLocation,
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
                child: Text(_formatDistancia(_sliderLocationLower),
                    style: _styleTextSliders, textAlign: TextAlign.left)),
            Expanded(
                child: Text(_formatDistancia(_sliderLocationUpper),
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
                  _buildRadioButton(_listCategorias, _selectedCategoria,
                      'Selecciona una categoría', _updateCategoria),
                  _buildRadioButton(_listTipoVenta, _selectedTipoVenta,
                      'Selecciona el tipo', _updateTipoVenta),
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
                  _buildRadioButton(_listOrdenacion, _selectedOrdenacion,
                      'Ordenar por', _updateOrdenacion),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
