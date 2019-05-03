import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selit/util/bubble_indication_painter.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:selit/util/bar_color.dart';
import 'package:location/location.dart';

import 'package:selit/screens/debug_main.dart';

final int splashDuration = 2;
double locationLat, locationLng;

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  final FocusNode myFocusNodePassword = FocusNode();
  final FocusNode myFocusNodeEmail = FocusNode();
  final FocusNode myFocusNodeName = FocusNode();
  final FocusNode myFocusNodeLastName = FocusNode();

  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();

  IconData _eyeOpen = FontAwesomeIcons.eye;
  IconData _eyeSlash = FontAwesomeIcons.eyeSlash;

  IconData _eyeLogin = FontAwesomeIcons.eye;
  IconData _eyeSignup = FontAwesomeIcons.eye;
  IconData _eyeSignupConfirm = FontAwesomeIcons.eye;
  bool _obscureTextLogin = true;
  bool _obscureTextSignup = true;
  bool _obscureTextSignupConfirm = true;

  static double heightLogin = 550.0;
  static double heightSignup = 850.0;
  double varHeight = heightLogin;

  TextEditingController signupEmailController = new TextEditingController();
  TextEditingController signupNameController = new TextEditingController();
  TextEditingController signupLastNameController = new TextEditingController();
  TextEditingController signupPasswordController = new TextEditingController();
  TextEditingController signupConfirmPasswordController =
      new TextEditingController();

  PageController _pageController;

  Color left = Colors.black;
  Color right = Colors.white;

  final Color _colorStatusBarGood = Colors.blue.withOpacity(0.5);
  final Color _colorStatusBarBad = Colors.red.withOpacity(0.5);

  /// Espera un tiempo mientras indica al usuario que ha iniciado
  /// sesión correctamente y luego lo redirige a la pantalla principal
  Future<void> _delayPrincipal() async {
    return Timer(Duration(seconds: splashDuration), () {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      Navigator.of(context).pushNamed('/principal');
    });
  }

  /// Intenta hacer login de un usuario con email y contraseña
  /// según lo escrito en los campos de texto
  /// Si se loguea correctamente, se almacena el token, se informa al usuario
  /// y se redirige a la pantalla [Principal]
  /// Si no se loguea correctamente, muestra un aviso al usuario de que
  /// no se ha podido iniciar sesión correctamente
  void _tryLogin() async {
    UsuarioRequest.login(
            loginEmailController.text, loginPasswordController.text)
        .then((loginToken) {
      if (loginToken != null) {
        // login incorrecto
        showInSnackBar("Iniciando sesión", _colorStatusBarGood);
        _delayPrincipal();
      }
    }).catchError((error) {
      if (error == "Unauthorized") {
        showInSnackBar("La cuenta no es válida", _colorStatusBarBad);
      } else if (error == "Forbidden") {
        showInSnackBar("Usuario o contraseña incorrectos", _colorStatusBarBad);
      } else {
        showInSnackBar(
            "Ha ocurrido un error en el servidor", _colorStatusBarBad);
      }
    });
  }

  Function _signUpCallback;
  Color _signUpButtonColor = Colors.grey[800]; // Desactivado

  /// Hacer registro de usuario con los campos del formulario
  /// Si el registro es correcto, se realiza una petición con los datos
  /// introducidos en el formulario y se informa al usuario del resultado
  /// Si el registro no es correcto, se muestra al usuario el
  /// error cometido (contraseñas no coinciden, etc.)
  void _trySignUp() async {
    // Validar campos de registro
    // Contraseñas coinciden
    if (signupPasswordController.text != signupConfirmPasswordController.text) {
      showInSnackBar("Las contraseñas no coinciden", Colors.yellow);
      return;
    }
    // Campos no nulos y válidos
    if (signupLastNameController.text.length < 1 ||
        signupNameController.text.length < 1 ||
        !validateEmail(signupEmailController.text)) {
      showInSnackBar("Rellena toodos los campos correctamente", Colors.yellow);
      return;
    }

    // Crear un objeto de la clase UsuarioClass para pasar datos de usuario
    UsuarioClass registeredUser = new UsuarioClass(
      nombre: signupNameController.text,
      apellidos: signupLastNameController.text,
      email: signupEmailController.text,
      locationLat: locationLat,
      locationLng: locationLng,
    );

    // Realizar la petición de inicio de sesión e informar al usuario del resultado
    UsuarioRequest.signUp(registeredUser, signupPasswordController.text)
        .then((_) => showInSnackBar(
            "Se ha enviado un correo de confirmación", _colorStatusBarGood))
        .catchError((error) {
      if (error == "Conflict") {
        showInSnackBar("La dirección de correo ya existe", _colorStatusBarBad);
      } else {
        showInSnackBar("No hay conexión a internet", _colorStatusBarBad);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    BarColor.changeBarColor(
        color: Theme.of(context).primaryColorLight, whiteForeground: true);
    return new Scaffold(
      key: _scaffoldKey,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height >= varHeight //850.0
                  ? MediaQuery.of(context).size.height
                  : varHeight,
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                    colors: [
                      Theme.of(context).primaryColorLight,
                      Theme.of(context).primaryColorDark,
                    ],
                    begin: const FractionalOffset(0.0, 0.0),
                    end: const FractionalOffset(1.0, 1.0),
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    alignment: FractionalOffset(1.0, 0.0),
                    child: GestureDetector(
                      onTap: () {
                        // TODO X de la esquina superior derecha de la pantalla
                        // ya no debería estar, no se usa
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => DebugMain()),
                        );
                      },
                      child: Icon(
                        FontAwesomeIcons.times,
                        size: 40.0,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: new Image(
                        width: 150.0,
                        height: 177.0,
                        fit: BoxFit.fill,
                        image: new AssetImage('assets/img/sell.png')),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: _buildMenuBar(context),
                  ),
                  Expanded(
                    flex: 2,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (i) async {
                        if (i == 0) {
                          setState(() {
                            varHeight = heightLogin;
                            right = Colors.white;
                            left = Colors.black;
                          });
                        } else if (i == 1) {
                          Location locationService = new Location();
                          // Intentar obtener la localización del usuario
                          try {
                            LocationData data =
                                await locationService.getLocation();
                            locationLat = data.latitude;
                            locationLng = data.longitude;
                            setState(() {
                              _signUpCallback = _trySignUp;
                              _signUpButtonColor =
                                  Theme.of(context).primaryColorDark;
                            });
                          } on PlatformException catch (_) {
                            showInSnackBar(
                                "Es necesaria la localización", Colors.red);
                          }

                          setState(() {
                            varHeight = heightSignup;
                            right = Colors.black;
                            left = Colors.white;
                          });
                        }
                      },
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints.expand(),
                          child: _buildSignIn(context),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints.expand(),
                          child: _buildSignUp(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    myFocusNodePassword.dispose();
    myFocusNodeEmail.dispose();
    myFocusNodeName.dispose();
    myFocusNodeLastName.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
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

  Widget _buildMenuBar(BuildContext context) {
    return Container(
      width: 300.0,
      height: 50.0,
      decoration: BoxDecoration(
        color: Color(0x552B2B2B),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: CustomPaint(
        painter: TabIndicationPainter(pageController: _pageController),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignInButtonPress,
                child: Text(
                  "Iniciar sesión",
                  style: TextStyle(color: left, fontSize: 16.0),
                ),
              ),
            ),
            //Container(height: 33.0, width: 1.0, color: Colors.white),
            Expanded(
              child: FlatButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onPressed: _onSignUpButtonPress,
                child: Text(
                  "Crear cuenta",
                  style: TextStyle(color: right, fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignIn(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 190.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeEmailLogin,
                          controller: loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: "Correo electrónico",
                            hintStyle: TextStyle(fontSize: 17.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePasswordLogin,
                          controller: loginPasswordController,
                          obscureText: _obscureTextLogin,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              size: 22.0,
                              color: Colors.black,
                            ),
                            hintText: "Contraseña",
                            hintStyle: TextStyle(fontSize: 17.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                _eyeLogin,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 170.0),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Theme.of(context).primaryColorLight,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: Theme.of(context).primaryColorDark,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: new LinearGradient(
                      colors: [
                        Theme.of(context).primaryColorDark,
                        Theme.of(context).primaryColorLight,
                      ],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                  highlightColor: Colors.transparent,
                  splashColor: Theme.of(context).primaryColorDark,
                  //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 42.0),
                    child: Text(
                      "ACCEDER",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontFamily: "NunitoBold"),
                    ),
                  ),
                  onPressed: _tryLogin,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
                onPressed: () {},
                child: Text(
                  "He olvidado mi contraseña",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 16.0,
                      fontFamily: "Nunito"),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUp(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  height: 450.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeName,
                          controller: signupNameController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.user,
                              color: Colors.black,
                            ),
                            hintText: "Nombre",
                            hintStyle: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeLastName,
                          controller: signupLastNameController,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.words,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.user,
                              color: Colors.black,
                            ),
                            hintText: "Apellidos",
                            hintStyle: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeEmail,
                          controller: signupEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.envelope,
                              color: Colors.black,
                            ),
                            hintText: "Correo electrónico",
                            hintStyle: TextStyle(fontSize: 16.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePassword,
                          controller: signupPasswordController,
                          obscureText: _obscureTextSignup,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              color: Colors.black,
                            ),
                            hintText: "Contraseña",
                            hintStyle: TextStyle(fontSize: 16.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignup,
                              child: Icon(
                                _eyeSignup,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                        child: TextField(
                          controller: signupConfirmPasswordController,
                          obscureText: _obscureTextSignupConfirm,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              color: Colors.black,
                            ),
                            hintText: "Confirmar contraseña",
                            hintStyle: TextStyle(fontSize: 16.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleSignupConfirm,
                              child: Icon(
                                _eyeSignupConfirm,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 430.0),
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: _signUpButtonColor,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: _signUpButtonColor,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                ),
                child: MaterialButton(
                    color: _signUpButtonColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "UNIRSE",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                            fontFamily: "NunitoBold"),
                      ),
                    ),
                    onPressed: _signUpCallback),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSignInButtonPress() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _onSignUpButtonPress() {
    _pageController?.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.decelerate);
  }

  void _toggleLogin() {
    setState(() {
      if (_obscureTextLogin) {
        _eyeLogin = _eyeSlash;
      } else {
        _eyeLogin = _eyeOpen;
      }
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  void _toggleSignup() {
    setState(() {
      if (_obscureTextSignup) {
        _eyeSignup = _eyeSlash;
      } else {
        _eyeSignup = _eyeOpen;
      }
      _obscureTextSignup = !_obscureTextSignup;
    });
  }

  void _toggleSignupConfirm() {
    setState(() {
      if (_obscureTextSignupConfirm) {
        _eyeSignupConfirm = _eyeSlash;
      } else {
        _eyeSignupConfirm = _eyeOpen;
      }
      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
    });
  }
}

bool validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value))
    return false;
  else
    return true;
}
