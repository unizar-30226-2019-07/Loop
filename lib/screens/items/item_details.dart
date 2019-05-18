import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:selit/class/chat_class.dart';
import 'package:selit/class/item_class.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:selit/class/items/filter_list_class.dart';
import 'package:selit/screens/chat/chat.dart';
import 'package:selit/screens/items/edit_item.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:selit/util/api/item_request.dart';
import 'package:selit/widgets/profile_picture.dart';
import 'package:selit/util/bar_color.dart';
import 'package:selit/widgets/star_rating.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Detalles de un item/producto en venta: título, descripción, precio,
/// imágenes, etc. También se muestra información acerca de su usuario
/// dueño y su ubicación además de posibilidad para contactar con él.
class ItemDetails extends StatefulWidget {
  final ItemClass item;
  ItemDetails({this.item});
  @override
  State<StatefulWidget> createState() => _ItemDetails(item);
}

class _ItemDetails extends State<ItemDetails> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _pujaController = new TextEditingController();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  final Color _colorStatusBarGood = Colors.blue.withOpacity(0.5);

  static final _styleDialogTitle = TextStyle(
      fontSize: 19.0, color: Colors.white, fontWeight: FontWeight.bold);

  static final _styleDialogContent = TextStyle(
      fontSize: 15.0, color: Colors.white, fontWeight: FontWeight.normal);

  int miId;

  ItemClass _item;

  List<ImageProvider> _images = [];

  static final styleTagWhite = TextStyle(
      fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold);

  static final styleTagBlack = TextStyle(
      fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.bold);

  static final styleTagPrice = TextStyle(
      fontSize: 32.0, color: Colors.black, fontWeight: FontWeight.bold);

  static final styleTagTitle = TextStyle(
      fontSize: 32.0, color: Colors.black, fontWeight: FontWeight.bold);

  Function _buttonFunction; // inhabilidar boton

  // Mapas
  Completer<GoogleMapController> _controller = Completer();
  String _ubicacionCompleta;

  final Color _colorStatusBarBad = Colors.red.withOpacity(0.5);

  // Constructor
  _ItemDetails(this._item) {
    _buttonFunction = pujar;
    if (_item.media.isNotEmpty) {
      for (var imagen in _item.media) {
        _images.add(imagen.image.image);
      }
    }
    _loadCoordinates();
    // productos deseados
    _favoriteFunction = _favoritePressed;
    _esFavorito = (_item?.favorited == true);
    _favorite = _esFavorito ? Icons.favorite : Icons.favorite_border;
  }

  Function _favoriteFunction; // callback al presionar el corazón
  bool _esFavorito;
  IconData _favorite;

  Future<Null> _refresh() async {
    // Diálogo "cargando..." para evitar repetir
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

    return await ItemRequest.getItembyId(itemId: _item.itemId, type: _item.type)
        .then((itemReloaded) {
      setState(() => _item = itemReloaded);
      Navigator.of(context).pop();
    }).catchError((error) {
      if (error == "Unauthorized" || error == "Forbidden") {
        showInSnackBar("Acción no autorizada", _colorStatusBarBad);
      } else {
        print("Error: $error");
        showInSnackBar("No hay conexión a internet", _colorStatusBarBad);
      }
      Navigator.of(context).pop();
    });
  }

  /// Añadir o quitar el producto según proceda
  void _favoritePressed() async {
    setState(() {
      _favoriteFunction = null;
    });
    if (_esFavorito) {
      // ya está, quitar
      await UsuarioRequest.removeFromWishlist(
              productId: _item.itemId, auctions: _item.isAuction())
          .then((_) {
        _esFavorito = false;
      }).catchError((msg) {
        if (msg == "Precondition Failed") {
          showInSnackBar(
              "Este producto no está en tu lista", _colorStatusBarBad);
          _esFavorito = false;
        } else {
          showInSnackBar("Ha ocurrido un problema", _colorStatusBarBad);
        }
      });
    } else {
      // no está, añadir
      await UsuarioRequest.addToWishlist(
              productId: _item.itemId, auctions: _item.isAuction())
          .then((_) {
        _esFavorito = true;
      }).catchError((msg) {
        if (msg == "Precondition Failed") {
          showInSnackBar(
              "Este producto ya está en tu lista", _colorStatusBarBad);
          _esFavorito = true;
        } else {
          showInSnackBar("Ha ocurrido un problema", _colorStatusBarBad);
        }
      });
    }
    // Actualizar el corazón
    setState(() {
      _favoriteFunction = _favoritePressed;
      if (_esFavorito) {
        _favorite = Icons.favorite;
      } else {
        _favorite = Icons.favorite_border;
      }
    });
  }

  void pujar() {
    // Diálogo "cargando..." para evitar repetir
    _buttonFunction = null;

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

    if (_pujaController.text.length < 1) {
      showInSnackBar("Rellena todos los campos correctamente", Colors.yellow);
    } else {
      print('Pujando...');

      ItemRequest.bidUp(_item, _pujaController.text, miId).then((_) {
        showInSnackBar("Puja realizada correctamente", _colorStatusBarGood);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        //Navigator.of(context).pop();
      }).catchError((error) {
        if (error == "Unauthorized" || error == "Forbidden") {
          showInSnackBar("Acción no autorizada", _colorStatusBarBad);
        } else if (error == "Conflict") {
          showInSnackBar(
              "Oferta inferior o igual al precio actual", Colors.yellow);
        } else {
          print("Error: $error");
          showInSnackBar("No hay conexión a internet", _colorStatusBarBad);
        }
        _buttonFunction = pujar;
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      });
    }
  }

  static Widget _buildEditConditional;
  Widget _buildChatConditional = Container();

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

  void _loadCoordinates() async {
    if (_item?.owner?.locationLat != null &&
        _item?.owner?.locationLng != null) {
      final coordinates =
          new Coordinates(_item.owner.locationLat, _item.owner.locationLng);
      try {
        var addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        if (addresses.length > 0) {
          setState(() {
            _ubicacionCompleta =
                '${addresses.first.locality}, ${addresses.first.countryName}';
          });
        }
      } catch (e) {
        print('Error al obtener addresses: ' + e.toString());
      }
    }
  }

  void _showDialogDeleteProduct() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("¿Seguro que quiere eliminar el producto?",
              style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          content: new Text(
              "Si pulsa \"Eliminar\" el producto se eliminará. Los cambios no pueden deshacerse.",
              style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold)),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cancelar",
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Eliminar",
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
              onPressed: () {
                ItemRequest.delete(_item).then((_) {
                  // Actualizar el listado
                  _item
                      .updateList((List<ItemClass> list) => list.remove(_item));
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }).catchError((error) {
                  if (error == "Unauthorized" || error == "Forbidden") {
                    showInSnackBar("Acción no autorizada", _colorStatusBarBad);
                  } else {
                    showInSnackBar(
                        "No hay conexión a internet", _colorStatusBarBad);
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditButton() {
    return Container(
        margin: EdgeInsets.only(top: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new RaisedButton(
              padding: const EdgeInsets.all(8.0),
              textColor: Colors.white,
              color: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditItem(item: _item)));
              },
              child: new Text('Editar producto',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
            new RaisedButton(
              onPressed: () => _showDialogDeleteProduct(),
              textColor: Colors.white,
              color: Colors.grey[600],
              padding: const EdgeInsets.all(8.0),
              child: new Text('Eliminar producto',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ));
  }

  Widget _buildChatButtonGanador() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 25.0),
      child: SizedBox(
        width: double.infinity,
        child: new RaisedButton(
          padding: const EdgeInsets.all(10.0),
          elevation: 1,
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            iniciarChatGanador();
          },
          child: new Text('Chat con ganador',
              style: TextStyle(
                  fontSize: 21.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildChatButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 25.0),
      child: SizedBox(
        width: double.infinity,
        child: new RaisedButton(
          padding: const EdgeInsets.all(10.0),
          elevation: 1,
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            iniciarChat();
          },
          child: new Text('Iniciar chat',
              style: TextStyle(
                  fontSize: 21.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildRateButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 25.0),
      child: SizedBox(
        width: double.infinity,
        child: new RaisedButton(
          padding: const EdgeInsets.all(10.0),
          elevation: 1,
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          onPressed: () =>
              Navigator.of(context).pushNamed('/rate-user', arguments: _item),
          child: new Text('Calificar usuario',
              style: TextStyle(
                  fontSize: 21.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  final _blendColor = Color.alphaBlend(Color(0x552B2B2B), Color(0xFFC0392B));

  void _leerIdUsuario() async {
    int idItem = _item.owner.userId;
    miId = await Storage.loadUserId();
    print('Mi id ' + miId.toString());
    print('Id item ' + idItem.toString());

    if (miId == idItem) {
      print('Construir editar');
      setState(() {
        _buildEditConditional = _buildEditButton();
      });

      if (_item.lastBid.bidder != null) {
        if (_item.type == "auction" &&
            !_item.endDate.isAfter(DateTime.now()) &&
            _item.lastBid.bidder.userId != miId) {
          _buildChatConditional = _buildChatButtonGanador();
        }
      }
    } else {
      print('Construir chat');
      setState(() {
        _buildChatConditional = _buildChatButton();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _buildEditConditional = null;
    _leerIdUsuario();
  }

  /// Mapa que indica donde esta el usuario dueño
  Widget _buildOwnerMap(CameraPosition pos) {
    return SizedBox.fromSize(
      size: Size(double.infinity, 300.0),
      child: Container(
        margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 40.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25.0),
          child: Stack(
            children: <Widget>[
              Container(
                color: Colors.grey[300],
                padding: EdgeInsets.all(3.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: GoogleMap(
                    mapType: MapType.normal,
                    rotateGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    initialCameraPosition: pos,
                    onTap: null,
                    onMapCreated: (GoogleMapController controller) {
                      if (!_controller.isCompleted) {
                        _controller.complete(controller);
                      }
                    },
                  ),
                ),
              ),
              _ubicacionCompleta == null
                  ? Container()
                  : Positioned(
                      top: 10,
                      left: 15,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 7.0),
                              color: Colors.grey[300],
                              child: Row(children: <Widget>[
                                Icon(Icons.location_on, size: 18.0),
                                Text(
                                    '  $_ubicacionCompleta'), // espacios a modo de padding
                              ])))),
            ],
          ),
        ),
      ),
    );
  }

  void iniciarChat() async {
    String docId = 'p' +
        _item.itemId.toString() +
        '_a' +
        _item.owner.userId.toString() +
        '_c' +
        miId.toString();

    Firestore.instance
        .collection('chat')
        .document(docId)
        .get()
        .then((document) {
      if (!document.exists) {
        print('CREAR NUEVO CHAT');
        // Se crea el chat
        var fechaActual = DateTime.now();
        Firestore.instance.runTransaction((transaction) async {
          await transaction
              .set(Firestore.instance.collection("chat").document(docId), {
            'idAnunciante': _item.owner.userId,
            'idCliente': miId,
            'idProducto': _item.itemId,
            'visible': [miId],
            'ultimoMensaje': '',
            'fechaUltimoMensaje': fechaActual,
            'tipoProducto': _item.type,
          });
        });
        List<int> visible = new List<int>();
        visible.add(miId);
        ChatClass chat = new ChatClass(
            usuario: _item.owner,
            miId: miId,
            producto: _item,
            visible: visible,
            docId: docId,
            lastMessageDate: fechaActual,
            lastMessage: '',
            tipoProducto: _item.type);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChatScreen(chat)));
      } else {
        List<int> listaVisible = List.from(document.data['visible']);
        print('CHAT EXISTENTE');
        if (!document['visible'].contains(miId)) {
          listaVisible.add(miId);
          print('Cambiando visibilidad');
          Firestore.instance.runTransaction((transaction) async {
            await transaction
                .set(Firestore.instance.collection("chat").document(docId), {
              'idAnunciante': _item.owner.userId,
              'idCliente': miId,
              'idProducto': _item.itemId,
              'visible': [miId, _item.owner.userId],
              'ultimoMensaje': document.data['ultimoMensaje'],
              'fechaUltimoMensaje': document['fechaUltimoMensaje'],
              'tipoProducto': _item.type,
            });
          });
        }
        // Ya existe el chat (hay que preservar los valores de visible)
        ChatClass chat = new ChatClass(
            usuario: _item.owner,
            miId: miId,
            producto: _item,
            visible: listaVisible,
            docId: docId,
            lastMessageDate: document['fechaUltimoMensaje'].toDate(),
            lastMessage: document.data['ultimoMensaje'],
            tipoProducto: _item.type);
        print('Tipo producto: ' + chat.tipoProducto);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChatScreen(chat)));
      }
    });
  }

  void iniciarChatGanador() async {
    String docId = 'p' +
        _item.itemId.toString() +
        '_a' +
        _item.lastBid.bidder.userId.toString() +
        '_c' +
        miId.toString();

    Firestore.instance
        .collection('chat')
        .document(docId)
        .get()
        .then((document) {
      if (!document.exists) {
        print('CREAR NUEVO CHAT');
        // Se crea el chat
        var fechaActual = DateTime.now();
        Firestore.instance.runTransaction((transaction) async {
          await transaction
              .set(Firestore.instance.collection("chat").document(docId), {
            'idAnunciante': _item.lastBid.bidder.userId,
            'idCliente': miId,
            'idProducto': _item.itemId,
            'visible': [miId],
            'ultimoMensaje': '',
            'fechaUltimoMensaje': fechaActual,
            'tipoProducto': _item.type,
          });
        });
        List<int> visible = new List<int>();
        visible.add(miId);
        ChatClass chat = new ChatClass(
            usuario: _item.lastBid.bidder,
            miId: miId,
            producto: _item,
            visible: visible,
            docId: docId,
            lastMessageDate: fechaActual,
            lastMessage: '',
            tipoProducto: _item.type);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChatScreen(chat)));
      } else {
        List<int> listaVisible = List.from(document.data['visible']);
        print('CHAT EXISTENTE');
        if (!document['visible'].contains(miId)) {
          listaVisible.add(miId);
          print('Cambiando visibilidad');
          Firestore.instance.runTransaction((transaction) async {
            await transaction
                .set(Firestore.instance.collection("chat").document(docId), {
              'idAnunciante': _item.lastBid.bidder.userId,
              'idCliente': miId,
              'idProducto': _item.itemId,
              'visible': [miId, _item.lastBid.bidder.userId],
              'ultimoMensaje': document.data['ultimoMensaje'],
              'fechaUltimoMensaje': document['fechaUltimoMensaje'],
              'tipoProducto': _item.type,
            });
          });
        }
        // Ya existe el chat (hay que preservar los valores de visible)
        ChatClass chat = new ChatClass(
            usuario: _item.lastBid.bidder,
            miId: miId,
            producto: _item,
            visible: listaVisible,
            docId: docId,
            lastMessageDate: document['fechaUltimoMensaje'].toDate(),
            lastMessage: document.data['ultimoMensaje'],
            tipoProducto: _item.type);
        print('Tipo producto: ' + chat.tipoProducto);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => ChatScreen(chat)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AlertDialog dialog = AlertDialog(
      backgroundColor: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Color.alphaBlend(Color(0x552B2B2B), Color(0xFFC0392B)),
              width: 2.0),
          borderRadius: BorderRadius.circular(10.0)),
      title: Text('Información de la subasta', style: _styleDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _item.type == "auction"
              ? Container(
                  decoration: new BoxDecoration(
                      color: _blendColor,
                      borderRadius:
                          new BorderRadius.all(const Radius.circular(10.0))),
                  child: Column(children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(top: 5, left: 10),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                              child: Text(
                                  'Fecha límite: ${DateFormat('dd-MM-yyyy').format(_item?.endDate) ?? ''}',
                                  style: _styleDialogContent))),
                    ),
                    Container(
                        padding: const EdgeInsets.only(top: 5, left: 10),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                                child: Text(
                                    'Precio de salida: ${_item?.price ?? ''} ${_item?.currency ?? ''}',
                                    style: _styleDialogContent)))),
                    Container(
                        padding:
                            const EdgeInsets.only(top: 5, left: 10, bottom: 5),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                                child: _item.lastBid == null
                                    ? Text('No hay pujas todavía',
                                        style: _styleDialogContent)
                                    : Text(
                                        'Última puja: ${_item?.lastBid?.amount ?? ''} ${_item?.currency ?? ''}',
                                        style: _styleDialogContent)))),
                  ]))
              : Container(),
          Container(
              padding: EdgeInsets.only(top: 15, bottom: 35),
              child: new Theme(
                data: new ThemeData(
                    primaryColor: Colors.white,
                    accentColor: Colors.white,
                    hintColor: Colors.white),
                child: new TextField(
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: new InputDecoration(
                      labelText: 'Introduce tu puja',
                      labelStyle: TextStyle(color: Colors.white),
                      border: new UnderlineInputBorder(
                          borderSide: new BorderSide(color: Colors.white))),
                  controller: _pujaController,
                  keyboardType: TextInputType.number,
                ),
              )),
          RaisedButton(
            padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 40.0),
            color: Colors.white,
            child: Text('Pujar',
                style: TextStyle(fontSize: 19.0, color: Colors.black)),
            onPressed: _buttonFunction,
          )
        ],
      ),
    );

    BarColor.changeBarColor(
        color: Theme.of(context).primaryColor, whiteForeground: true);
    final ThemeData theme = Theme.of(context);
    final TextStyle descriptionStyle = theme.textTheme.subhead;
    // Item en venta o no (también tener en cuenta si es nulo)
    bool _itemEnVenta = (_item?.status ?? "en venta") == "en venta";
    // Subasta fuera de fecha o no
    bool _subastaEnFecha = _item?.endDate?.isAfter(DateTime.now());
    // Ubicación del dueño
    CameraPosition _cameraPosition;
    if (_item?.owner?.locationLat != null &&
        _item?.owner?.locationLng != null &&
        _item?.owner?.userId != null) {
      // Generar un numero ""aleatorio"" a partir del ID de usuario
      // No es la mejor opción para mover la ubicación, pero por ahora sirve
      // Mover +/- 0.004 la latitud y longitud
      double randomLat = (200 - ((_item.owner.userId * 37 + 48) % 400)) / 50000;
      double randomLng = (200 - ((_item.owner.userId * 83 + 21) % 400)) / 50000;
      //print('Con ID ${_item.owner.userId} se mueve ($randomLat, $randomLng)');
      LatLng movedLL = LatLng(_item.owner.locationLat + randomLat,
          _item.owner.locationLng + randomLng);
      // Posición de cámara para mostrarla en el mapa
      _cameraPosition = CameraPosition(
        target: movedLL,
        zoom: 14.5,
      );
    }
    return new Scaffold(
      key: _scaffoldKey,
      floatingActionButton: _item.type == "auction" && _subastaEnFecha
          ? new FloatingActionButton(
              elevation: 8.0,
              child: new Icon(FontAwesomeIcons.gavel),
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () =>
                  showDialog(context: context, builder: (context) => dialog),
            )
          : Container(),
      body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: SafeArea(
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0),
                  child: SingleChildScrollView(
                      child: Column(children: <Widget>[
                    _images.isEmpty
                        ? Divider()
                        : Column(children: <Widget>[
                            Container(
                              child: Card(
                                elevation: 4.0,
                                child: Container(
                                  color: Colors.white,
                                  child: _images.isEmpty
                                      ? Container()
                                      : SizedBox(
                                          height: 250.0,
                                          child: Center(
                                            child: Carousel(
                                              images: _images,
                                              boxFit: BoxFit.scaleDown,
                                              showIndicator: _images.length > 1,
                                              autoplay: false,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            Divider(),
                          ]),
                    Container(child: _buildEditConditional),
                    Container(
                        //padding: const EdgeInsets.fromLTRB(16.0, 15.0, 16.0, 0.0),
                        // alignment: Alignment.centerLeft,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Padding(
                              padding: const EdgeInsets.only(left: 15, top: 20),
                              child: Text(_item?.title ?? '',
                                  style: styleTagTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)),
                          Row(
                              crossAxisAlignment: _item.type == "auction"
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(children: [
                                  _item.type == "auction"
                                      ? Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 0.0, left: 9, top: 0),
                                          child: _item.type == "auction" &&
                                                  _item.lastBid != null
                                              ? Text(
                                                  'Última puja',
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.grey[600]),
                                                )
                                              : Text(
                                                  'Precio salida',
                                                  style: TextStyle(
                                                      fontSize: 15.0,
                                                      color: Colors.grey[600]),
                                                ))
                                      : Container(),
                                  Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 0.0, left: 15, top: 0),
                                      child: _item.type == "auction" &&
                                              _item.lastBid != null
                                          ? Text(
                                              '${_item?.lastBid?.amount ?? ''} ${_item?.currency ?? ''}',
                                              style: styleTagBlack,
                                            )
                                          : Text(
                                              '${_item?.price ?? ''} ${_item?.currency ?? ''}',
                                              style: styleTagBlack,
                                            ))
                                ]),
                                Column(children: [
                                  SizedBox.fromSize(
                                    size: Size(60.0, 60.0),
                                    child: _favoriteFunction == null
                                        ? Container(
                                            margin: EdgeInsets.all(15.0),
                                            child: CircularProgressIndicator(
                                                strokeWidth: 4.0,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        _esFavorito
                                                            ? Colors.grey
                                                            : Colors.red)))
                                        : IconButton(
                                            padding: _item.type == "auction"
                                                ? const EdgeInsets.only(
                                                    bottom: 0.0,
                                                    right: 10,
                                                    top: 20)
                                                : const EdgeInsets.only(
                                                    bottom: 0.0,
                                                    right: 10,
                                                    top: 0),
                                            icon: Icon(_favorite),
                                            color: Colors.red,
                                            iconSize: 35.0,
                                            tooltip: 'Favoritos',
                                            splashColor: Colors.red,
                                            onPressed: _favoriteFunction,
                                          ),
                                  ),
                                ]),
                              ]),
                        ])),
                    Divider(),
                    Container(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 10.0, 10.0, 15.0),
                        alignment: Alignment.topLeft,
                        child: Text(_item?.description ?? '',
                            style: TextStyle(
                                fontSize: 15.0, color: Colors.black))),
                    _item.category == null
                        ? Container()
                        : Container(
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 0.0, left: 15, top: 5),
                                      child: Text(
                                          'Categoría: ' +
                                              FilterListClass.categoryNames[
                                                  _item.category],
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              color: Colors.grey[600])))
                                ]),
                                Column(children: [
                                  Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          16.0, 5.0, 7.0, 0.0),
                                      child: DefaultTextStyle(
                                          style: descriptionStyle,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                // three line description
                                                mainAxisSize: MainAxisSize.max,
                                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 8.0,
                                                              right: 10.0),
                                                      child: Chip(
                                                        backgroundColor: _item
                                                                    .type ==
                                                                "auction"
                                                            ? _subastaEnFecha
                                                                ? Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                : _blendColor
                                                            : _itemEnVenta
                                                                ? Theme.of(
                                                                        context)
                                                                    .primaryColor
                                                                : _blendColor,
                                                        label: _item.type ==
                                                                "auction"
                                                            ? Text(
                                                                _subastaEnFecha
                                                                    ? 'Subasta activa'
                                                                    : _item.lastBid ==
                                                                            null
                                                                        ? 'Subasta cerrada'
                                                                        : _item.lastBid.bidder.userId ==
                                                                                miId
                                                                            ? 'Subasta ganada'
                                                                            : 'Subasta perdida',
                                                                style:
                                                                    styleTagWhite)
                                                            : Text(
                                                                _itemEnVenta
                                                                    ? 'En venta'
                                                                    : 'Vendido',
                                                                style:
                                                                    styleTagWhite),
                                                      )),
                                                ],
                                              ),
                                            ],
                                          )))
                                ]),
                              ])),
                    Divider(),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        margin: EdgeInsets.only(left: 15.0, top: 10.0),
                        child: Text(
                          'Acerca del vendedor',
                          style: styleTagBlack,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                      alignment: Alignment.centerLeft,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        elevation: 2.0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            side: BorderSide(
                                color: Colors.grey[300], width: 2.0)),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pushNamed(
                              '/profile',
                              arguments: _item.owner.userId),
                          splashColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.05),
                          highlightColor: Colors.transparent,
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              SizedBox.fromSize(
                                size: Size(100.0, 100.0),
                                child: Container(
                                  padding: EdgeInsets.all(2.0),
                                  child:
                                      ProfilePicture(_item.owner.profileImage),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          child: Text(
                                            _item.owner.nombre +
                                                ' ' +
                                                _item.owner.apellidos,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: descriptionStyle.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                        Container(
                                            child: StarRating(
                                          starRating:
                                              _item.owner?.numeroEstrellas ?? 5,
                                          starColor: Colors.black,
                                          profileView: false,
                                          starSize: 18.0,
                                        )),
                                        Container(
                                          padding: EdgeInsets.only(top: 3.0),
                                          child: Row(
                                            children: <Widget>[
                                              Icon(Icons.location_on),
                                              Text(
                                                  ' A ${_item.distance.toStringAsFixed(1)} km'),
                                            ],
                                          ),
                                        )
                                      ],
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildChatConditional,
                    _buildRateButton(), // TODO comprobaciones de que lo puede valorar
                    _cameraPosition == null
                        ? Container()
                        : _buildOwnerMap(_cameraPosition)
                  ]))))),
    );
  }
}
