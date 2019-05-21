import 'package:flutter/material.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/util/api/usuario_request.dart';

// Vista temporal con varios botones que llevan a diferentes vistas
// de forma que se pueda acceder a ellas de alguna forma

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  static final _styleTitle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.white);
  static final _styleDescription =
      const TextStyle(fontStyle: FontStyle.italic, fontSize: 16.0);
  static final _styleButton = TextStyle(fontSize: 19.0, color: Colors.white);

  final TextEditingController _passController = new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final Color _colorStatusBarGood = Colors.blue.withOpacity(0.5);
  final Color _colorStatusBarBad = Colors.red.withOpacity(0.5);

  void showInSnackBar(String value, Color alfa) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      ),
      backgroundColor: alfa,
      duration: Duration(seconds: 3),
    ));
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("¿Seguro que desea eliminar su cuenta?"),
          content: new Text(
              "Al eliminar su cuenta se borrará del sistema toda su información."),
          actions: <Widget>[
            new FlatButton(
              child: new Text("CANCELAR"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("ACEPTAR"),
              onPressed: () {
                Navigator.of(context).pop();
                cambioPass();
              },
            )
          ],
        );
      },
    );
  }

  void cambioPass() async {
    if (_passController.text.length <= 0) {
      showInSnackBar("Completa todos los campos", Colors.yellow);
    } else {
      int miId = await Storage.loadUserId();
      UsuarioRequest.delete(miId).then((_) {
        showInSnackBar("Cuenta eliminada correctamente", _colorStatusBarGood);
      }).catchError((error) {
        if (error == "Unauthorized" ||
            error == "Forbidden" ||
            error == "Not Found") {
          showInSnackBar("Acción no autorizada", _colorStatusBarBad);
        } else {
          showInSnackBar("No hay conexión a internet", _colorStatusBarBad);
        }
      });
    }
  }

  Widget _buildForm() {
    Widget wPassword = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                    ),
                    controller: _passController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              )),
        )
      ],
    );

    Widget wButton = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
            margin: EdgeInsets.all(20),
            child: new Container(
                padding: const EdgeInsets.only(left: 10.0, bottom: 35.0),
                child: new RaisedButton(
                  color: Color(0xffc0392b),
                  padding: EdgeInsets.symmetric(vertical: 10.0),
                  child: Text('Eliminar cuenta', style: _styleButton),
                  onPressed: () async {
                    _showDialog();
                  },
                )),
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
              children: <Widget>[
                SizedBox.fromSize(
                  size: Size(double.infinity, 90.0),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 30.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment(0.007, -1.0),
                          end: Alignment(-0.007, 1.0),
                          stops: [
                            0.8,
                            0.8
                          ],
                          colors: [
                            Theme.of(context).primaryColor,
                            Colors.grey[100],
                          ]),
                    ),
                    child: Text('Eliminar cuenta', style: _styleTitle),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
                  child: Text(
                      'Para eliminar tu cuenta, introduce tu contraseña de nuevo.',
                      style:
                          _styleDescription.copyWith(color: Colors.grey[600])),
                ),
                wPassword,
                wButton
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        key: _scaffoldKey,
        body: _buildForm());
  }
}
