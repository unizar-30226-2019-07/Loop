import 'package:flutter/material.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/util/bar_color.dart';
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
  Future<void> _checkForLoggedUser(BuildContext context) async {
    String token = await Storage.loadToken();
    if (token == null) {
      print('LOADING: No hay token');
      throw ("NOTOKEN");
    } else {
        await UsuarioRequest.getUserById(0);
        print('LOADING: Usuario registrado');
        print (token);
    }
  }

  void _showErrorDialog(BuildContext context) {
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

    _checkForLoggedUser(context).then((_) {
      Navigator.of(context).pop();

        print('Redirect a principal');
        Navigator.of(context).pushReplacementNamed('/principal');

    }).timeout(TIMEOUT, onTimeout: () {
      _showErrorDialog(context);
    }).catchError((error) {

      print('Redirect a login con error: $error');
      Storage.deleteToken();
      Navigator.of(context).pushReplacementNamed('/login-page');
    });

  }

  @override
  Widget build(BuildContext context) {
    BarColor.changeBarColor(
        color: Theme.of(context).primaryColorLight, whiteForeground: true);
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
