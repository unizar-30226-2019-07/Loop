import 'package:flutter/material.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:selit/widgets/profile_picture.dart';
import 'package:selit/widgets/star_rating.dart';
import 'package:selit/widgets/star_rating_interactive.dart';

/// Pantalla para calificar otro usuario, con información sobre el
/// usuario que va a ser calificado, un número de estrellas entre 1 y 5
/// y un comentario adicional sobre la calificación.
/// Con estos campos establecen un formulario a enviar
class RateUser extends StatefulWidget {
  final ItemClass referencedItem;

  RateUser({this.referencedItem});
  @override
  State<StatefulWidget> createState() => _RateUserState(referencedItem);
}

class _RateUserState extends State<RateUser> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static final _styleTitle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.white);
  static final TextStyle _styleCardDescription = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black);
  static final TextStyle _styleCardProduct = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.black);
  static final TextStyle _styleStarTitle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.grey);
  static final _styleButton = TextStyle(fontSize: 19.0, color: Colors.white);

  StarRatingInteractive _starRating = new StarRatingInteractive(
    starColor: Colors.yellow[800],
    starSize: 50.0,
  );
  final TextEditingController _infoController = new TextEditingController();

  /// Color más oscuro que el rojo principal
  final Color _colorStatusBarBad = Colors.red.withOpacity(0.5);

  ItemClass _referencedItem;
  Function _sendFunction;

  // Constructor
  _RateUserState(this._referencedItem) {
    assert(_referencedItem.owner != null, "El dueño no debe ser null");
    _sendFunction = _onPressedSend;
  }

  void _onPressedSend() {
    // Diálogo "cargando..." para evitar repetir
    _sendFunction = null;
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

    if (_infoController.text == '' ||
        StarRatingInteractive.currentRating < 1 ||
        StarRatingInteractive.currentRating > 5) {
      showInSnackBar("Rellena todos los campos correctamente", Colors.yellow);
      Navigator.of(context).pop(); // alertDialog
      _sendFunction = _onPressedSend;
    } else {
      UsuarioRequest.rateUser(
              producto: _referencedItem,
              estrellas: StarRatingInteractive.currentRating,
              comentario: _infoController.text)
          .then((_) {
        Navigator.of(context).pop(); // alertDialog
        Navigator.of(context).pop(); // fuera de la pantalla
      }).catchError((error) {
        if (error == "Precondition Failed") {
          showInSnackBar(
              "Ya has valorado a este usuario antes", _colorStatusBarBad);
        } else {
          showInSnackBar("Ha ocurrido un problema", _colorStatusBarBad);
        }
        print('Error al valorar usuario: $error');
        Navigator.of(context).pop(); // alertDialog
        _sendFunction = _onPressedSend;
      });
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

  Widget _buildRateForm() {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.fromLTRB(20.0, 25.0, 0.0, 10.0),
            child: Text('Calificar una venta', style: _styleTitle)),
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
                    child: ProfilePicture(_referencedItem.owner.profileImage),
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
                              _referencedItem.owner.nombre +
                                  ' ' +
                                  _referencedItem.owner.apellidos,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _styleCardDescription,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 5.0),
                            child: Text(
                              _referencedItem.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _styleCardProduct,
                            ),
                          ),
                          Container(
                              child: StarRating(
                            starRating:
                                _referencedItem.owner?.numeroEstrellas ?? 1,
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
        Container(
            margin: EdgeInsets.fromLTRB(20.0, 30.0, 0.0, 0.0),
            child: Text('Tu valoración', style: _styleTitle)),
        Container(
          margin: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              color: Colors.grey[300],
              padding: EdgeInsets.all(2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Container(
                  color: Colors.grey[50],
                  padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      children: <Widget>[
                        Text('¿Cómo valorarías a este vendedor?',
                              style: _styleStarTitle),
                        _starRating
                      ],
                    ),
                  ),
                ),
              ),
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
                      labelText: 'Añade un comentario (opcional)',
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
                  padding:
                      EdgeInsets.symmetric(vertical: 7.0, horizontal: 20.0),
                  child: Text('Calificar usuario', style: _styleButton),
                  onPressed: _sendFunction,
                ))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
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
            child: _buildRateForm(),
          )),
    ]);
  }
}
