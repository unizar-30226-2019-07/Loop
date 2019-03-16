import 'package:flutter/material.dart';
import 'package:selit/models/usuario_model.dart';
import 'package:selit/util/star_rating.dart';

/// Perfil de usuario, tal como aparece en el wireframe
/// dividido en dos partes: profile_user (superior) y profile_products (inferior)
class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => new _ProfileState();
}

/* TODO ver https://marcinszalek.pl/flutter/filter-menu-ui-challenge/
 * para el diseño del perfil
class _ProfileClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.lineTo(0.0, size.height - 60.0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
*/

class _ProfileState extends State<Profile> {
  // Estilos para los diferentes textos
  static final _styleNombre = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.white);
  static final _styleSexoEdad = const TextStyle(
      fontStyle: FontStyle.italic, fontSize: 15.0, color: Colors.white);
  static final _styleUbicacion =
      const TextStyle(fontSize: 15.0, color: Colors.white);
  static final _styleReviews =
      const TextStyle(fontSize: 15.0, color: Colors.black);
  static final _textAlignment = TextAlign.left;

  /// Usuario a mostrar en el perfil
  UsuarioModel _user = UsuarioModel.placeholder();

  /// Realiza una petición GET para obtener los datos del usuario
  /// userId y al recibirlos actualiza el perfil para que muestre
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
      });
    });
  }

  /// Widget correspondiente al perfil del usuario _user
  Widget _buildProfile() {
    // wUserData (parte superior)
    // - wUserDataLeft (parte izquierda: foto de perfil, estrellas)
    // - wUserDataRight (parte derecha: nombre, apellidos, etc.)

    Widget wUserDataLeft = Expanded(
      flex: 4,
      child: Container(
        margin: EdgeInsets.only(left: 25),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20),
              child: ClipOval(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: _user.fotoPerfil,
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 10),
                child: StarRating(starRating: _user.numeroEstrellas ?? 5)),
            Container(
                margin: EdgeInsets.only(top: 5, bottom: 15),
                alignment: Alignment.center,
                child: Text('${_user.reviews} reviews',
                    style: _styleReviews, textAlign: _textAlignment))
          ],
        ),
      ),
    );

    Widget wUserDataRight = Expanded(
      flex: 6,
      child: Container(
          margin: EdgeInsets.only(left: 25, right: 10),
          //color: Colors.green, // util para ajustar margenes
          child: Column(
            children: <Widget>[
              Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(top: 15),
                  child: Text(_user.nombre ?? '---',
                      style: _styleNombre, textAlign: _textAlignment)),
              Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 5),
                  child: Text(_user.apellidos ?? '---',
                      style: _styleNombre, textAlign: _textAlignment)),
              Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 10),
                  child: Text('${_user.sexo}, ${_user.edad} años',
                      style: _styleSexoEdad, textAlign: _textAlignment)),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(2),
                      child: Icon(Icons.location_on),
                    ),
                    Text(
                      _user.ubicacionCiudad ?? '---',
                      style: _styleUbicacion,
                      textAlign: _textAlignment,
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 5, bottom: 45),
                child: Text(
                  _user.ubicacionResto ?? '---',
                  style: _styleUbicacion,
                  textAlign: _textAlignment,
                ),
              )
            ],
          )),
    );

    Widget wUserData = Container(
      // TODO seguro que hay alguna forma mejor de añadir un color de fondo
      // que usar un gradiente de este modo, buscar informacion
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [
              0.65,
              0.65
            ],
            colors: [
              Theme.of(context).primaryColor,
              Colors.grey[100],
            ]),
      ),
      padding: EdgeInsets.only(top: 30),
      child: Row(children: <Widget>[wUserDataLeft, wUserDataRight]),
    );

    // TODO completar
    Widget widgetUserProducts = Text('test');

    return Column(
      children: <Widget>[
        wUserData,
        Expanded(
          child: widgetUserProducts,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _loadProfile(1); // TODO sustituir "1" por el ID pasado
    return Scaffold(body: _buildProfile());
  }
}
