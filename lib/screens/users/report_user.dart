import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:selit/widgets/profile_picture.dart';
import 'package:selit/widgets/star_rating.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Pantalla para realizar informe sobre otro usuario
/// Formulario que informa sobre quién es el usuario que se va a reportar,
/// pide una razón por el reporte y permite subir el informe
class ReportUser extends StatefulWidget {
  final UsuarioClass otherUser;

  ReportUser({this.otherUser});
  @override
  State<StatefulWidget> createState() => _ReportUserState(otherUser);
}

class _ReportUserState extends State<ReportUser> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static final _styleTitle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.white);
  static final _styleWarning = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 16.0, color: Colors.white);
  static final TextStyle _styleCardDescription = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black);
  static final _styleButton = TextStyle(fontSize: 19.0, color: Colors.white);

  /// Botones para seleccionar razón
  static final _styleFilterButton =
      TextStyle(fontSize: 18.0, color: Colors.black);

  /// Texto del título del alertdialog
  static final _styleDialogTitle = TextStyle(
      fontSize: 19.0, color: Colors.white, fontWeight: FontWeight.bold);

  /// Texto de los botones del alertdialog, para cuando esta seleccionado y no
  static final _styleDialogButtonsUnselected =
      TextStyle(fontSize: 18.0, color: Colors.white);
  static final _styleDialogButtonsSelected =
      TextStyle(fontSize: 18.0, color: Colors.black);

  final TextEditingController _infoController = new TextEditingController();

  /// Color más oscuro que el rojo principal
  final _blendColor = Color.alphaBlend(Color(0x552B2B2B), Color(0xFFC0392B));
  final Color _colorStatusBarBad = Colors.red.withOpacity(0.5);

  UsuarioClass _otherUser;

  static final List<String> reasons = [
    'Sospecha de fraude',
    'No acudió a la cita',
    'Mal comportamiento',
    'Artículo defectuoso',
    'Otros'
  ];
  // ID razón seleccionada para el reporte
  int _selectedReason;
  Function _sendFunction;

  // Constructor
  _ReportUserState(this._otherUser) {
    _selectedReason = -1;
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
        _selectedReason < 0 ||
        _selectedReason >= reasons.length) {
      showInSnackBar("Rellena todos los campos correctamente", Colors.yellow[800]);
      Navigator.of(context).pop(); // alertDialog
      _sendFunction = _onPressedSend;
    } else {
      UsuarioRequest.reportUser(
              reportedUserId: _otherUser.userId,
              asunto: reasons[_selectedReason],
              desc: _infoController.text)
          .then((_) {
            Navigator.of(context).pop(); // alertDialog
            Navigator.of(context).pop(); // fuera de la pantalla
          })
          .catchError((error) {
            if (error == "Precondition Failed") {
              showInSnackBar("Ya has reportado a este usuario antes", _colorStatusBarBad);
            } else {
              showInSnackBar("Ha ocurrido un problema", _colorStatusBarBad);
            }
            print('Error al reportar usuario: $error');
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

  // Botón que pide "asunto" del reporte
  Widget _buildReasonButton() {
    // Crear la lista con las opciones a elegir
    List<Widget> buttonOptions = [];
    for (var i = 0; i < reasons.length; i++) {
      buttonOptions.add(SizedBox.fromSize(
          size: Size(double.infinity, 40.0),
          child: Container(
              margin: EdgeInsets.all(2),
              child: FlatButton(
                color: _selectedReason == i ? Colors.grey[200] : _blendColor,
                child: Text(reasons[i],
                    style: _selectedReason == i
                        ? _styleDialogButtonsSelected
                        : _styleDialogButtonsUnselected),
                onPressed: () {
                  setState(() => _selectedReason = i);
                  Navigator.of(context).pop();
                },
              ))));
    }

    // Diálogo a mostrar cuando se pulsa el boton
    AlertDialog dialog = AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: _blendColor, width: 2.0),
          borderRadius: BorderRadius.circular(10.0)),
      title: Text('Razón del informe', style: _styleDialogTitle),
      content: Column(mainAxisSize: MainAxisSize.min, children: buttonOptions),
    );

    return RaisedButton(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
                _selectedReason == -1
                    ? 'Selecciona una razón...'
                    : reasons[_selectedReason],
                style: _styleFilterButton),
          ),
          Icon(FontAwesomeIcons.chevronRight, color: Colors.black, size: 16.0),
        ],
      ),
      color: Colors.grey[50],
      onPressed: () =>
          showDialog(context: context, builder: (context) => dialog),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[300], width: 2.0),
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  Widget _buildReportForm() {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.fromLTRB(20.0, 25.0, 0.0, 10.0),
            child: Text('Informe de usuario', style: _styleTitle)),
        SizedBox.fromSize(
          size: Size(double.infinity, 85.0),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: InkWell(
                splashColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                child: FlatButton(
                    onPressed: () => Navigator.of(context).pushNamed('/faq'),
                    color: _blendColor, // sombreado
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Icon(Icons.report_problem,
                              color: Colors.white, size: 35.0),
                        ),
                        Expanded(
                          child: Text(
                            'Por favor consulta las normas antes de realizar cualquier informe',
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: _styleWarning,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.fromLTRB(20.0, 30.0, 0.0, 10.0),
            child: Text('Información del usuario', style: _styleTitle)),
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
        Container(
          margin: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 5.0),
          child: _buildReasonButton(),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
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
                      labelText: 'Descripción del informe',
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
                  child: Text('Enviar informe', style: _styleButton),
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
                  0.42,
                  0.42
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
