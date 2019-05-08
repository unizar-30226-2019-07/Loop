import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:selit/util/bar_color.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/util/api/item_request.dart';

/// Segunda pantalla del formulario de subida de un nuevo producto
/// Incluye selección de precio fijo o subasta  sus características
class EditItem2 extends StatefulWidget {
  final ItemClass item;

  /// UsuarioClass del usuario a editar
  EditItem2({@required this.item});

  @override
  _EditItemState2 createState() => new _EditItemState2(item);
}

class _EditItemState2 extends State<EditItem2> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ///Controladores de campos del formulario
  final TextEditingController _priceController = new TextEditingController();

  //Lista opciones divisa
  List<String> _divisas = <String>['', 'EUR', 'USD'];
  String _divisa = '';

  //Lista opciones categoria
  String _tipoPrecio = 'sale';

  ItemClass _item;

  /// Fecha límite
  DateTime _selectedDate;

  final Color _colorStatusBarGood = Colors.blue.withOpacity(0.5);
  final Color _colorStatusBarBad = Colors.red.withOpacity(0.5);

  /// Constructor:
  _EditItemState2(ItemClass item) {
    this._item = item;
    _priceController.text = item.price.toString();
    _divisa = item.currency;
    _buttonFunction = createItem;
    _tipoPrecio= item.type == "auction" ? "auction" : "sale";
    _selectedDate= item.endDate;
  }

  /// Titulos
  static final _styleTitle = TextStyle(
      fontSize: 22.0, color: Colors.white, fontWeight: FontWeight.bold);

  static final _styleSubTitleB = TextStyle(
      fontSize: 17.0, color: Colors.grey, fontWeight: FontWeight.bold);

  static final _styleSubTitle = TextStyle(
      fontSize: 17.0, color: Colors.white, fontWeight: FontWeight.normal);

  static final _styleButton = TextStyle(fontSize: 19.0, color: Colors.white);


  String _dateString(DateTime fecha) {
    return '${fecha.day} / ${fecha.month} / ${fecha.year}';
  }
  void showInSnackBar(String value, Color alfa) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      ),
      backgroundColor: alfa,
      duration: Duration(seconds: 3),
    ));
  }

  void createItem() {
    // Diálogo "cargando..." para evitar repetir
    _buttonFunction = null;
    showDialog(
      barrierDismissible: false, // JUST MENTION THIS LINE
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(
                strokeWidth: 5.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
            Container(
                margin: EdgeInsets.only(top: 15.0), child: Text('Cargando...')),
          ],
        ));
      },
    );
    // Editar producto
    double formattedPrice =
        double.tryParse(_priceController.text.replaceAll(',', '.'));

    if (_tipoPrecio == 'sale') {
      if (_priceController.text.length < 1 ||
          formattedPrice == null ||
          _tipoPrecio == '' ||
          _divisa == '') {
        showInSnackBar("Rellena todos los campos correctamente", Colors.yellow);
      } else {
        _item.update(
            type: _tipoPrecio, price: formattedPrice, currency: _divisa);

        ItemRequest.edit(_item).then((_) {
          print('Item actualizado');
          showInSnackBar(
              "Datos actualizados correctamente", _colorStatusBarGood);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }).catchError((error) {
          if (error == "Unauthorized" || error == "Forbidden") {
            showInSnackBar("Acción no autorizada", _colorStatusBarBad);
          } else if (error == "Internal Server Error") {
            showInSnackBar("Imagen no válida, prueba con otra", _colorStatusBarBad);
          } else {
            showInSnackBar("No hay conexión a internet", _colorStatusBarBad);
          }
          _buttonFunction = createItem;
          Navigator.of(context).pop();
        });
      }
    } else {
      if (_priceController.text.length < 1 ||
          formattedPrice == null ||
          _tipoPrecio == '' ||
          _divisa == ''
          ) {
        showInSnackBar("Rellena todos los campos correctamente 2", Colors.yellow);
      } else {
        
        _item.updateAuction(
            type: _tipoPrecio, price: formattedPrice, currency: _divisa, endDate: _selectedDate);

        ItemRequest.editAuction(_item).then((_) {
          print('Subasta actualizada');
          showInSnackBar(
              "Datos actualizados correctamente", _colorStatusBarGood);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }).catchError((error) {
          if (error == "Unauthorized" || error == "Forbidden") {
            showInSnackBar("Acción no autorizada", _colorStatusBarBad);
          } else if (error == "Internal Server Error") {
            showInSnackBar("Imagen no válida, prueba con otra", _colorStatusBarBad);
          } else {
            print("Error: $error");
            showInSnackBar("No hay conexión a internet", _colorStatusBarBad);
          }
          _buttonFunction = createItem;
          Navigator.of(context).pop();
        });
        
      }
    }
  }

  Function _buttonFunction; // inhabilidar boton

  ///Títulos iniciales
  Widget _buildBottomMenu() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 25.0),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Column(
            children: <Widget>[
              Row(children: <Widget>[
                Text('Editar producto', style: _styleTitle)
              ]),
              Padding(
                padding: EdgeInsets.only(
                  left: 6,
                  top: 15,
                ),
                child: Row(children: <Widget>[
                  Text('1) Producto ', style: _styleSubTitleB),
                  Text('   2) Precio ', style: _styleSubTitle)
                ]),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 3,
                ),
                child: Row(children: <Widget>[
                  new LinearPercentIndicator(
                    animation: true,
                    animationDuration: 500,
                    width: 195.0,
                    lineHeight: 4.0,
                    percent: 1,
                    backgroundColor: Colors.grey,
                    progressColor: Colors.white,
                  ),
                ]),
              ),
            ],
          )),
        ],
      ),
    );
  }

  /// Formulario de inserción de un nuevo producto
  Widget _buildForm() {
    /// Resumen del producto y selección del tipo de producto: precio fijo o subasta
    Widget wTipoPrecio = Row(
      children: <Widget>[
        Expanded(
          child: Container(
              margin: EdgeInsets.only(left: 10, bottom: 26, right: 10, top: 55),
              child: Column(children: <Widget>[
                new Container(
                  width: 350.0,
                  height: 200.0,
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: new Border.all(color: Colors.grey[600])),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                          left: 11,
                          top: 25,
                        ),
                        child: Text(_item.title,
                            overflow: TextOverflow.ellipsis,
                            style: new TextStyle(
                                fontSize: 22.0, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                          padding: EdgeInsets.only(
                            left: 11,
                            top: 10,
                          ),
                          child: Container(
                            constraints: new BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width - 95),
                            child: Text(
                              _item.description,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              maxLines: 7,
                              style: new TextStyle(
                                fontSize: 15.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ))
                    ],
                  ),
                ),
                
              ])),
        )
      ],
    );

    ///Precio del producto y divisa
    Widget wPrecio = Row(
      children: <Widget>[
        Expanded(
          flex: 7,
          child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Precio',
                    ),
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                  ),
                ],
              )),
        ),
        Expanded(
          flex: 3,
          child: Container(
              margin: EdgeInsets.only(left: 25, bottom: 26, right: 10),
              //color: Colors.red, // util para ajustar margenes
              child: Column(children: <Widget>[
                new FormField(
                  builder: (FormFieldState state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Divisa',
                      ),
                      isEmpty: _divisa == '',
                      child: new DropdownButtonHideUnderline(
                        child: new DropdownButton(
                          value: _divisa,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _divisa = newValue;
                              state.didChange(newValue);
                            });
                          },
                          items: _divisas.map((String value) {
                            return new DropdownMenuItem(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ])),
        )
      ],
    );

    Widget wImgTitle = Padding(
        padding: EdgeInsets.only(
          left: 10,
          top: 17,
        ),
        child: Text(
          'Fecha y hora límite',
          style: new TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ));


    Widget wAge = Row(
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Container(
              margin: EdgeInsets.only(left: 15, right: 10, top:10),
              child: RaisedButton(
                color: Colors.grey[600],
                onPressed: () async {
                  DateTime picked = await showDatePicker(
                      context: context, 
                      initialDate: _selectedDate ?? DateTime.now().add(new Duration(days: 0, hours: 1)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030, 1));
                  setState(() {
                    _selectedDate = picked;
                  });
                },
                child: Text(
                  _selectedDate == null
                      ? 'Fecha ...'
                      : _dateString(_selectedDate),
                  style: _styleButton,
                  textAlign: TextAlign.left,
                ),
              )),
        )
      ],
    );

    return SafeArea(
        top: false,
        bottom: false,
        child: new Form(
            key: _formKey,
            autovalidate: true,
            child: _tipoPrecio == 'sale'
                ? new ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: <Widget>[
                      wTipoPrecio,
                      Divider(),
                      wPrecio,
                      Divider(),
                      new Container(
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 30.0),
                          child: RaisedButton(
                            color: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(
                                vertical: 7.0, horizontal: 20.0),
                            child:
                                Text('Modificar producto', style: _styleButton),
                            onPressed: _buttonFunction,
                          )),
                    ],
                  )
                : new ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: <Widget>[
                      wTipoPrecio,
                      Divider(),
                      wPrecio,
                      Divider(),
                      wImgTitle,
                      wAge,
                      Divider(),
                      new Container(
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 30.0),
                          child: RaisedButton(
                            color: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(
                                vertical: 7.0, horizontal: 20.0),
                            child:
                                Text('Modificar producto', style: _styleButton),
                            onPressed: _buttonFunction,
                          )),
                    ],
                  )));
  }

  @override
  Widget build(BuildContext context) {
    BarColor.changeBarColor(color: Colors.transparent, whiteForeground: true);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment(0.01, -1.0),
                    end: Alignment(-0.01, 1.0),
                    stops: [
                      0.93,
                      0.93
                    ],
                    colors: [
                      Theme.of(context).primaryColor,
                      Colors.grey[100],
                    ]),
              ),
              child: _buildBottomMenu(),
            ),
            Expanded(
              child: Container(
                color: Colors.grey[100],
                child: _buildForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
