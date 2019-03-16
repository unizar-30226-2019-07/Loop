import 'package:flutter/material.dart';
import 'package:selit/models/usuario_model.dart';

class EditProfile extends StatefulWidget {
  @override
  EditProfileState createState() => new EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _surnameController = new TextEditingController();
  final TextEditingController _locationController = new TextEditingController();
  final TextEditingController _sexController = new TextEditingController();
  final TextEditingController _yearController = new TextEditingController();

  /// Usuario a mostrar en el perfil
  UsuarioModel _user = UsuarioModel.placeholder();

  /// Realiza una petición GET para obtener los datos del usuario
  /// userId y al recibirlos actualiza la edición del perfil para que muestre
  /// los datos de dicho usuario
  Future<void> _loadProfile(userId) async {
    // TODO hacer una petición en lugar de simular una carga de 1 segundo
    return Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _user = new UsuarioModel(
            nombre: 'Nombre',
            apellidos: 'Apellidos',
            sexo: 'Hombre',
            edad: 21,
            ubicacionCiudad: 'Zaragoza',
            ubicacionResto: 'Aragon, España',
            numeroEstrellas: 2.5,
            reviews: 30,
            urlPerfil:
                'https://avatars0.githubusercontent.com/u/17049331'); // TODO modificar por JSON

        _nameController.text = _user.nombre;
        _surnameController.text = _user.apellidos;
        _locationController.text = _user.ubicacionCiudad;
        _sexController.text = _user.sexo;
        _yearController.text = _user.edad.toString();
      });
    });
  }

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
                  child: _user.fotoPerfil,
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
    _loadProfile(1); // TODO sustituir "1" por el ID pasado
    return Scaffold(body: _buildForm());
  }
}
