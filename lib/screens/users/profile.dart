import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geocoder/geocoder.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:selit/util/api/item_request.dart';
import 'package:selit/util/bubble_indication_painter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/widgets/items/item_tile.dart';
import 'package:selit/widgets/star_rating.dart';
import 'package:selit/widgets/profile_picture.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

/// Perfil de usuario: muestra sus datos, foto de perfil y
/// dos listas: una con los productos en venta y otra con los vendidos
/// Recibe el ID de usuario a mostrar y muestra un perfil por defecto
/// hasta que recibe los datos.
class Profile extends StatefulWidget {
  final int userId;

  /// Página de perfil para el usuario userId
  Profile({@required this.userId});

  @override
  _ProfileState createState() => new _ProfileState(userId);
}

class _ProfileState extends State<Profile> {
  // Estilos para los diferentes textos
  static final _styleNombre = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 18.0, color: Colors.white);
  static final _styleSexoEdad = const TextStyle(
      fontStyle: FontStyle.italic, fontSize: 15.0, color: Colors.white);
  static final _styleUbicacion =
      const TextStyle(fontSize: 15.0, color: Colors.white);
  static final _styleReviews =
      const TextStyle(fontSize: 15.0, color: Colors.white);
  static final _styleEditProfile =
      const TextStyle(fontSize: 16.0, color: Colors.white);
  static final _styleNothing =
      const TextStyle(fontSize: 20.0, color: Colors.grey);
  static final _textAlignment = TextAlign.left;

  /// Color más oscuro que el rojo principal
  final _blendColor = Color.alphaBlend(Color(0x552B2B2B), Color(0xFFC0392B));

  final _sexSymbol = {
    "hombre": FontAwesomeIcons.mars,
    "mujer": FontAwesomeIcons.venus,
    "otro": FontAwesomeIcons.neuter
  };

  /// Controlador tabs "en venta" y "vendido"
  PageController _pageController = PageController(initialPage: 0);

  /// Controlador listas "en venta" y "vendido"
  ScrollController _controllerEnVenta =
      ScrollController(initialScrollOffset: 0, keepScrollOffset: false);
  ScrollController _controllerVendidos =
      ScrollController(initialScrollOffset: 0, keepScrollOffset: false);

  /// Color de "en venta" (necesario alternarlo entre blanco-negro)
  Color _tabColorLeft = Colors.black;

  /// Color de "vendido" (necesario alternarlo entre blanco-negro)
  Color _tabColorRight = Colors.white;

  // Objetos en venta y vendidos
  List<ItemClass> _itemsEnVenta = <ItemClass>[];
  bool _itemsEnVentaEmpty = false; // diferenciar entre cargando y no hay
  List<ItemClass> _itemsVendidos = <ItemClass>[];
  bool _itemsVendidosEmpty = false; // diferenciar entre cargando y no hay
  bool _cancelled; // evitar bug al pedir objetos y cambiar de pantalla

  // Callback llamado por los objetos al ser actualizados
  void updateItemsVenta(Function(List<ItemClass>) actualizacion) {
    setState(() => actualizacion(_itemsEnVenta));
  }

  // Callback llamado por los objetos al ser actualizados
  void updateItemsVendidos(Function(List<ItemClass>) actualizacion) {
    setState(() => actualizacion(_itemsVendidos));
  }

  /// Usuario a mostrar en el perfil (null = placeholder)
  static UsuarioClass _user;
  int _loggedUserId;

  /// Ubicación del usuario
  String _ubicacionCiudad;
  String _ubicacionResto;

  _ProfileState(int _userId) {
    _user = null;
    _ubicacionCiudad = null;
    _ubicacionResto = null;
    _loggedUserId = null;
    _loadProfile(_userId).then((_) => _loadProfileItems());
    Storage.loadUserId().then((id) {
      print(id);
      setState(() => _loggedUserId = id);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _cancelled = true;
  }

  Future<void> _loadRatings() async {
    UsuarioRequest.getRatingsFromUser(userId: _user.userId).then((list) {
      setState(() {
        _user.setRatings(list);
      });
    }).catchError((error) {
      print('Error al obtener las calificaciones: $error');
    });
  }

  Future<void> _loadLocation() async {
    if (_user?.locationLat != null && _user?.locationLng != null) {
      // Se obtienen sus valores de ubicación
      final coordinates = new Coordinates(_user.locationLat, _user.locationLng);
      try {
        var addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        if (addresses.length > 0 && !_cancelled) {
          setState(() {
            _ubicacionCiudad = addresses.first.locality;
            _ubicacionResto = addresses.first.countryName;
          });
        }
      } catch (e) {
        print('Error al obtener addresses: ' + e.toString());
      }
    }
  }

  Future<void> _loadProfile(int _userId) async {
    // Mostrar usuario placeholder mientras carga el real
    _cancelled = false;
    if (_user == null) {
      String token = await Storage.loadToken();
      await UsuarioRequest.getUserById(_userId).then((realUser) {
        if (!_cancelled) {
          setState(() {
            realUser.token = token;
            _user = realUser;
          });
          _loadRatings();
          _loadLocation();
        }
      }).catchError((error) {
        print('Error al cargar el perfil de usuario: $error');
      });
    }
  }

  void _loadProfileItems() async {
    if (_user?.userId == null) {
      print('ERROR: Intentando cargar objetos de un usuario sin ID');
    } else {
      double userLat = await Storage.loadLat();
      double userLng = await Storage.loadLng();
      // Cargar los objetos en venta y vendidos para el usuario
      ItemRequest.getItemsFromUser(
              userId: _user.userId,
              userLat: userLat,
              userLng: userLng,
              status: "en venta")
          .then((itemsVenta) {
        if (!_cancelled) {
          // Callback para cuando se actualicen
          itemsVenta
              .forEach((item) => item.setUpdateListCallback(updateItemsVenta));
          // Acutalizar vista en la pantalla
          setState(() {
            if (itemsVenta.isEmpty) {
              _itemsEnVentaEmpty = true;
            } else {
              _itemsEnVenta = itemsVenta;
            }
          });
        }
      }).catchError((error) {
        print('Error al cargar los productos en venta de usuario: $error');
        _itemsEnVentaEmpty = true;
      });
      ItemRequest.getItemsFromUser(
              userId: _user.userId,
              userLat: userLat,
              userLng: userLng,
              status: "vendido")
          .then((itemsVendidos) {
        if (!_cancelled) {
          // Callback para cuando se actualicen
          itemsVendidos.forEach(
              (item) => item.setUpdateListCallback(updateItemsVendidos));
          setState(() {
            if (itemsVendidos.isEmpty) {
              _itemsVendidosEmpty = true;
            } else {
              _itemsVendidos = itemsVendidos;
            }
          });
        }
      }).catchError((error) {
        print('Error al cargar los productos vendidos de usuario: $error');
        _itemsVendidosEmpty = true;
      });
    }
  }

  void _onPressedEditProfile() {
    Navigator.of(context).pushNamed('/edit-profile', arguments: _user);
  }

  void _onPressedViewReviews() {
    if (_user?.ratings != null) {
      Navigator.of(context).pushNamed('/rating-list', arguments: _user.ratings);
    }
  }

  // Pulsación del boton "en venta"
  void _onPressedEnVenta() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    if (_controllerEnVenta.hasClients) {
      _controllerEnVenta.animateTo(0,
          duration: Duration(milliseconds: 150), curve: Curves.linear);
    }
  }

  // Pulsación del boton "vendidos"
  void _onPressedVendidos() {
    _pageController.animateToPage(1,
        duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    if (_controllerVendidos.hasClients) {
      _controllerVendidos.animateTo(0,
          duration: Duration(milliseconds: 150), curve: Curves.linear);
    }
  }

  // Botón de editar perfil
  Widget _buildEditProfileButton() {
    return Container(
        margin: EdgeInsets.only(right: 15),
        child: GestureDetector(
            onTap: _onPressedEditProfile,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Container(
                    padding: EdgeInsets.all(2.0),
                    color: _blendColor,
                    alignment: Alignment.centerRight,
                    width: 130.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: 5),
                          child:
                              Icon(Icons.edit, color: Colors.white, size: 18.0),
                        ),
                        Container(
                            margin: EdgeInsets.only(right: 10),
                            child:
                                Text('Editar perfil', style: _styleEditProfile))
                      ],
                    )))));
  }

  // Botón de reportar usuario
  Widget _buildReportButton() {
    return Container(
        margin: EdgeInsets.only(right: 15),
        child: GestureDetector(
            onTap: () => Navigator.of(context)
                .pushNamed('/report-user', arguments: _user),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Container(
                    padding: EdgeInsets.all(2.0),
                    color: _blendColor,
                    alignment: Alignment.centerRight,
                    width: 159.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          child: Icon(Icons.report_problem,
                              color: Colors.white, size: 18.0),
                        ),
                        Container(
                            margin: EdgeInsets.only(right: 5),
                            child: Text('Reportar usuario',
                                style: _styleEditProfile))
                      ],
                    )))));
  }

  /// Constructor para los botones "en venta" y "vendido"
  Widget _buildTabButton(displayText, onPress, textColor) {
    return Expanded(
      child: FlatButton(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onPressed: onPress,
        child: Text(
          displayText,
          style: TextStyle(color: textColor, fontSize: 16.0),
        ),
      ),
    );
  }

  /// Widget correspondiente al perfil del usuario _user
  /// Si un campo de _user es nulo, se muestran los campos por defecto
  Widget _buildProfile() {
    // wTopStack (parte superior junto con botón de edición)
    // wUserData (parte superior)
    // - wUserDataLeft (parte izquierda: foto de perfil, estrellas)
    // - wUserDataRight (parte derecha: nombre, apellidos, etc.)
    // wProductList (parte inferior)
    // - wProductListSelling (parte izquierda: lista de productos en venta)
    // - wProductListSold (parte derecha: lista de productos vendidos)

    Widget wUserDataLeft = Expanded(
      flex: 4,
      child: Container(
        margin: EdgeInsets.only(left: 25),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 20),
              child: ClipOval(
                // borde de 2 pixeles sobre la foto
                child: Container(
                  color: _blendColor,
                  padding: EdgeInsets.all(2.0),
                  child: ProfilePicture(_user?.profileImage),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: _user?.numeroEstrellas == null
                  ? Container(margin: EdgeInsets.only(top: 25))
                  : StarRating(
                      starRating: _user.numeroEstrellas,
                      starColor: Colors.white,
                      profileView: true,
                    ),
            ),
            _user?.ratings == null
                ? Container(margin: EdgeInsets.only(top: 40))
                : Container(
                    margin: EdgeInsets.fromLTRB(3.0, 5.0, 3.0, 10.0),
                    child: GestureDetector(
                        onTap: _user.ratings.length > 0 ? _onPressedViewReviews : null,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Container(
                                padding: EdgeInsets.all(2.0),
                                color: _blendColor,
                                alignment: Alignment.center,
                                width: 130.0,
                                child: Text('${_user.ratings.length} valoraciones',
                                    style: _styleReviews))))),
          ],
        ),
      ),
    );

    Widget wTopLeftButton = (_user?.userId == null || _loggedUserId == null)
        ? Container()
        : _user.userId == _loggedUserId
            ? _buildEditProfileButton()
            : _buildReportButton();

    Widget wLocation = _ubicacionCiudad == null || _ubicacionResto == null
        ? Container()
        : SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 5),
                      child: Icon(Icons.location_on, color: Colors.white),
                    ),
                    Text(
                      _ubicacionCiudad,
                      style: _styleUbicacion,
                      textAlign: _textAlignment,
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    _ubicacionResto,
                    style: _styleUbicacion,
                    textAlign: _textAlignment,
                  ),
                )
              ],
            ));

    int edad;
    if (_user?.nacimiento != null) {
      DateTime now = DateTime.now();
      edad = now.year - _user.nacimiento.year;
      if (_user.nacimiento.month > now.month ||
          (_user.nacimiento.month == now.month &&
              _user.nacimiento.day >= now.day)) {
        edad--; // no ha cumplido años este año
      }
    }

    Widget wUserDataRight = Expanded(
      flex: 6,
      child: Container(
          margin: EdgeInsets.only(left: 20, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              wTopLeftButton,
              Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(
                      top: wTopLeftButton == Container() ? 25 : 10),
                  child: Text(_user?.nombre ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: _styleNombre,
                      textAlign: _textAlignment)),
              Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.only(top: 5),
                  child: Text(_user?.apellidos ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: _styleNombre,
                      textAlign: _textAlignment)),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(
                    top: 10, bottom: wLocation == Container() ? 45 : 10),
                child: Row(children: <Widget>[
                  Text(edad != null ? '$edad años' : '',
                      style: _styleSexoEdad, textAlign: _textAlignment),
                  Container(
                      margin: EdgeInsets.only(left: 5.0),
                      child: _sexSymbol.containsKey(_user?.sexo)
                          ? Icon(_sexSymbol[_user.sexo],
                              color: Colors.white, size: 18.0)
                          : Container())
                ]),
              ),
              wLocation
            ],
          )),
    );

    Widget wUserData = Container(
      padding: EdgeInsets.only(top: 30),
      child: Row(children: <Widget>[wUserDataLeft, wUserDataRight]),
    );

    Widget wProductListSelling;
    if (_itemsEnVenta.isEmpty) {
      if (_itemsEnVentaEmpty) {
        // Efectivamente esta vacio, no esta cargando
        wProductListSelling = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.not_interested, color: Colors.grey, size: 65.0),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Text('Nada por aquí...', style: _styleNothing),
            )
          ],
        );
      } else {
        // Todavia esta cargando
        wProductListSelling = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
                strokeWidth: 5.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600])),
          ],
        );
      }
    } else {
      wProductListSelling = Container(
        margin: EdgeInsets.only(top: 5),
        child: ListView.builder(
          controller: _controllerEnVenta,
          padding: EdgeInsets.symmetric(horizontal: 15),
          itemCount: _itemsEnVenta.length,
          itemBuilder: (context, index) =>
              ItemTile(_itemsEnVenta[index], index % 2 == 0),
        ),
      );
    }

    Widget wProductListSold;
    if (_itemsVendidos.isEmpty) {
      if (_itemsVendidosEmpty) {
        // Efectivamente esta vacio, no esta cargando
        wProductListSold = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.not_interested, color: Colors.grey, size: 65.0),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Text('Nada por aquí...', style: _styleNothing),
            )
          ],
        );
      } else {
        // Todavia esta cargando
        wProductListSold = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
                strokeWidth: 5.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600])),
          ],
        );
      }
    } else {
      wProductListSold = Container(
        margin: EdgeInsets.only(top: 5),
        child: ListView.builder(
          controller: _controllerVendidos,
          padding: EdgeInsets.symmetric(horizontal: 15),
          itemCount: _itemsVendidos.length,
          itemBuilder: (context, index) =>
              ItemTile(_itemsVendidos[index], index % 2 == 0),
        ),
      );
    }

    // NOTA: la 'sincronizacion rapida' de los cambios de Flutter no
    // suele funcionar con los cambios realizados a las listas,
    // mejor reiniciar del todo
    Widget wProductList = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: (MediaQuery.of(context).size.width - 300) / 2),
          decoration: BoxDecoration(
            color: Color(0x552B2B2B),
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
          child: CustomPaint(
            painter: TabIndicationPainter(pageController: _pageController),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildTabButton("En venta", _onPressedEnVenta, _tabColorLeft),
                _buildTabButton("Vendidos", _onPressedVendidos, _tabColorRight),
              ],
            ),
          ),
        ),
      ),
      body: PageView(
          controller: _pageController,
          onPageChanged: (pageIndex) {
            if (pageIndex == 0) {
              // en venta
              setState(() {
                _tabColorLeft = Colors.black;
                _tabColorRight = Colors.white;
              });
            } else {
              // vendidos
              setState(() {
                _tabColorLeft = Colors.white;
                _tabColorRight = Colors.black;
              });
            }
          },
          children: <Widget>[wProductListSelling, wProductListSold]),
    );

    return Column(
      children: <Widget>[
        wUserData,
        Expanded(
          child: wProductList,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Color de fondo
          SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment(0.15, -1.0),
                    end: Alignment(-0.15, 1.0),
                    stops: [
                      0.6,
                      0.6
                    ],
                    colors: [
                      Theme.of(context).primaryColor,
                      Colors.grey[100],
                    ]),
              ),
            ),
          ),
          // Contenido: perfil del usuario
          _buildProfile(),
        ],
      ),
      // Botón para añadir nuevos items
      floatingActionButton: (_user?.userId == null ||
              _loggedUserId == null ||
              _user.userId != _loggedUserId)
          ? Container()
          : SpeedDial(
              // both default to 16
              marginRight: 18,
              marginBottom: 20,
              animatedIcon: AnimatedIcons.menu_close,
              animatedIconTheme: IconThemeData(size: 22.0),
              // this is ignored if animatedIcon is non null
              // child: Icon(Icons.add),
              visible: true,
              curve: Curves.bounceIn,
              overlayColor: Colors.black,
              overlayOpacity: 0.5,
              heroTag: 'speed-dial-hero-tag',
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              elevation: 8.0,
              shape: CircleBorder(),
              children: [
                SpeedDialChild(
                  child: Icon(Icons.add),
                  backgroundColor: Theme.of(context).primaryColor,
                  label: 'Añadir producto',
                  //labelStyle: TextTheme(fontSize: 18.0),
                  onTap: () {
                    Navigator.of(context).pushNamed('/new-item',
                        arguments: <dynamic>[_user, updateItemsVenta]);
                  },
                ),
                SpeedDialChild(
                  child: Icon(Icons.favorite),
                  backgroundColor: Theme.of(context).primaryColor,
                  label: 'Lista de deseos',
                  //labelStyle: TextTheme(fontSize: 18.0),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/whises', arguments: _user);
                  },
                ),
              ],
            ),
    );
  }
}
