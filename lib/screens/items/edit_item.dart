import 'dart:io';
import 'package:flutter/material.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/screens/items/edit_item_2.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:selit/class/items/filter_list_class.dart';
import 'package:selit/class/image_class.dart';

/// Primera pantalla del formulario de subida de un nuevo producto
/// Incluye tiítulo, descripción, categoría y fotos
class EditItem extends StatefulWidget {
  final ItemClass item;

  /// UsuarioClass del usuario
  EditItem({@required this.item});

  @override
  _EditItemState createState() => new _EditItemState(item);
}

class _EditItemState extends State<EditItem> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ///Controladores de campos del formulario
  final TextEditingController _titleController = new TextEditingController();
  final TextEditingController _descriptionController =
      new TextEditingController();

  ///Ficheros de galería
  List _images;
  int _imagen = 0;

  ///Lista opciones categoria
  List<String> _categorias = <String>['']
    ..addAll(FilterListClass.categoryNames.values.toList());
  String _categoria = '';

  ItemClass _item;

  /// Constructor:
  _EditItemState(ItemClass item) {
    this._item = item;
    _titleController.text = _item.title;
    _descriptionController.text = _item.description;
    _categoria = FilterListClass.categoryNames[_item.category];
    // Rellenar con las ImageClass del item
    _images = [];
    _images.addAll(_item.media);
    // Rellenar lo que falte con null
    for (int i = _item.media.length; i < 5; i++) _images.add(null);
    print('Precio actual: ' + _item.price.toString());
  }

  /// Titulos
  static final _styleTitle = TextStyle(
      fontSize: 22.0, color: Colors.white, fontWeight: FontWeight.bold);

  static final _styleSubTitleB = TextStyle(
      fontSize: 17.0, color: Colors.white, fontWeight: FontWeight.bold);

  static final _styleSubTitle = TextStyle(
      fontSize: 17.0, color: Colors.grey, fontWeight: FontWeight.normal);

  static final _styleButton = TextStyle(fontSize: 19.0, color: Colors.white);

  ///Selección de foto 1 de galería
  imageSelectorGallery() async {
    _images[_imagen] = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {});
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

  void editItem() {
    if (_titleController.text.length < 1 ||
        _descriptionController.text.length < 1 ||
        _categoria == '') {
      showInSnackBar("Rellena todos los campos correctamente", Colors.yellow);
    } else {
      print('Id de producto: ' + _item.itemId.toString());
      // Quitar imágenes no usadas
      List nonNull = List.from(_images.where((x) => x != null));
      _item.title = _titleController.text;
      _item.description = _descriptionController.text;
      _item.category = FilterListClass.categoryNames.keys
          .where((k) => FilterListClass.categoryNames[k] == _categoria)
          .first;

      List<ImageClass> _media = [];
      int i = 0;
      for (var imagen in nonNull) {
        if (imagen is ImageClass) {
          _media.add(imagen);
        } else {
          _media.add(ImageClass.file(fileImage: nonNull[i]));
        }
        i = i + 1;
      }
      _item.media = _media;

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => EditItem2(item: _item)));
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
                    maxLength: 50,
                    controller: _titleController,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: new TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      maxLength: 300,
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
          'Imágenes (mantén pulsado para borrar)',
          style: new TextStyle(
            fontSize: 15,
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
                              _imagen = index;
                              imageSelectorGallery();
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
                    : FlatButton(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.all(0),
                        onPressed: () => null, // para efecto de InkResponse
                        child: GestureDetector(
                          onLongPress: () =>
                              setState(() => _images[index] = null),
                          child: InkWell(
                            splashColor: Colors.black,
                            child: new Container(
                              margin: const EdgeInsets.all(7.0),
                              padding: const EdgeInsets.all(3.0),
                              decoration: new BoxDecoration(
                                  image: new DecorationImage(
                                    image: _images[index] is File
                                        ? new AssetImage(_images[index].path)
                                        : _images[index].image.image,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(15.0),
                                  border:
                                      new Border.all(color: Colors.grey[600])),
                            ),
                          ),
                        ),
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
                Divider(),
                new Container(
                    margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 30.0),
                    child: RaisedButton(
                      color: Theme.of(context).primaryColor,
                      padding:
                          EdgeInsets.symmetric(vertical: 7.0, horizontal: 20.0),
                      child: Text('Siguiente', style: _styleButton),
                      onPressed: () {
                        editItem();
                      },
                    )),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Theme.of(context).primaryColor);
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
