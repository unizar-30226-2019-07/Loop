import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/widgets/profile_picture.dart';
import 'package:selit/widgets/star_rating.dart';
import 'package:selit/util/bar_color.dart';

/// Pantalla para calificar otro usuario, con información sobre el
/// usuario que va a ser calificado, un número de estrellas entre 1 y 5
/// y un comentario adicional sobre la calificación.
/// Con estos campos establecen un formulario a enviar
class RateUser extends StatefulWidget {
  final UsuarioClass otherUser;

  RateUser({this.otherUser});
  @override
  State<StatefulWidget> createState() => _RateUserState(otherUser);
}

class _RateUserState extends State<RateUser> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static final _styleTitle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.white);
  static final _styleWarning = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white);
  static final TextStyle _styleCardDescription = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black);
  static final _styleButton = TextStyle(fontSize: 19.0, color: Colors.white);

  final TextEditingController _infoController = new TextEditingController();

  /// Color más oscuro que el rojo principal
  final _blendColor = Color.alphaBlend(Color(0x552B2B2B), Color(0xFFC0392B));

  UsuarioClass _otherUser;

  // Constructor
  _RateUserState(this._otherUser);

  void _onPressedSend() {
    if (_infoController.text == '') {
      showInSnackBar("Rellena todos los campos correctamente", Colors.yellow);
    } else {
      print('Usuario con id ${_otherUser.userId} con razón ${_infoController.text}');
    }
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

  Widget _buildReportForm() {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.fromLTRB(20.0, 25.0, 0.0, 10.0),
            child: Text('Calificar usuario', style: _styleTitle)),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 25.0),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.grey[300], width: 2.0)),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox.fromSize(
                  size: Size(100.0, 100.0),
                  child: Container(
                    padding: EdgeInsets.all(2.0),
                    child: ProfilePicture(_otherUser.profileImage),
                  ),
                ),
                Expanded(
                  child: Container(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Text(
                              _otherUser.nombre + ' ' + _otherUser.apellidos,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _styleCardDescription,
                            ),
                          ),
                          Container(
                              child: StarRating(
                            starRating: _otherUser.numeroEstrellas ?? 1,
                            starColor: Colors.black,
                            profileView: false,
                            starSize: 20.0,
                          )),
                        ],
                      )),
                )
              ],
            ),
          ),
        ),
        SizedBox.fromSize(
          size: Size(double.infinity, 90.0),
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              child: StarRating(profileView: true, starRating: 5.0, starColor: Colors.yellow[800], starSize: 50.0,),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              color: Colors.grey[300],
              padding: EdgeInsets.all(2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  color: Colors.grey[50],
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Comentario adicional (opcional)',
                      alignLabelWithHint: true,
                    ),
                    maxLength: 300,
                    controller: _infoController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Container(
            margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
            child: RaisedButton(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 20.0),
              child: Text('Calificar usuario', style: _styleButton),
              onPressed: _onPressedSend,
            ))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    BarColor.changeBarColor(color: Colors.transparent, whiteForeground: true);
    return Stack(children: <Widget>[
      Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment(0.10, -1.0),
                end: Alignment(-0.10, 1.0),
                stops: [
                  0.5,
                  0.5
                ],
                colors: [
                  Theme.of(context).primaryColor,
                  Colors.grey[100],
                ]),
          ),
        ),
      ),
      Scaffold(
          resizeToAvoidBottomInset: true,
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: _buildReportForm(),
          )),
    ]);
  }
}
