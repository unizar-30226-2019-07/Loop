import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/util/api/usuario_request.dart';

/// Pantalla de carga hasta que se puede decidir si existe un
/// usuario registrado en la aplicación (existe un token) y ese token
/// es válido (petición a /users/me)
class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  static const TIMEOUT = const Duration(seconds: 7);

  final _styleLoading = TextStyle(color: Colors.white, fontSize: 18.0);

  /// Devuelve true si existe un token guardado y es válido (es decir,
  /// hay un usuario que ha iniciado sesión en la aplicación)
  /// TODO quitar los print cuando se vea necesario
  Future<bool> _checkForLoggedUser(BuildContext context) async {
    bool legitUser = false;
    String token = await Storage.loadToken();
    if (token == null) {
      print('LOADING: No hay token');
    } else {
      UsuarioClass receivedUser = await UsuarioRequest.getUserById(0);
      if (receivedUser == null) {
        print('LOADING: Había token pero no era válido');
        Storage.deleteToken();
      } else {
        print('LOADING: Usuario registrado');
        print (token);
        legitUser = true;
      }
    }
    return legitUser;
  }

  void _showErrorDialog(BuildContext context) {
    // TODO comprobar si el usuario tiene internet
    AlertDialog dialogo = AlertDialog(
      title: Text('Error al iniciar sesión'),
      content: Text('No se ha podido conectar al servidor'),
      actions: <Widget> [
        // TODO borrar al terminar el debug
        FlatButton(child: Text('Entrar igualmente'), onPressed: () { Navigator.of(context).pushNamed('/principal'); })
      ],
    );
    showDialog(context: context, builder: (context) => dialogo);
  }


  /// Intentar comprobar si hay un usuario logueado,
  /// si no se puede comprobar tras [TIMEOUT] mostrar un mensaje
  /// de alerta indicando que no hay conexión
  @override
  void initState() {
    super.initState();

    _checkForLoggedUser(context).then((legit) {
      Navigator.of(context).pop();
      if (legit) {
        print('Redirect a principal');
        Navigator.of(context).pushNamed('/principal');
      } else {
        print('Redirect a login');
        Navigator.of(context).pushNamed('/login-page');
      }
    }).timeout(TIMEOUT, onTimeout: () {
      _showErrorDialog(context);
    }).catchError((_) {
      _showErrorDialog(context);
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColorLight,
                  Theme.of(context).primaryColorDark,
                ],
                stops: [0.0, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                    strokeWidth: 5.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                Container(
                  margin: EdgeInsets.only(top: 25.0),
                  child: Text('Iniciando sesión...',
                      style: _styleLoading),
                ),
              ],
            ))));
  }
}
