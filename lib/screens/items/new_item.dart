import 'dart:io';
import 'package:flutter/material.dart';
import 'package:selit/class/image_class.dart';
import 'package:selit/class/item_class.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:selit/class/usuario_class.dart';

/// Primera pantalla del formulario de subida de un nuevo producto
/// Incluye tiítulo, descripción, categoría y fotos
class NewItem extends StatefulWidget {
  final UsuarioClass user;

  /// UsuarioClass del usuario
  NewItem({@required this.user});

  @override
  _NewItemState createState() => new _NewItemState(user);
}

class _NewItemState extends State<NewItem> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ///Controladores de campos del formulario
  final TextEditingController _titleController = new TextEditingController();
  final TextEditingController _descriptionController =
      new TextEditingController();

  ///Ficheros de galería
  List<File> _images = <File>[null, null, null, null, null];

  ///Lista opciones categoria
  List<String> _categorias = <String>['', 'Automocion', 'Ropa', 'Tecnología'];
  String _categoria = '';

  static ItemClass _item;

  //Prpietario del producto
  UsuarioClass _user;

  /// Constructor:
  _NewItemState(UsuarioClass _user) {
    this._user = _user;
  }

  /// Titulos
  static final _styleTitle = TextStyle(
      fontSize: 22.0, color: Colors.white, fontWeight: FontWeight.bold);

  static final _styleSubTitleB = TextStyle(
      fontSize: 17.0, color: Colors.white, fontWeight: FontWeight.bold);

  static final _styleSubTitle = TextStyle(
      fontSize: 17.0, color: Colors.grey, fontWeight: FontWeight.normal);

  static final _styleButton = TextStyle(
      fontSize: 19.0, color: Colors.white);

  ///Selección de foto 1 de galería
  imageSelectorGallery(int index) async {
    File selectedFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      if (selectedFile != null) {
        _images[index] = selectedFile;
      }
    });
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
    if (_titleController.text.length < 1 ||
        _descriptionController.text.length < 1 ||
        _categoria == '') {
      showInSnackBar("Rellena todos los campos correctamente", Colors.yellow);
    } else {
      // Quitar imágenes no usadas
      _images.removeWhere((x) => x == null);
      // Preparar item para pasar a newItem2
      _item = ItemClass(
          itemId: 0,
          title: _titleController.text,
          description: _descriptionController.text,
          locationLat: _user.locationLat,
          locationLng: _user.locationLng,
          category: _categoria,
          owner: _user,
          media: List.generate(_images.length,
            (i) => ImageClass.file(fileImage: _images[i])));

      Navigator.of(context).pushNamed('/new-item2', arguments: _item);
    }
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
                    animation: true,
                    animationDuration: 500,
                    width: 195.0,
                    lineHeight: 4.0,
                    percent: 0.5,
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
    /// Título y descipción del producto
    Widget wDataTop = Row(
      children: <Widget>[
        Expanded(
          child: Container(
              margin: EdgeInsets.only(left: 10, right: 10, bottom: 35, top: 30),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Título',
                    ),
                    controller: _titleController,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: new TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      controller: _descriptionController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                  ),
                ],
              )),
        )
      ],
    );

    /// Categoría del producto
    Widget wCategoria = Row(
      children: <Widget>[
        Expanded(
          child: Container(
              margin: EdgeInsets.only(left: 10, bottom: 26, right: 10),
              //color: Colors.red, // util para ajustar margenes
              child: Column(children: <Widget>[
                new FormField(
                  builder: (FormFieldState state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                      ),
                      isEmpty: _categoria == '',
                      child: new DropdownButtonHideUnderline(
                        child: new DropdownButton(
                          value: _categoria,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _categoria = newValue;
                              state.didChange(newValue);
                            });
                          },
                          items: _categorias.map((String value) {
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
          'Imágenes',
          style: new TextStyle(
            fontSize: 16.8,
            color: Colors.grey[600],
          ),
        ));

    /// Imágnenes del producto del producto
    Widget wImg = new Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 100.0,
        child: new ListView.builder(
          itemCount: _images.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => Container(
                height: 125.0,
                width: 150.0,
                child: _images[index] == null
                    ? new Container(
                        margin: const EdgeInsets.all(7.0),
                        padding: const EdgeInsets.all(3.0),
                        decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          border: new Border.all(color: Colors.grey[600]),
                        ),
                        child: new FlatButton(
                            onPressed: () {
                              imageSelectorGallery(index);
                            },
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 35,
                                    top: 0,
                                  ),
                                  child: Icon(Icons.add_a_photo),
                                ),
                              ],
                            )),
                      )
                    : new Container(
                        margin: const EdgeInsets.all(7.0),
                        padding: const EdgeInsets.all(3.0),
                        decoration: new BoxDecoration(
                            image: new DecorationImage(
                              image: FileImage(_images[index]),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                            border: new Border.all(color: Colors.grey[600])),
                      ),
              ),
        ));

    return SafeArea(
        top: false,
        bottom: false,
        child: new Form(
            key: _formKey,
            autovalidate: true,
            child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                wDataTop,
                Divider(),
                wCategoria,
                Divider(),
                wImgTitle,
                wImg,
                new Container(
                    margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 30.0),
                    child: RaisedButton(
                      color: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 20.0),
                      child: Text('Siguiente',
                          style: _styleButton),
                      onPressed: () {
                        createItem();
                      },
                    )),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment(0.10, -1.0),
              end: Alignment(-0.10, 1.0),
              stops: [
                0.23,
                0.23
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
