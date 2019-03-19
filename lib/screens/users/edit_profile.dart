import 'dart:io';

import 'package:flutter/material.dart';
import 'package:selit/models/usuario_model.dart';
import 'package:selit/widgets/profile_picture.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  final UsuarioModel user;

  /// Página de perfil para el usuario userId
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

  //Fichero de galería
  File _galleryFile;

  /// Usuario a mostrar en el perfil
  UsuarioModel _user;

  /// Constructor: mostrar el usuario _user
  _EditProfileState(UsuarioModel _user) {
    this._user = _user;
    _nameController.text = _user.nombre;
    _surnameController.text = _user.apellidos;
    _locationController.text = _user.ubicacionCiudad;
    _sexController.text = _user.sexo;
    _yearController.text = _user.edad.toString();
    _galleryFile = null;
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
                      ? ProfilePicture(_user.urlPerfil)
                      //TODO No deja crear ProfilePicture() con path local al seleccionar de galería
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
                    keyboardType: TextInputType.emailAddress,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Repetir nueva contraseña',
                    ),
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
          flex: 10,
          child: Container(
            margin: EdgeInsets.only(left: 25, right: 10),
            //color: Colors.red, // util para ajustar margenes
            child: Column(
              children: <Widget>[
                new Stack(
                    alignment: const Alignment(1.0, 1.0),
                    children: <Widget>[
                      new TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Sexo',
                          labelText: 'Sexo',
                        ),
                        controller: _sexController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      new FlatButton(
                          onPressed: () {
                            _sexController.clear();
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          child: new Icon(Icons.clear))
                    ])
              ],
            ),
          ),
        )
      ],
    );

    Widget wAge = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
            margin: EdgeInsets.only(left: 25, bottom: 30, right: 10),
            //color: Colors.red, // util para ajustar margenes
            child: Column(
              children: <Widget>[
                new Stack(
                    alignment: const Alignment(1.0, 1.0),
                    children: <Widget>[
                      new TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Edad',
                          labelText: 'Edad',
                        ),
                        controller: _yearController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      new FlatButton(
                          onPressed: () {
                            _yearController.clear();
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          child: new Icon(Icons.clear))
                    ])
              ],
            ),
          ),
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
                wPassword,
                Divider(),
                wSex,
                wAge,
                new Container(
                    padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                    child: new RaisedButton(
                      child: const Text('Guardar cambios'),
                      onPressed: null,
                    )),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildForm());
  }
}
