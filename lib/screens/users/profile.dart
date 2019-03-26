import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:selit/widgets/star_rating.dart';
import 'package:selit/widgets/profile_picture.dart';
//import 'package:selit/widgets/items/items_list.dart';

/// Perfil de usuario: muestra sus datos, foto de perfil y
/// dos listas: una con los productos en venta y otra con los vendidos
/// Recibe el ID de usuario a mostrar y muestra un perfil por defecto
/// hasta que recibe los datos.
class Profile extends StatefulWidget {
  final int userId;

  /// Página de perfil para el usuario userId
  Profile({@required this.userId});

  @override
  _ProfileState createState() => new _ProfileState(userId);
}

class _ProfileState extends State<Profile> {
  // Estilos para los diferentes textos
  static final _styleNombre = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.black);
  static final _styleSexoEdad = const TextStyle(
      fontStyle: FontStyle.italic, fontSize: 15.0, color: Colors.black);
  static final _styleUbicacion =
      const TextStyle(fontSize: 15.0, color: Colors.black);
  static final _styleReviews =
      const TextStyle(fontSize: 15.0, color: Colors.white);
  static final _textAlignment = TextAlign.left;

  static final _styleTabs =
      const TextStyle(fontSize: 16.0, color: Colors.white);

  /// Usuario a mostrar en el perfil (null = placeholder)
  static UsuarioClass _user;

  _ProfileState(int _userId) {
    _loadProfile(_userId);
  }

  Future<void> _loadProfile(int _userId) async {
    // Mostrar usuario placeholder mientras carga el real
    if (_user == null) {
      UsuarioRequest.getUserById(_userId).then((realUser) {
        setState(() {
          _user = realUser;
        });
      });
    }
  }

  /// Widget correspondiente al perfil del usuario _user
  /// Si un campo de _user es nulo, se muestran los campos por defecto
  Widget _buildProfile() {
    // wTopStack (parte superior junto con botón de edición)
    // wUserData (parte superior)
    // - wUserDataLeft (parte izquierda: foto de perfil, estrellas)
    // - wUserDataRight (parte derecha: nombre, apellidos, etc.)
    // wProductList (parte inferior)
    // - wProductListSelling (parte izquierda: lista de productos en venta)
    // - wProductListSold (parte derecha: lista de productos vendidos)

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
                  child: ProfilePicture(_user?.urlPerfil),
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 10),
                child: StarRating(starRating: _user?.numeroEstrellas ?? 5)),
            Container(
                margin: EdgeInsets.only(top: 5, bottom: 15),
                alignment: Alignment.center,
                child: Text('${_user?.reviews} reviews',
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
                  child: Text(_user?.nombre ?? '---',
                      style: _styleNombre, textAlign: _textAlignment)),
              Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 5),
                  child: Text(_user?.apellidos ?? '---',
                      style: _styleNombre, textAlign: _textAlignment)),
              Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(top: 10),
                  child: Text('${_user?.sexo}, ${_user?.edad} años',
                      style: _styleSexoEdad, textAlign: _textAlignment)),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 15),
                child: Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(2),
                      child: Icon(Icons.location_on, color: Colors.black),
                    ),
                    Text(
                      _user?.ubicacionCiudad ?? '---',
                      style: _styleUbicacion,
                      textAlign: _textAlignment,
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 5, left: 15, bottom: 45),
                child: Text(
                  _user?.ubicacionResto ?? '---',
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
              0.62,
              0.62
            ],
            colors: [
              Colors.grey[100],
              Theme.of(context).primaryColor,
            ]),
      ),
      padding: EdgeInsets.only(top: 30),
      child: Row(children: <Widget>[wUserDataLeft, wUserDataRight]),
    );

    print(_user);

    Widget wTopStack = Stack(children: <Widget>[
      wUserData,
      Positioned(
        right: _user != null ? 10 : -50,
        top: 40,
        child: IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            Navigator.of(context).pushNamed('/edit-profile', arguments: _user);
          },
        ),
      ),
    ]);

    Widget wProductListSelling = ListView.builder(
      padding: EdgeInsets.all(25),
      //itemExtent: 20, <- cuanto mide cada item (?) dice que es más eficiente
      itemBuilder: (BuildContext context, int index) {
        return Text('Producto en venta nº ${index}'); // TODO
      },
    );

    Widget wProductListSold = ListView.builder(
      padding: EdgeInsets.all(25),
      //itemExtent: 20, <- cuanto mide cada item (?) dice que es más eficiente
      itemBuilder: (BuildContext context, int index) {
        return Text('Producto vendido nº ${index}'); // TODO
      },
    );

    // NOTA: la 'sincronizacion rapida' de los cambios de Flutter no
    // suele funcionar con los cambios realizados a las listas,
    // mejor reiniciar del todo
    Widget wProductList = DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: Container(
                color: Theme.of(context).primaryColor,
                child: TabBar(
                  tabs: [Tab(text: 'En venta'), Tab(text: 'Vendidos')],
                  indicatorColor: Colors.grey[200],
                  labelStyle: _styleTabs,
                ))),
        body: TabBarView(
            children: <Widget>[wProductListSelling, wProductListSold]),
      ),
    );

    return Column(
      children: <Widget>[
        wTopStack,
        Expanded(
          child: Container(
            color: Colors.grey[200],
            child: wProductList,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildProfile());
  }
}
