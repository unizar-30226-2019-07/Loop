import 'dart:io';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// Segunda pantalla del formulario de subida de un nuevo producto
/// Incluye selección de precio fijo o subasta  sus características
class NewItem2 extends StatefulWidget {
  @override
  _NewItemState2 createState() => new _NewItemState2();
}

class _NewItemState2 extends State<NewItem2> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  ///Controladores de campos del formulario
  final TextEditingController _priceController = new TextEditingController();
  final TextEditingController _limitController = new TextEditingController();

  //Ficheros de galería
  File _galleryFile1;
  File _galleryFile2;

  //Lista opciones divisa
  List<String> _divisas = <String>['', 'EUR', 'Otro'];
  String _divisa = '';

  //Lista opciones categoria
  List<String> _tiposPrecio = <String>['Precio Fijo', 'Subasta'];
  String _tipoPrecio = 'Precio Fijo';

  /// Constructor:
  _NewItemState2() {
    _galleryFile1 = null;
    _galleryFile2 = null;
  }

  /// Titulos
  static final _styleTitle = TextStyle(
      fontSize: 22.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontFamily: 'Nunito');

  static final _styleSubTitleB = TextStyle(
      fontSize: 17.0,
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontFamily: 'Nunito');

  static final _styleSubTitle = TextStyle(
      fontSize: 17.0,
      color: Colors.white,
      fontWeight: FontWeight.normal,
      fontFamily: 'Nunito');


  ///Selector de fecha
  DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2018, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

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
                Text('Nuevo producto', style: _styleTitle)
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
              margin: EdgeInsets.only(left: 10, bottom: 26, right: 10, top: 45),
              child: Column(children: <Widget>[
                new Container(
                  width: 350.0,
                  height: 200.0,
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      border: new Border.all(color: Colors.grey[600])),
                  child: Column(
                    children: <Widget>[
                      Row(children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            left: 11,
                            top: 25,
                          ),
                          child: Text("Título",
                              style: new TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Nunito')),
                        )
                      ]),
                      Row(children: <Widget>[
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
                                'Descripción: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean scelerisque varius mauris, eget pulvinar velit tincidunt nec. Nam dignissim gravida nunc, in pulvinar odio ullamcorper in. Vivamus sed massa egestas tellus commodo. ',
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.justify,
                                maxLines: 7,
                                style: new TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ))
                      ]),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 25,
                  ),
                  child: new FormField(
                    builder: (FormFieldState state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Tipo',
                        ),
                        isEmpty: _tipoPrecio == '',
                        child: new DropdownButtonHideUnderline(
                          child: new DropdownButton(
                            value: _tipoPrecio,
                            isDense: true,
                            onChanged: (String newValue) {
                              setState(() {
                                _tipoPrecio = newValue;
                                state.didChange(newValue);
                              });
                            },
                            items: _tiposPrecio.map((String value) {
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
                    keyboardType: TextInputType.emailAddress,
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

    ///Límite en subasta
    Widget wLimite = Row(
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Límite',
                    ),
                    controller: _limitController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              )),
        ),
        Expanded(
          flex: 2,
          child: Container(
              margin: EdgeInsets.only(left: 5, top: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(children: <Widget>[
                new FlatButton(
                    onPressed: () {
                      _selectDate(context);
                      //_limitController.text = "${selectedDate.toLocal()}";
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    child: new Icon(Icons.calendar_today))
              ])),
        )
      ],
    );

    return SafeArea(
        top: false,
        bottom: false,
        child: new Form(
            key: _formKey,
            autovalidate: true,
            child: _tipoPrecio == 'Precio Fijo'
                ? new ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: <Widget>[
                      wTipoPrecio,
                      Divider(),
                      wPrecio,
                      Divider(),
                      new Container(
                          padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                          child: new RaisedButton(
                            color: Color(0xffc0392b),
                            child: const Text('Subir producto',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {},
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
                      wLimite,
                      Divider(),
                      new Container(
                          padding: const EdgeInsets.only(left: 10.0, top: 20.0, right: 10),
                          child: new RaisedButton(
                            color: Color(0xffc0392b),
                            child: const Text('Subir producto',
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {},
                          )),
                    ],
                  )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment(0.15, -1.65),
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
              _buildBottomMenu(),
              Expanded(
                child: Container(
                  child: _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
