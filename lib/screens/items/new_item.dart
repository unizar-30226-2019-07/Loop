import 'dart:io';
import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/widgets/profile_picture.dart';
import 'package:image_picker/image_picker.dart';

/// Página de edición de perfil (formulario con los campos
/// necesarios para modificar los atributos del usuario)
/// Recibe el UsuarioClass del usuario a editar y, una vez terminado
/// de editar, realiza una petición para actualizar dichos cambios
class NewItem extends StatefulWidget {
  @override
  _NewItemState createState() => new _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _surnameController = new TextEditingController();
  final TextEditingController _locationController = new TextEditingController();
  final TextEditingController _sexController = new TextEditingController();
  final TextEditingController _yearController = new TextEditingController();

  /// Usuario a mostrar en el perfil

  //Fichero de galería
  File _galleryFile1;
  File _galleryFile2;

  //Lista opciones categoria
  List<String> _categorias = <String>['', 'Coches', 'Ropa', 'Tecnología'];
  String _categoria = '';

  /// Constructor:
  _NewItemState() {
    _galleryFile1 = null;
    _galleryFile2 = null;
  }

  /// Titulos: 'Añadir producto'
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
                  left: 5,
                  top: 8,
                ),
                child: Row(children: <Widget>[
                  Text('1) Producto ', style: _styleSubTitleB),
                  Text('> 2)  Precio ', style: _styleSubTitle)
                ]),
              ),
            ],
          )),
        ],
      ),
    );
  }

  /// Widget correspondiente a la edición del perfil del usuario _user
  /// Si un campo de _user es nulo, se muestran los campos por defecto
  Widget _buildForm() {
    // wDataTop
    // wLocation
    // wPassword
    // wSex
    // wAge

    //Selección de foto de galería
    imageSelectorGallery1() async {
      _galleryFile1 = await ImagePicker.pickImage(
        source: ImageSource.gallery,
      );
      setState(() {});
    }

    imageSelectorGallery2() async {
      _galleryFile2 = await ImagePicker.pickImage(
        source: ImageSource.gallery,
      );
      setState(() {});
    }

    Widget wDataTop = Row(
      children: <Widget>[
        Expanded(
          child: Container(
              margin: EdgeInsets.only(left: 25, right: 10, bottom: 35, top: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Título',
                    ),
                    controller: _nameController,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: new TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                      ),
                      controller: _surnameController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                    ),
                  ),
                ],
              )),
        )
      ],
    );

    Widget wCategoria = Row(
      children: <Widget>[
        Expanded(
          child: Container(
              margin: EdgeInsets.only(left: 25, bottom: 26, right: 10),
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

    Widget wImg = new Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: new ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Container(
              height: 125.0,
              width: 200.0,
              child: _galleryFile1 == null
                  ? new Container(
                      margin: const EdgeInsets.all(7.0),
                      padding: const EdgeInsets.all(3.0),
                      decoration: new BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          border: new Border.all(color: Colors.grey[600])),
                      child: new FlatButton(
                          onPressed: imageSelectorGallery1,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.add_a_photo),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: 20,
                                  top: 2,
                                ),
                                child: Text("Añadir foto"),
                              ),
                            ],
                          )),
                    )
                  : new Container(
                      margin: const EdgeInsets.all(7.0),
                      padding: const EdgeInsets.all(3.0),
                      decoration: new BoxDecoration(
                          image: new DecorationImage(
                            image: new AssetImage(_galleryFile1.path),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(15.0),
                          border: new Border.all(color: Colors.grey[600])),
                    ),
            ),
            Container(
                height: 125.0,
                width: 200.0,
                child: _galleryFile2 == null
                    ? new Container(
                        margin: const EdgeInsets.all(7.0),
                        padding: const EdgeInsets.all(3.0),
                        decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            border: new Border.all(color: Colors.grey[600])),
                        child: new FlatButton(
                            onPressed: imageSelectorGallery2,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.add_a_photo),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: 20,
                                    top: 2,
                                  ),
                                  child: Text("Añadir foto"),
                                )
                              ],
                            )),
                      )
                    : new Container(
                        margin: const EdgeInsets.all(7.0),
                        padding: const EdgeInsets.all(3.0),
                        decoration: new BoxDecoration(
                            image: new DecorationImage(
                              image: new AssetImage(_galleryFile2.path),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                            border: new Border.all(color: Colors.grey[600])),
                      ))
          ],
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
                wImg,
                Divider(),
                new Container(
                    padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                    child: new RaisedButton(
                      color: Color(0xffc0392b),
                      child: const Text('Siguiente',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/new-item2');
                      },
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
              begin: Alignment(0.15, -1.75),
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
