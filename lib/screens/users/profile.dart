import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
	@override
	ProfileState createState() => new ProfileState();
}

class UsuarioVO {
  Text nombre;
  Text apellidos;
  dynamic fotoPerfil; // TODO tipo común image-fadeinimage
  Text sexoEdad;
  Text ubicacion;

  UsuarioVO(jsonData) {
    nombre = new Text('Nombre');
    apellidos = new Text('Apellidos');
    sexoEdad = new Text('Hombre, 21 años');
    ubicacion = new Text('Zaragoza, España');
    fotoPerfil = FadeInImage.assetNetwork(
      placeholder: 'images/profile_default.jpg',
      image: 'https://avatars0.githubusercontent.com/u/17049331',
      fadeInCurve: Curves.linear,
      fadeInDuration: const Duration(milliseconds: 300),
      width: 50,
    );
  }

  UsuarioVO.placeholder() {
    nombre = new Text('---');
    apellidos = new Text('---');
    sexoEdad = new Text('---');
    ubicacion = new Text('---');
    fotoPerfil = Image.asset(
      'images/profile_default.jpg',
      width: 50,
    );
  }

}

class ProfileState extends State<Profile> {

  UsuarioVO user = UsuarioVO.placeholder();

  // Perfil por defecto, sin ningún dato
  // Se muestra hasta que se reciban los datos de la petición HTTP
  Widget _buildProfile() {
    return Column(
      children: <Widget>[
        // Parte superior: datos del usuario
        Row(
          children: <Widget>[
            // Foto de perfil y estrellas
            Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(30),
                  child: user.fotoPerfil,
                ),
              ],
            ),
            // Nombre, sexo, edad, ubicación
            Column(
              children: <Widget>[
                user.nombre,
                user.apellidos,
                user.sexoEdad,
                Row(
                  children: <Widget>[
                    Icon(Icons.location_on),
                    user.ubicacion,
                  ],
                ),
              ],
            )
          ],
        ),
        // Parte inferior: objetos en venta y vendidos
        //Column(),
      ],
    );
  }

  // Muestra el perfil por defecto e inicia una petición
  // para obtener los datos del usuario userId
  // Cuando recibe los datos, actualiza el perfil
  Future<void> _loadProfile(userId) async {
    // TODO hacer una petición en lugar de simular una carga de 1 segundo
    return Future.delayed(
			Duration(seconds: 2),
      () {
        setState(() {
          user = new UsuarioVO('testData');
        });
      }
    );
  }

	@override
	Widget build(BuildContext context) {
    _loadProfile(1);
		return Scaffold(
			appBar: AppBar(
				title: const Text('Perfil'),
			),
			body: _buildProfile(),
		);
	}

}
