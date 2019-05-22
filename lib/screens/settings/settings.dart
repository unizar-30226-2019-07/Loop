import 'package:flutter/material.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:selit/util/storage.dart';

// Vista temporal con varios botones que llevan a diferentes vistas
// de forma que se pueda acceder a ellas de alguna forma
class Settings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static final _styleTitle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.white);
  static final _styleButton = TextStyle(fontSize: 19.0, color: Colors.white);
  static final _styleCredits = TextStyle(fontSize: 13.0, color: Colors.grey);
  
  final Color _colorStatusBarGood = Colors.blue.withOpacity(0.5);
  final Color _colorStatusBarBad = Colors.red.withOpacity(0.5);

  Function _functionDownloadData;
  Color _colorDownloadData;

  _SettingsState() {
    _functionDownloadData = _downloadData;
    _colorDownloadData = Colors.grey[300];
  }

  void _downloadData() async {
    setState(() {
      _functionDownloadData = null;
    _colorDownloadData = Colors.grey[400];
    });
    showDialog(
      barrierDismissible: false, // JUST MENTION THIS LINE
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(
                strokeWidth: 5.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
            Container(
                margin: EdgeInsets.only(top: 15.0), child: Text('Cargando...')),
          ],
        ));
      },
    );

      UsuarioRequest.requestData().then((_) {
      showInSnackBar("Revisa tu correo", _colorStatusBarGood);
      Navigator.of(context).pop();
    }).catchError((error) {
      showInSnackBar("Ha ocurrido un problema", _colorStatusBarBad);
      setState(() {
        _functionDownloadData = _downloadData;
        _colorDownloadData = Colors.grey[300];
      });
      Navigator.of(context).pop();
    });
  }

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

  Widget _buildSettings(BuildContext context) {
    return Column(children: [
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
          child: Text('Ajustes', style: _styleTitle),
        ),
      ),
      Expanded(
        child:
        Container(
          margin: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
          child: ListView(children: <Widget>[
            Container(
              margin: EdgeInsets.all(3.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    color: Colors.grey[300],
                    padding: EdgeInsets.all(0.0),
                    child: ListTile(
                        leading: Icon(Icons.info), title: Text("Primeros pasos")),
                  )),
            ),
            Container(
              margin: EdgeInsets.all(3.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.all(0.0),
                      child: ListTile(
                          leading: Icon(Icons.account_circle),
                          title: Text("Eliminar cuenta"),
                          onTap: () {
                            Navigator.of(context).pushNamed('/account');
                          }))),
            ),
            Container(
              margin: EdgeInsets.all(3.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    color: _colorDownloadData,
                    padding: EdgeInsets.all(0.0),
                    child: ListTile(
                        leading: Icon(Icons.cloud_download), title: Text("Descargar mis datos"),
                        onTap: _functionDownloadData),
                  )),
            ),
            Container(
              margin: EdgeInsets.all(3.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                    color: Colors.grey[300],
                    padding: EdgeInsets.all(0.0),
                    child: ListTile(
                        leading: Icon(Icons.help),
                        title: Text("FAQ"),
                        onTap: () {
                            Navigator.of(context).pushNamed('/faq');
                          }),
                  )),
            ),
          ]),
        ),
      ),
      Container(
        margin: EdgeInsets.all(10.0),
        child: Text('Selit! mobile v1.0\n© ALLENSHIP 2019', textAlign: TextAlign.center, style: _styleCredits)
      ),
      Container(
        margin: EdgeInsets.only(bottom: 20.0),
        child: ButtonTheme(
          minWidth: 150.0,
          child: RaisedButton(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            color: Theme.of(context).primaryColor,
            child: Text('Cerrar sesión', style: _styleButton),
            onPressed: () {
              Storage.deleteToken();
              print("Sesión cerrada");
              Navigator.pushReplacementNamed(context, "/login-page");
            },
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _buildSettings(context),
      ),
    );
  }
}
