import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
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

  ItemClass _item;

  int miId;

  List<ImageProvider> _images = [];

  static final _styleTitle = TextStyle(
      fontSize: 26.0, color: Colors.black, fontWeight: FontWeight.w700);

  static final styleTagWhite = TextStyle(
      fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold);

  static final styleTagBlack = TextStyle(
      fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.bold);

  // Mapas
  Completer<GoogleMapController> _controller = Completer();
  String _ubicacionCompleta;

  final Color _colorStatusBarBad = Colors.red.withOpacity(0.5);

  // Constructor
  _ItemDetails(this._item) {
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
    ),);
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
      }
    );
    }
    else{
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
    String docId = 'p' + _item.itemId.toString() + '_a' + 
      _item.owner.userId.toString() + '_c' + miId.toString();

    Firestore.instance.collection('chat').document(docId).get().then((document){
      if(document == null){
        print('CREAR NUEVO CHAT');
        // Se crea el chat
        Firestore.instance.runTransaction((transaction) async {
          await transaction.set(Firestore.instance.collection("chat").document(docId), 
            {'idAnunciante' : _item.owner.userId, 'idCliente' : miId, 'idProducto' : _item.itemId,
              'visible' : [miId]});
        });
        List<int> visible = new List<int>();
        visible.add(miId);
        ChatClass chat =  new ChatClass(usuario: _item.owner, miId: miId, producto: _item,
          visible: visible, docId: docId);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chat)));
      }
      else{
        print('CHAT EXISTENTE');
        // Ya existe el chat (hay que preservar los valores de visible)
        ChatClass chat =  new ChatClass(usuario: _item.owner, miId: miId, producto: _item,
          visible: List.from(document.data['visible']), docId: docId);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chat)));
      }
    });
  /*
    var document = await Firestore.instance.collection('chat').document(docId).get();
    if(document.data == null){
      print('CREAR NUEVO CHAT');
      // Se crea el chat
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(Firestore.instance.collection("chat").document(docId), 
          {'idAnunciante' : _item.owner.userId, 'idCliente' : miId, 'idProducto' : _item.itemId,
            'visible' : [miId]});
      });
      List<int> visible = new List<int>();
      visible.add(miId);
      ChatClass chat =  new ChatClass(usuario: _item.owner, miId: miId, producto: _item,
        visible: visible, docId: docId);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chat)));
    }
    else{
      // Ya existe el chat (hay que preservar los valores de visible)
      ChatClass chat =  new ChatClass(usuario: _item.owner, miId: miId, producto: _item,
        visible: List.from(document.data[0]['visible']), docId: docId);
      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chat)));
    }    
    */
  }

  @override
  Widget build(BuildContext context) {
    BarColor.changeBarColor(
        color: Theme.of(context).primaryColor, whiteForeground: true);
    final ThemeData theme = Theme.of(context);
    final TextStyle descriptionStyle = theme.textTheme.subhead;
    // Item en venta o no (también tener en cuenta si es nulo)
    bool _itemEnVenta = (_item?.status ?? "en venta") == "en venta";
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
      body: SafeArea(
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
                    padding: const EdgeInsets.fromLTRB(16.0, 15.0, 16.0, 0.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _item?.title ?? '',
                      style: _styleTitle,
                    )),
                Container(
                    padding: const EdgeInsets.fromLTRB(16.0, 5.0, 16.0, 0.0),
                    child: DefaultTextStyle(
                        style: descriptionStyle,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              // three line description
                              mainAxisSize: MainAxisSize.max,
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0, right: 10.0),
                                    child: Chip(
                                      backgroundColor: _itemEnVenta
                                          ? Theme.of(context).primaryColor
                                          : _blendColor,
                                      label: Text(
                                          _itemEnVenta ? 'En venta' : 'Vendido',
                                          style: styleTagWhite),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, left: 8.0),
                                  child: Text(
                                    '${_item?.price ?? ''} ${_item?.currency ?? ''}',
                                    style: styleTagBlack,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox.fromSize(
                              size: Size(60.0, 60.0),
                              child: _favoriteFunction == null
                                  ? Container(
                                      margin: EdgeInsets.all(15.0),
                                      child: CircularProgressIndicator(
                                          strokeWidth: 4.0,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  _esFavorito
                                                      ? Colors.grey
                                                      : Colors.red)))
                                  : IconButton(
                                      icon: Icon(_favorite),
                                      color: Colors.red,
                                      iconSize: 35.0,
                                      tooltip: 'Favoritos',
                                      splashColor: Colors.red,
                                      onPressed: _favoriteFunction,
                                    ),
                            ),
                          ],
                        ))),
                Container(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 15.0),
                    alignment: Alignment.topLeft,
                    child: Text(_item?.description ?? '',
                        style: TextStyle(fontSize: 15.0, color: Colors.black))),
                _item.category == null
                    ? Container()
                    : Container(
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 20.0),
                        alignment: Alignment.centerLeft,
                        child: Text(
                            'Categoría: ' +
                                FilterListClass.categoryNames[_item.category],
                            style: TextStyle(
                                fontSize: 17.0, color: Colors.grey[600]))),
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
                  padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                  alignment: Alignment.centerLeft,
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.grey[300], width: 2.0)),
                    child: InkWell(
                      onTap: () => Navigator.of(context)
                          .pushNamed('/profile', arguments: _item.owner.userId),
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
                              child: ProfilePicture(_item.owner.profileImage),
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
                _cameraPosition == null
                    ? Container()
                    : _buildOwnerMap(_cameraPosition)
              ])))),
    );
  }
}
