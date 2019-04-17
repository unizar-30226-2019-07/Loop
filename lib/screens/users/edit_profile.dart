import 'dart:io';
import 'dart:async';
import 'package:geocoder/geocoder.dart';
import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/image_class.dart';
import 'package:selit/widgets/profile_picture.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

/// Página de edición de perfil (formulario con los campos
/// necesarios para modificar los atributos del usuario)
/// Recibe el UsuarioClass del usuario a editar y, una vez terminado
/// de editar, realiza una petición para actualizar dichos cambios
class EditProfile extends StatefulWidget {
  final UsuarioClass user;

  /// UsuarioClass del usuario a editar
  EditProfile({@required this.user});

  @override
  _EditProfileState createState() => new _EditProfileState(user);
}

class _EditProfileState extends State<EditProfile> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _surnameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _sexController = new TextEditingController();
  final TextEditingController _oldPassController = new TextEditingController();
  final TextEditingController _newPassController = new TextEditingController();
  final TextEditingController _newPassRepController =
      new TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static final _styleTitle = TextStyle(
      fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.bold);
  static final _styleText = TextStyle(
      fontSize: 17.0, color: Colors.black);
  static final _styleButton = TextStyle(
      fontSize: 19.0, color: Colors.white);
  static final _styleAgeTitle = TextStyle(
      fontSize: 14.0, color: Colors.grey[600], fontWeight: FontWeight.bold);

  /// Texto del título del alertdialog
  static final _styleDialogTitle = TextStyle(
      fontSize: 19.0, color: Colors.black, fontWeight: FontWeight.w600);
  static final _styleDialogAccept =
      TextStyle(fontSize: 19.0, color: Colors.white, fontWeight: FontWeight.bold); // color rojo
  static final _styleDialogCancel = TextStyle(
      fontSize: 19.0, color: Colors.grey[600], fontWeight: FontWeight.bold);
  static final _styleLocationButton = TextStyle(
      fontSize: 17.0, color: Colors.blue[600], fontWeight: FontWeight.bold);

  final Color _colorStatusBarGood = Colors.blue.withOpacity(0.5);
  final Color _colorStatusBarBad = Colors.red.withOpacity(0.5);

  /// Usuario a mostrar en el perfil
  UsuarioClass _user;

  /// Fecha de nacimiento
  DateTime _selectedDate;

  /// Ubicación del usuario (nombre del sitio)
  String _ubicacionCiudad;
  String _ubicacionResto;

  /// Uso de mapas para seleccionar ubicación
  Completer<GoogleMapController> _controller = Completer();
  LatLng _userPosition; // la de UsuarioClass
  LatLng _selectedPosition; // la seleccionada en el mapa
  Marker _positionMarker; // marcador de posición del usuario en el mapa
  CameraPosition _cameraPosition; // posicion inicial al abrir el mapa

  //Lista opciones sexo
  List<String> _sexos = <String>['', 'hombre', 'mujer', 'otro'];
  String _sexo = '';

  ImageClass _displayImage;

  /// Constructor: mostrar el usuario _user
  _EditProfileState(UsuarioClass _user) {
    this._user = _user;
    _nameController.text = _user.nombre;
    _surnameController.text = _user.apellidos;
    _userPosition = LatLng(_user.locationLat, _user.locationLng);
    _cameraPosition = CameraPosition(
      target: _userPosition,
      zoom: 15,
    );
    _positionMarker =
        Marker(markerId: MarkerId("Home"), position: _userPosition);
    _emailController.text = _user.email;
    _sexController.text = _user.sexo;
    _selectedDate = _user.nacimiento;
    _sexo = _user.sexo;
    _displayImage = _user.profileImage;
    _loadCoordinates();
  }

  String _nacimientoString(DateTime fecha) {
    return '${fecha.day} / ${fecha.month} / ${fecha.year}';
  }

  void _loadCoordinates() async {
    if (_user?.locationLat != null && _user?.locationLng != null) {
      final coordinates = new Coordinates(_user.locationLat, _user.locationLng);
      try{
        var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      if (addresses.length > 0) {
        setState(() {
          _ubicacionCiudad = addresses.first.locality;
          _ubicacionResto = addresses.first.countryName;
        });
      }
      }catch(e){
        print('Error al obtener addresses: '+ e.toString());
      }
      
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

  void updateUser() {
    if (_nameController.text.length < 1 || _surnameController.text.length < 1 || _emailController.text.length < 1) {
      showInSnackBar("Rellena todos los campos correctamente", Colors.yellow);
    } else {
      _user.update(
          nombre: _nameController.text,
          apellidos: _surnameController.text,
          sexo: _sexo,
          email: _emailController.text,
          locationLat: _user.locationLat,
          locationLng: _user.locationLng,
          nacimiento: _selectedDate,
          image: _displayImage);
      UsuarioRequest.editUser(_user).then((_) {
          showInSnackBar("Datos actualizados correctamente", _colorStatusBarGood);
      }).catchError((error) {
        if (error == "Unauthorized" || error == "Forbidden") {
          showInSnackBar("Acción no autorizada", _colorStatusBarBad);
        } else if (error == "Not Found") {
          showInSnackBar("Usuario no encontrado", _colorStatusBarBad);
        } else {
          showInSnackBar("No hay conexión a Internet", _colorStatusBarBad);
        }
      });
    }
  }

  void cambioPass() async {
    if (_newPassController.text != _newPassRepController.text) {
      showInSnackBar("Las contraseñas no coinciden", Colors.yellow);
    } else if (_newPassController.text.length <= 0 ||
        _newPassRepController.text.length <= 0 ||
        _oldPassController.text.length <= 0) {
      showInSnackBar("Completa todos los campos", Colors.yellow);
    } else {
      int miId = await Storage.loadUserId();
      UsuarioRequest.password(
              _oldPassController.text, _newPassController.text, miId)
          .then((_) {
        showInSnackBar(
            "Contraseña actualizada correctamente", _colorStatusBarGood);
      }).catchError((error) {
        if (error == "Unauthorized" ||
            error == "Forbidden" ||
            error == "Not Found") {
          showInSnackBar("Acción no autorizada", _colorStatusBarBad);
        } else if (error == "Precondition Failed") {
          showInSnackBar("Contraseña incorrecta", _colorStatusBarBad);
        } else {
          showInSnackBar("No hay conexión a internet", _colorStatusBarBad);
        }
      });
    }
  }

  /// Actualizar SOLO LOCALMENTE la ubicación de usuario
  /// para guardar cambios deberá pulsar el boton de "Guardar Cambios"
  void _updateLocation() {
    try{
      double newLat = _selectedPosition.latitude;
      double newLng = _selectedPosition.longitude;
      setState(() {
        _userPosition = LatLng(newLat, newLng);
        _cameraPosition = CameraPosition(
          target: _userPosition,
          zoom: 15,
        );
        _positionMarker = Marker(markerId: MarkerId("Home"), position: _selectedPosition);
        _loadCoordinates();
      });
    }catch(e){
      print('Error al guardar las coordenadas seleccionadas: ' + e.toString());
    } 
  }

  /// Cuadro de diálogo para seleccionar ubicación de usuario
  Widget _buildLocationDialog() {
    Widget wMapStack = Stack(
      children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _cameraPosition,
          myLocationEnabled: true,
          onCameraMove: (controller) => _selectedPosition = controller.target,
          onMapCreated: (GoogleMapController controller) {
            if (!_controller.isCompleted) {
              _controller.complete(controller);
            }
          },
          markers: Set<Marker>()..add(_positionMarker),
        ),
        Positioned(
          right: 5,
          bottom: 5,
          child: RaisedButton(
            color: Colors.white,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onPressed: () async {
              GoogleMapController mapController = await _controller.future;
              CameraPosition zoomPosition = CameraPosition(
                target: _cameraPosition.target,
                zoom: 17
              );
              mapController.animateCamera(
                  CameraUpdate.newCameraPosition(zoomPosition));
            },
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 5),
                  child: Icon(Icons.location_on, color: Colors.blue[600]),
                ),
                Text('Volver', style: _styleLocationButton),
              ],
            ),
          ),
        ),
        Center(
            child: Container(
          padding: EdgeInsets.only(bottom: 47),
          child: Icon(FontAwesomeIcons.mapMarkerAlt,
              size: 40.0, color: Colors.red),
        )),
      ],
    );

    return AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 5.0),
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[400], width: 2.0),
            borderRadius: BorderRadius.circular(10.0)),
        title: Text('Selecciona tu ubicación', style: _styleDialogTitle),
        content: SizedBox.fromSize(
            size: Size(double.infinity, 300.0),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                    padding: EdgeInsets.all(2.0),
                    color: Colors.grey[400],
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: wMapStack)))),
        actions: <Widget>[
          RaisedButton(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              onPressed: () {
                _updateLocation();
                Navigator.of(context).pop();
              },
              child: Text('Aceptar',
                  style: _styleDialogAccept)),
          FlatButton(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar', style: _styleDialogCancel))
        ]);
  }

  /// Abrir el cuadro de diálogo que pide ubicación
  void _openLocationDialog() {
    _controller = Completer<GoogleMapController>();
    showDialog(context: context, builder: (context) => _buildLocationDialog());
  }

  /// Widget correspondiente a la edición del perfil del usuario _user
  /// Si un campo de _user es nulo, se muestran los campos por defecto
  Widget _buildForm() {
    // wDataTop
    // wLocation
    // wPassword
    // wSex
    // wAge

    //Selección de foto de galería
    imageSelectorGallery() async {
      File pickedFile = await ImagePicker.pickImage(
        source: ImageSource.gallery,
      );
      setState(() {
        if (pickedFile != null) {
          _displayImage = ImageClass.file(fileImage: pickedFile);
        }
      });
    }

    Widget wDataTop = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Container(
            margin: EdgeInsets.only(
              left: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: ClipOval(
                    // borde de 2 pixeles sobre la foto
                    child: Container(
                      color: Colors.grey[600],
                      padding: EdgeInsets.all(2.0),
                      child: ProfilePicture(_displayImage),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: imageSelectorGallery,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 5),
                          child: Icon(Icons.edit)
                        ),
                        Text('Editar foto'),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
              margin: EdgeInsets.only(left: 25.0, right: 10.0, bottom: 25.0),
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                    ),
                    maxLength: 50,
                    controller: _nameController,
                  ),
                  Container(
                    child: new TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Apellidos',
                      ),
                      maxLength: 100,
                      controller: _surnameController,
                    ),
                  ),
                ],
              )),
        )
      ],
    );

    Widget wLocationInfo = _ubicacionCiudad == null || _ubicacionResto == null
      ? Container()
      : Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 5),
              child: Icon(Icons.location_on),
            ),
            Text('$_ubicacionCiudad, $_ubicacionResto', style: _styleText)
          ],
        );

    Widget wLocationButton = Container(
      margin: EdgeInsets.only(top: 10.0),
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 20.0),
          color: Colors.grey[600],
          child: Text('Abrir mapa', style: _styleButton),
          onPressed: _openLocationDialog)));

    Widget wEmail = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
              margin: EdgeInsets.only(left: 15, right: 10, bottom: 5),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              )),
        )
      ],
    );

    Widget wOldPassword = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
              margin: EdgeInsets.only(left: 15, right: 10, bottom: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Contraseña antigua',
                    ),
                    obscureText: true,
                    controller: _oldPassController,
                    keyboardType: TextInputType.text,
                  ),
                ],
              )),
        )
      ],
    );

    Widget wPassword = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
              margin: EdgeInsets.only(left: 15, right: 10, bottom: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña',
                    ),
                    obscureText: true,
                    controller: _newPassController,
                    keyboardType: TextInputType.text,
                  ),
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Repetir nueva contraseña',
                    ),
                    obscureText: true,
                    controller: _newPassRepController,
                    keyboardType: TextInputType.text,
                  ),
                ],
              )),
        )
      ],
    );

    Widget wSex = Row(
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Container(
              margin: EdgeInsets.only(left: 15, bottom: 7),
              //color: Colors.red, // util para ajustar margenes
              child: Column(children: <Widget>[
                new FormField(
                  builder: (FormFieldState state) {
                    return InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Sexo',
                      ),
                      isEmpty: _sexo == '',
                      child: new DropdownButtonHideUnderline(
                        child: new DropdownButton(
                          value: _sexo,
                          isDense: true,
                          onChanged: (String newValue) {
                            setState(() {
                              _sexo = newValue;
                              state.didChange(newValue);
                            });
                          },
                          items: _sexos.map((String value) {
                            return new DropdownMenuItem(
                              value: value,
                              child: new Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ])),
        ),
        Expanded(
          flex: 2,
          child: Container(
              margin: EdgeInsets.only(left: 5, top: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(children: <Widget>[
                new FlatButton(
                    onPressed: () {
                      setState(() {
                        _sexo = null;
                      });
                    },
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    child: new Icon(Icons.delete))
              ])),
        )
      ],
    );

    Widget wAge = Row(
      children: <Widget>[
        Expanded(
          flex: 8,
          child: Container(
              margin: EdgeInsets.only(left: 15),
              child: RaisedButton(
                color: Colors.grey[600],
                onPressed: () async {
                  DateTime picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900, 1),
                    lastDate: DateTime.now()
                  );
                  setState((){
                    _selectedDate = picked;
                  });
                },
                child: Text(_selectedDate == null ? 'Seleccionar fecha...' : _nacimientoString(_selectedDate), style: _styleButton, textAlign: TextAlign.left,),
              )
            ),
        ),
        Expanded(
          flex: 2,
          child: Container(
              margin: EdgeInsets.only(left: 5),
              //color: Colors.red, // util para ajustar margenes
              child: Column(children: <Widget>[
                new FlatButton(
                    onPressed: () => setState(() => _selectedDate = null),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    child: new Icon(Icons.delete))
              ])),
        )
      ],
    );

    return SafeArea(
        child: new Form(
            key: _formKey,
            autovalidate: true,
            child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                Container(
                  margin: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 10.0),
                  child: Text('Editar perfil', style: _styleTitle),
                ),
                wDataTop,
                Divider(),
                Container(
                  margin: EdgeInsets.fromLTRB(10.0, 15.0, 0.0, 10.0),
                  child: Text('Mi ubicación', style: _styleTitle),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      wLocationInfo,
                      wLocationButton,
                    ],
                  ),
                ),
                Divider(),
                Container(
                  margin: EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 10.0),
                  child: Text('Mi información', style: _styleTitle),
                ),
                wEmail,
                wSex,
                Container(
                  margin: EdgeInsets.only(left: 15.0, top: 5.0),
                  child: Text('Fecha de nacimiento', style: _styleAgeTitle),
                ),
                wAge,
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 20.0),
                      color: Theme.of(context).primaryColor,
                      child: Text('Guardar cambios', style: _styleButton),
                      onPressed: updateUser,
                    )
                  ),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.only(left: 6, top: 20, bottom: 10),
                  child: Row(children: <Widget>[
                    Row(children: <Widget>[
                      Text('Cambiar contraseña', style: _styleTitle)
                    ]),
                  ]),
                ),
                wOldPassword,
                Divider(),
                wPassword,
                Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 20.0),
                      color: Theme.of(context).primaryColor,
                      child: Text('Cambiar contraseña', style: _styleButton),
                      onPressed: cambioPass,
                    )
                  ),
                ),
              ],
            )));
  }

  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Theme.of(context).primaryColor.withAlpha(200));
    return Scaffold(key: _scaffoldKey, body: _buildForm());
  }
}
