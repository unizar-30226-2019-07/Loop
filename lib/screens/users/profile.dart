import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
	@override
	ProfileState createState() => new ProfileState();
}

// TODO mover a otro fichero
class UsuarioVO {

  // Atributos a mostrar del usuario en el perfil
  Text nombre;
  Text apellidos;
  dynamic fotoPerfil; // TODO tipo común image-fadeinimage
  Text sexoEdad;
  Text ubicacion;
  double numeroEstrellas;
  Text reviews;

  // Estilos para los diferentes textos
	static final _styleNombre = const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0);
	static final _styleSexoEdad = const TextStyle(fontStyle: FontStyle.italic, fontSize: 15.0);
	static final _styleUbicacion = const TextStyle(fontSize: 15.0);
	static final _styleReviews = const TextStyle(fontSize: 15.0);

  // TODO cargar datos del usuario del JSON
  UsuarioVO(jsonData) {
    nombre = new Text('Nombre', style: _styleNombre, textAlign: TextAlign.left);
    apellidos = new Text('Apellidos', style: _styleNombre, textAlign: TextAlign.left);
    sexoEdad = new Text('Hombre, 21 años', style: _styleSexoEdad, textAlign: TextAlign.left);
    ubicacion = new Text('Zaragoza, España', style: _styleUbicacion, textAlign: TextAlign.left);
    fotoPerfil = FadeInImage.assetNetwork(
      placeholder: 'images/profile_default.jpg',
      image: 'https://avatars0.githubusercontent.com/u/17049331',
      fadeInCurve: Curves.linear,
      fadeInDuration: const Duration(milliseconds: 100),
    );
    numeroEstrellas = 4.5;
    reviews = new Text('30 reviews', style:_styleReviews);
  }

  // Usuario por defecto, para mostrarlo mientras carga
  UsuarioVO.placeholder() {
    nombre = new Text('-----', style: _styleNombre, textAlign: TextAlign.left);
    apellidos = new Text('-----', style: _styleNombre, textAlign: TextAlign.left);
    sexoEdad = new Text('---, ---', style: _styleSexoEdad, textAlign: TextAlign.left);
    ubicacion = new Text('---', style: _styleUbicacion, textAlign: TextAlign.left);
    fotoPerfil = Image.asset(
      'images/profile_default.jpg',
    );
    numeroEstrellas = 0;
    reviews = new Text('---', style:_styleReviews);
  }

}

class ProfileState extends State<Profile> {

  UsuarioVO user = UsuarioVO.placeholder();

  // Perfil por defecto, sin ningún dato
  // Se muestra hasta que se reciban los datos de la petición HTTP
  Widget _buildProfile() {
    Widget widgetStar = Expanded(
      flex: 2,
      child: Icon(Icons.star),
    );

    // TODO mover estrellas a carpeta util
    Widget widgetUserStars = Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            widgetStar,
            widgetStar,
            widgetStar,
            widgetStar,
            widgetStar,
          ],
        )
      ],
    );

    // TODO separar en mas variables?
    Widget widgetUserData = Row(
      children: <Widget>[
        // Foto de perfil y estrellas
        Expanded(
          flex: 4,
          child: Container(
            margin: EdgeInsets.only(left: 25),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: user.fotoPerfil,
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: widgetUserStars
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  child: user.reviews,
                )
              ],
            ),
          ),
        ),
        // Nombre, sexo, edad, ubicación
        Expanded(
          flex: 6,
          child: Container(
            margin: EdgeInsets.only(left: 25, right: 10),
            //color: Colors.red, // util para ajustar margenes
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 30),
                  child: user.nombre,
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 5),
                  child: user.apellidos,
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 10),
                  child: user.sexoEdad
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 15, bottom: 50),
                  child: Row(
                    children: <Widget>[
                      Container(
                        margin:EdgeInsets.all(5),
                        child: Icon(Icons.location_on),
                      ),
                      user.ubicacion,
                    ],
                  ),
                ),
              ],
            )
          ),
        )
      ],
    );

    // TODO completar
    Widget widgetUserProducts = Text('test');

    return Column(
      children: <Widget>[
        // Parte superior: datos del usuario
        widgetUserData,
        Divider(),
        // Parte inferior: objetos en venta y vendidos
        Expanded(
          child: widgetUserProducts,
        )
      ],
    );
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
