import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
	@override
	EditProfileState createState() => new EditProfileState();
}

// TODO mover a otro fichero
class UsuarioVO {

  // Atributos a mostrar del usuario en la edición del perfil
  Text nombre;
  Text apellidos;
  dynamic fotoPerfil; // TODO tipo común image-fadeinimage
  Text sexo;
  Text edad;
  Text ubicacion;

  // Estilos para los diferentes textos
	static final _styleNombre = const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0);
	static final _styleSexoEdad = const TextStyle(fontStyle: FontStyle.italic, fontSize: 15.0);
	static final _styleUbicacion = const TextStyle(fontSize: 15.0);
	static final _styleReviews = const TextStyle(fontSize: 15.0);

  // TODO cargar datos del usuario del JSON
  UsuarioVO(jsonData) {
    nombre = new Text('Nombre', style: _styleNombre, textAlign: TextAlign.left);
    apellidos = new Text('Apellidos', style: _styleNombre, textAlign: TextAlign.left);
    sexo = new Text('Hombre', style: _styleSexoEdad, textAlign: TextAlign.left);
    edad = new Text('21', style: _styleSexoEdad, textAlign: TextAlign.left);
    ubicacion = new Text('Zaragoza, España', style: _styleUbicacion, textAlign: TextAlign.left);
    fotoPerfil = FadeInImage.assetNetwork(
      placeholder: 'images/profile_default.jpg',
      image: 'https://avatars0.githubusercontent.com/u/17049331',
      fadeInCurve: Curves.linear,
      fadeInDuration: const Duration(milliseconds: 100),
    );
  }

  // Usuario por defecto, para mostrarlo mientras carga
  UsuarioVO.placeholder() {
    nombre = new Text('-----', style: _styleNombre, textAlign: TextAlign.left);
    apellidos = new Text('-----', style: _styleNombre, textAlign: TextAlign.left);
    sexo = new Text('---', style: _styleSexoEdad, textAlign: TextAlign.left);
    edad = new Text('---', style: _styleSexoEdad, textAlign: TextAlign.left);
    ubicacion = new Text('---', style: _styleUbicacion, textAlign: TextAlign.left);
    fotoPerfil = Image.asset(
      'images/profile_default.jpg',
    );
  }

}

class EditProfileState extends State<EditProfile> {

   final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  UsuarioVO user = UsuarioVO.placeholder();

  Widget _buildForm() {

  Widget widgetUserBasics = Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Container(
            margin: EdgeInsets.only(left: 10, bottom: 5),
            //color: Colors.red, // util para ajustar margenes
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: user.fotoPerfil,
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, left: 25),
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin:EdgeInsets.all(5),
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
            )
          ),
        )
      ],
    );


Widget widgetUserData = Row(
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
            )
          ),
        )
      ],
    );


    Widget widgetUserPass = Row(
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
            )
          ),
        )
      ],
    );

    

  Widget widgetUserSexo = Row(
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
            margin: EdgeInsets.only(left: 25, right: 10,top: 30),
            //color: Colors.red, // util para ajustar margenes
            child: Column(
              children: <Widget>[
               Container(
                 margin:EdgeInsets.all(5),
                 child: Icon(Icons.delete),
              ),
              ],
            )
          ),
        )
      ],
    );

    Widget widgetUserLYear = Row(
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
            margin: EdgeInsets.only(left: 25, right: 10,top: 30, bottom:20),
            //color: Colors.red, // util para ajustar margenes
            child: Column(
              children: <Widget>[
               Container(
                 margin:EdgeInsets.all(5),
                 child: Icon(Icons.delete),
              ),
              ],
            )
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
            widgetUserBasics,
            Divider(),
            widgetUserData,
            Divider(),
            widgetUserPass,
            Divider(),
            widgetUserSexo,
            widgetUserLYear,
            new Container(
                padding: const EdgeInsets.only(left: 10.0, top: 20.0),
                child: new RaisedButton(
                  child: const Text('Guardar cambios'),
                  onPressed: null,
                )),
          ],
        )));
}


  // Muestra el perfil por defecto e inicia una petición
  // para obtener los datos del usuario userId
  // Cuando recibe los datos, actualiza el perfil
  Future<void> _loadProfile(userId) async {
    // TODO hacer una petición en lugar de simular una carga de 1 segundo
    return Future.delayed(
			Duration(seconds: 1),
      () {
        setState(() {
          user = new UsuarioVO('testData'); // TODO modificar por JSON
          _nameController.text = user.nombre.data;
          _surnameController.text = user.apellidos.data;
          _locationController.text= user.ubicacion.data;
          _sexController.text= user.sexo.data;
          _yearController.text= user.edad.data;
        });
      }
    );
  }

  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _surnameController = new TextEditingController();
  final TextEditingController _locationController = new TextEditingController();
  final TextEditingController _sexController = new TextEditingController();
  final TextEditingController _yearController = new TextEditingController();

  void initState() {
    _nameController.text = user.nombre.data;
    _surnameController.text = user.apellidos.data;
    _locationController.text= user.ubicacion.data;
    _sexController.text= user.sexo.data;
    _yearController.text= user.edad.data;
    return super.initState();
  }

	@override
	Widget build(BuildContext context) {
    _loadProfile(1);
		return Scaffold(
			appBar: AppBar(
				title: const Text('Editar Perfil'),
			),
			body: _buildForm(),
		);
	}

}
