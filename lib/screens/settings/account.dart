import 'package:flutter/material.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:selit/util/bar_color.dart';

// Vista temporal con varios botones que llevan a diferentes vistas
// de forma que se pueda acceder a ellas de alguna forma

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  static final _styleTitle = TextStyle(
      fontSize: 22.0, color: Colors.grey[800], fontWeight: FontWeight.bold);

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
          content: new Text("Al eliminar su cuenta se borrará del sistema toda su información."),
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
      UsuarioRequest.delete(miId)
          .then((_) {
        showInSnackBar(
            "Cuenta eliminada correctamente", _colorStatusBarGood);
      }).catchError((error) {
        if (error == "Unauthorized" ||
            error == "Forbidden" ||
            error == "Not Found") {
          showInSnackBar("Acción no autorizada", _colorStatusBarBad);
        }
        else {
          showInSnackBar("No hay conexión a internet", _colorStatusBarBad);
        }
      });
    }
  }

Widget _buildForm() {

  Widget wTitle = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
            margin: EdgeInsets.only(left: 10, top:25),
            child: 
              Padding(
                  padding: EdgeInsets.only(
                    left: 6,
                    top: 15,
                    bottom: 10
                  ),
                  child: Row(children: <Widget>[
                    Row(children: <Widget>[
                      Text('Eliminar cuenta', style: _styleTitle)
                    ]),
                  ]),
                ),
                
            ),
        )
      ],
    );
    Widget wPassword = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
              margin: EdgeInsets.only(left: 30, right: 20, bottom: 20),
              //color: Colors.red, // util para ajustar margenes
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
            child:
            
                new Container(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 55),
                    child: new RaisedButton(
                      color: Color(0xffc0392b),
                      child: const Text('Eliminar cuenta',
                          style: TextStyle(color: Colors.white)),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                wTitle,
                wPassword,
                wButton

              ],
            )));
}
  @override
  Widget build(BuildContext context) {
    BarColor.changeBarColor(color: Colors.transparent, whiteForeground: true);
    return Scaffold(
       key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Cuenta'),
        ),
        body: _buildForm());
  }
}
