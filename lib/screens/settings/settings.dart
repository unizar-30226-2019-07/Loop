import 'package:flutter/material.dart';
import 'package:selit/util/storage.dart';

// Vista temporal con varios botones que llevan a diferentes vistas
// de forma que se pueda acceder a ellas de alguna forma
class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: Text('Ajustes'),
        ),
        body: Container(
            margin: EdgeInsets.all(20),
            child: Column(children: [
              Expanded(
                child: ListView(children: <Widget>[
                  ListTile(
                      leading: Icon(Icons.account_circle),
                      title: Text("Cuenta"),
                      onTap: () {
                        Navigator.of(context).pushNamed('/account');
                      }),
                  ListTile(
                      leading: Icon(Icons.notifications),
                      title: Text("Notificaciones")),
                  ListTile(leading: Icon(Icons.help), title: Text("Ayuda")),
                ]),
              ),
              ButtonTheme(
                minWidth: 150.0,
                child: RaisedButton(
                  color: Color(0xffc0392b),
                  child: const Text('Cerrar sesión',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Storage.deleteToken();
                    print("Sesión cerrada");
                    Navigator.pushReplacementNamed(context, "/login-page");
                  },
                ),
              ),
            ])));
  }
}
