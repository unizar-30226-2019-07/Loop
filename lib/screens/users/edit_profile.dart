import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/widgets/profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selit/util/api/usuario_edit.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

/// Página de edición de perfil (formulario con los campos
/// necesarios para modificar los atributos del usuario)
/// Recibe el UsuarioClass del usuario a editar y, una vez terminado
/// de editar, realiza una petición para actualizar dichos cambios
class EditProfile extends StatefulWidget {
  final UsuarioClass user;

  /// UsuarioClass del usuario a editar
  EditProfile({@required this.user});

  @override
  _EditProfileState createState() => new _EditProfileState(user);
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _surnameController = new TextEditingController();
  final TextEditingController _locationController = new TextEditingController();
  final TextEditingController _sexController = new TextEditingController();
  final TextEditingController _yearController = new TextEditingController();
    final TextEditingController _oldPassController = new TextEditingController();
      final TextEditingController _newPassController = new TextEditingController();
        final TextEditingController _newPassRepController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static final _styleTitle = TextStyle(
      fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.bold);

  /// Usuario a mostrar en el perfil
  UsuarioClass _user;

  //Fichero de galería
  File _galleryFile;
  String _base64Image;
  String _mimeType;
  String _charset; 

  //Lista opciones sexo
  List<String> _sexos = <String>['', 'hombre', 'mujer', 'Otro'];
  String _sexo = '';

  /// Constructor: mostrar el usuario _user
  _EditProfileState(UsuarioClass _user) {
    this._user = _user;
    _base64Image = _user.pictureBase64;
    _mimeType = _user.pictureMime;
    _charset = _user.pictureCharset;
    _nameController.text = _user.nombre;
    _surnameController.text = _user.apellidos;
    _locationController.text = _user.ubicacionCiudad;
    _sexController.text = _user.sexo;
    _yearController.text = _user.edad.toString();
    _sexo = _user.sexo;
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

  void updateUser() {
    if (_nameController.text.length < 1 || _surnameController.text.length < 1) {
      showInSnackBar("Rellena toodos los campos correctamente", Colors.yellow);
    } else {
      _user.update(_nameController.text, _surnameController.text, _sexo, 3, 3, _mimeType, _base64Image , _charset);
      edit(_user).then((response) {
        final Color legit = Colors.blue.withOpacity(0.5);
        final Color fake = Colors.red.withOpacity(0.5);
        if (response.statusCode == 200) {
          print(response.body);
          showInSnackBar("Datos actualizados correctamente", legit);
        } else if (response.statusCode == 401) {
          print(response.statusCode);
          print(response.body);
          showInSnackBar("No autorizado", fake);
        } else if (response.statusCode == 402) {
          print(response.statusCode);
          print(response.body);
          showInSnackBar("Prohibido", fake);
        } else {
          print(response.statusCode);
          print(response.body);
          showInSnackBar("No encontrado", fake);
        }
      }).catchError((error) {
        print('error : $error');
      });
    }
  }

  void cambioPass() {

    if (_newPassController.text != _newPassRepController.text) {
      showInSnackBar("Las contraseñas no coinciden", Colors.yellow);
    } 
    else if(_newPassController.text.length <=0 || _newPassRepController.text.length <=0 
      || _oldPassController.text.length <=0 ){
        showInSnackBar("Completa todos los campos", Colors.yellow);
    }
    else{

    }
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
    imageSelectorGallery() async {
      _galleryFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
      );
      _base64Image = base64Encode(_galleryFile.readAsBytesSync());
      _mimeType = (lookupMimeType(_galleryFile.path));
      _charset = "utf-8";
      setState(() {});
    }

    Widget wDataTop = Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Container(
            margin: EdgeInsets.only(
              left: 10,
            ),
            //color: Colors.red, // util para ajustar margenes
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 50),
                  child: _galleryFile == null
                      ? ProfilePicture(_user)
                      : new CircleAvatar(
                          backgroundImage: new FileImage(_galleryFile),
                          radius: 70.0,
                        ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, left: 15),
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget>[
                      new FlatButton(
                          onPressed: imageSelectorGallery,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.edit),
                              Text("Editar")
                            ],
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
              margin: EdgeInsets.only(left: 25, right: 10, bottom: 35, top: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                    ),
                    controller: _nameController,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: new TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Apellidos',
                      ),
                      controller: _surnameController,
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                ],
              )),
        )
      ],
    );

    Widget wLocation = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
              margin: EdgeInsets.only(left: 25, right: 10, bottom: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Ubicación',
                    ),
                    controller: _locationController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              )),
        )
      ],
    );
    Widget wOldPassword = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
              margin: EdgeInsets.only(left: 25, right: 10, bottom: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Contraseña antigua',
                    ),
                    controller: _oldPassController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                ],
              )),
        )
      ],
    );

    Widget wPassword = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
              margin: EdgeInsets.only(left: 25, right: 10, bottom: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña',
                    ),
                    controller: _newPassController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Repetir nueva contraseña',
                    ),
                    controller: _newPassRepController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              )),
        )
      ],
    );

    Widget wSex = Row(
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Container(
              margin: EdgeInsets.only(left: 25, bottom: 7),
              //color: Colors.red, // util para ajustar margenes
              child: Column(children: <Widget>[
                new FormField(
                  builder: (FormFieldState state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Sexo',
                      ),
                      isEmpty: _sexo == '',
                      child: new DropdownButtonHideUnderline(
                        child: new DropdownButton(
                          value: _sexo,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _sexo = newValue;
                              state.didChange(newValue);
                            });
                          },
                          items: _sexos.map((String value) {
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
        ),
        Expanded(
          flex: 2,
          child: Container(
              margin: EdgeInsets.only(left: 5, top: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(children: <Widget>[
                new FlatButton(
                    onPressed: () {
                      setState(() {
                        _sexo = null;
                      });
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    child: new Icon(Icons.delete))
              ])),
        )
      ],
    );

    Widget wAge = Row(
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Container(
              margin: EdgeInsets.only(left: 25, bottom: 30),
              //color: Colors.red, // util para ajustar margenes
              child: Column(children: <Widget>[
                new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Edad',
                    labelText: 'Edad',
                  ),
                  controller: _yearController,
                  keyboardType: TextInputType.emailAddress,
                )
              ])),
        ),
        Expanded(
          flex: 2,
          child: Container(
              margin: EdgeInsets.only(left: 5),
              //color: Colors.red, // util para ajustar margenes
              child: Column(children: <Widget>[
                new FlatButton(
                    onPressed: () {
                      _yearController.clear();
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    child: new Icon(Icons.delete))
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
            child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                wDataTop,
                Divider(),
                wLocation,
                Divider(),
                wSex,
                wAge,
                new Container(
                    padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                    child: new RaisedButton(
                      color: Color(0xffc0392b),
                      child: const Text('Guardar cambios',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        updateUser();
                      },
                    )),
                Padding(
                  padding: EdgeInsets.only(
                    left: 6,
                    top: 40,
                    bottom: 10
                  ),
                  child: Row(children: <Widget>[
                    Row(children: <Widget>[
                      Text('Cambiar contraseña', style: _styleTitle)
                    ]),
                  ]),
                ),
                wOldPassword,
                Divider(),
                wPassword,
                new Container(
                    padding: const EdgeInsets.only(left: 10.0, top: 20.0, bottom: 55),
                    child: new RaisedButton(
                      color: Color(0xffc0392b),
                      child: const Text('Cambiar contraseña',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        cambioPass();
                      },
                    )),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(key: _scaffoldKey, body: _buildForm());
  }
}
