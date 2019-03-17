import 'package:flutter/material.dart';
import 'package:selit/models/usuario_model.dart';
import 'package:selit/widgets/profile_picture.dart';

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

  /// Usuario a mostrar en el perfil
  UsuarioModel _user;

  /// Constructor: mostrar el usuario _user
  _EditProfileState(this._user);

  /// Widget correspondiente a la edición del perfil del usuario _user
  /// Si un campo de _user es nulo, se muestran los campos por defecto
  Widget _buildForm() {
    // wDataTop
    // wLocation
    // wPassword
    // wSex
    // wAge

    Widget wDataTop = Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Container(
            margin: EdgeInsets.only(left: 10, bottom: 5),
            //color: Colors.red, // util para ajustar margenes
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 50),
                  child: ProfilePicture(_user.urlPerfil),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, left: 25),
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(5),
                        child: Icon(Icons.edit),
                      ),
                      new Text('Editar')
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
              margin: EdgeInsets.only(left: 25, right: 10, bottom: 35),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                    ),
                    controller: _nameController,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Apellidos',
                    ),
                    controller: _surnameController,
                    keyboardType: TextInputType.datetime,
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
          flex: 8,
          child: Container(
            margin: EdgeInsets.only(left: 25),
            //color: Colors.red, // util para ajustar margenes
            child: Column(
              children: <Widget>[
                new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Sexo',
                    labelText: 'Sexo',
                  ),
                  controller: _sexController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
              margin: EdgeInsets.only(left: 25, right: 10, top: 30),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(5),
                    child: Icon(Icons.delete),
                  ),
                ],
              )),
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
            child: Column(
              children: <Widget>[
                new TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Edad',
                    labelText: 'Edad',
                  ),
                  controller: _yearController,
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
              margin: EdgeInsets.only(left: 25, right: 10, top: 30, bottom: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(5),
                    child: Icon(Icons.delete),
                  ),
                ],
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
