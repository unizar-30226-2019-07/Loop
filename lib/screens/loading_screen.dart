import 'package:flutter/material.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/util/api/usuario_request.dart';

/// Pantalla de carga hasta que se puede decidir si existe un
/// usuario registrado en la aplicación (existe un token)
class LoadingScreen extends StatelessWidget {

  static final TIMEOUT = const Duration(seconds: 5);

  final _styleLoading = TextStyle(color: Colors.white, fontSize: 18.0);

  Future<bool> _checkForLoggedUser(BuildContext context) async {
    Storage.loadToken().then((token) {
      if (token == null) {
        print('LOADING: No hay token');
        return false;
      } else {
        UsuarioRequest.getUserById(0).then((receivedUser) {
          if (receivedUser == null) {
            print('LOADING: Había token pero no era válido');
            Storage.deleteToken();
            return false;
          } else {
            print('LOADING: Usuario registrado');
            return true;
          }
        }).timeout(TIMEOUT, onTimeout: () {
          // TODO diferenciar internet de usuario o de la app
          AlertDialog dialogo = AlertDialog(
            title: Text('Error de red'),
            content: Text('No se ha podido conectar al servidor'),
          );
          showDialog(context: context, builder: (context) => dialogo);
        });
      }
    });
    return false;
  }

  void _checkUser(BuildContext context) async {
    bool legit = await _checkForLoggedUser(context);
    Navigator.of(context).pop();
    if (legit) {
      Navigator.of(context).pushNamed('/principal');
    } else {
      Navigator.of(context).pushNamed('/login-page');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Construyendo laoding');
    _checkUser(context);
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
                children: <Widget>[
                  CircularProgressIndicator(
                      strokeWidth: 5.0,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white)),
                  Text('Intentando conectar con el servidor...',
                      style: _styleLoading),
                ],
              ))));
  }
}
