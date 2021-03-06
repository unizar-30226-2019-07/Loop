import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:selit/class/chat_class.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/item_class.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:selit/class/items/filter_list_class.dart';
import 'package:selit/screens/chat/chat.dart';
import 'package:selit/screens/items/edit_item.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:selit/util/api/item_request.dart';
import 'package:selit/widgets/profile_picture.dart';
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

  List<UsuarioClass> posiblesUsuarios = new List<UsuarioClass>();

  static final styleTagWhite = TextStyle(
      fontSize: 18.0, color: Colors.white, fontWeight: FontWeight.bold);

  static final styleTagBlack = TextStyle(
      fontSize: 22.0, color: Colors.black, fontWeight: FontWeight.bold);

  static final styleTagPrice = TextStyle(
      fontSize: 32.0, color: Colors.black, fontWeight: FontWeight.bold);

  static final styleTagTitle = TextStyle(
      fontSize: 32.0, color: Colors.black, fontWeight: FontWeight.bold);

  // Mapas
  Completer<GoogleMapController> _controller = Completer();
  String _ubicacionCompleta;

  final Color _colorStatusBarBad = Colors.red.withOpacity(0.5);
  final _blendColor = Color.alphaBlend(Color(0x552B2B2B), Color(0xFFC0392B));

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
    if (_item.type == "auction" && _item.itemId != 0) {
      _checkAuctionFinished();
    }

    if (_item.itemId != null) {
      // Sumar uno al numero de visitas
      ItemRequest.viewItem(itemId: _item.itemId, type: _item.type).catchError(
          (error) =>
              print('Ocurrio un error al sumar visitas a un producto: $error'));
    }
  }

  @override
  void initState() {
    _buildEditConditional = null;
    _leerIdUsuario();
    _getChatUsers();
    super.initState();
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
      setState(() {
        _item.price = itemReloaded.price;

        if (_item.type == "auction") {
          _item.lastBid = itemReloaded.lastBid;
          _checkAuctionFinished();
        }
      });
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
      showInSnackBar(
          "Rellena todos los campos correctamente", Colors.yellow[800]);
      Navigator.of(context).pop();
    } else {
      print('Pujando...');

      double pujaDouble =
          double.tryParse(_pujaController.text.replaceAll(',', '.'));
      if (pujaDouble == null) {
        showInSnackBar("Puja inválida", Colors.yellow[800]);
        Navigator.of(context).pop();
        return;
      } else {
        pujaDouble = double.parse(
            pujaDouble.toStringAsFixed(2)); // 2 decimales de precision
        if (pujaDouble < 0) {
          showInSnackBar("La puja no puede ser negativa", Colors.yellow[800]);
          Navigator.of(context).pop();
          return;
        } else if (pujaDouble > 1000000) {
          showInSnackBar("La puja es demasiado grande", Colors.yellow[800]);
          Navigator.of(context).pop();
          return;
        } else if (pujaDouble <= _item.price ||
            (_item.lastBid?.amount != null &&
                pujaDouble <= _item.lastBid.amount)) {
          showInSnackBar(
              "La puja debe ser mayor que la actual", Colors.yellow[800]);
          Navigator.of(context).pop();
          return;
        }
      }

      ItemRequest.bidUp(_item, pujaDouble.toString(), miId).then((_) {
        showInSnackBar("Puja realizada correctamente", _colorStatusBarGood);

        //Se pide el item para obtener lastBid
        ItemRequest.getItembyId(itemId: _item.itemId, type: _item.type)
            .then((itemReloaded) {
          setState(() {
            _item.lastBid = itemReloaded.lastBid;
            _item.price = itemReloaded.price;
            _pujaController.text = '';
          });
          // Callback del item
          _item.updateList(
              (List<ItemClass> list) => list.forEach((ItemClass listItem) {
                    if (listItem.itemId == _item.itemId &&
                        listItem.type == _item.type) listItem = _item;
                  }));

          Navigator.of(context).pop();
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
      }).catchError((error) {
        if (error == "Unauthorized" || error == "Forbidden") {
          showInSnackBar("Acción no autorizada", _colorStatusBarBad);
        } else if (error == "Conflict") {
          showInSnackBar(
              "Oferta inferior o igual al precio actual", Colors.yellow[800]);
        } else {
          print("Error: $error");
          showInSnackBar("No hay conexión a internet", _colorStatusBarBad);
        }

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
                    print('Error al eliminar producto: $error');
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

  /// Devolver una lista con los usuarios que han abierto chat al vendedor del producto
  void _getChatUsers() async {
    List<UsuarioClass> listaClientes = new List<UsuarioClass>();
    Firestore.instance
        .collection('chat')
        .where('idProducto', isEqualTo: _item.itemId)
        .where('idAnunciante', isEqualTo: miId)
        .where('tipoProducto', isEqualTo: 'sale')
        .getDocuments()
        .then((QuerySnapshot data) {
      data.documents.forEach((document) async {
        listaClientes
            .add(await UsuarioRequest.getUserById(document['idCliente']));
      });
    });
    setState(() {
      posiblesUsuarios = listaClientes;
    });
  }

  void _markAsSold(int buyerId) {
    ItemRequest.markItemAsSold(item: _item, buyerId: buyerId).then((_) {
      showInSnackBar("Objeto marcado como vendido", _colorStatusBarGood);
      setState(() => _item.status = "vendido");
      // Callback del item
      _item.updateList((List<ItemClass> list) => list.remove(_item));
      _buildEditConditional = _buildEditButton();
      Navigator.of(context).pop();
    }).catchError((error) {
      if (error == "Conflict") {
        showInSnackBar("Este producto ya está vendido", _colorStatusBarBad);
      } else if (error == "Not Found") {
        showInSnackBar(
            "No se ha encontrado al usuario comprador", _colorStatusBarBad);
      } else if (error == "Forbidden") {
        showInSnackBar(
            "No tienes permiso para editar este producto", _colorStatusBarBad);
      } else {
        print('Error al marcar como vendido: $error');
        showInSnackBar("Ha ocurrido un problema", _colorStatusBarBad);
      }
      Navigator.of(context).pop();
    });
  }

  void _checkAuctionFinished() {
    ItemRequest.checkAuctionFinished(item: _item).then((terminada) {
      setState(() {
        if (terminada) {
          _item.status = "vendido";
        } else {
          _item.status = "en venta";
        }
      });
    }).catchError((error) {
      print('Error al comprobar estado de subasta: $error');
      showInSnackBar(
          "Ha ocurrido un problema al comprobar el estado de la subasta",
          _colorStatusBarBad);

      //Navigator.of(context).pop();
    });
  }

  void _showMarkAsSoldDialog() {
    if (posiblesUsuarios.isEmpty) {
      showInSnackBar("No has chateado con nadie", _colorStatusBarBad);
    } else {
      List<Widget> buttonOptions = [];
      posiblesUsuarios.forEach((usuario) {
        buttonOptions.add(SizedBox.fromSize(
            size: Size(double.infinity, 64.0),
            child: Container(
                margin: EdgeInsets.all(2),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(color: Colors.grey[300], width: 2.0)),
                  child: InkWell(
                    onTap: () => _markAsSold(usuario.userId),
                    splashColor: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.05),
                    highlightColor: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        SizedBox.fromSize(
                          size: Size(50.0, 50.0),
                          child: Container(
                            padding: EdgeInsets.all(2.0),
                            child: ProfilePicture(usuario.profileImage),
                          ),
                        ),
                        Expanded(
                          child: Container(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      usuario.nombre + ' ' + usuario.apellidos,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .subhead
                                          .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                    ),
                                  ),
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                ))));
      });

      AlertDialog dialog = AlertDialog(
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: _blendColor, width: 2.0),
            borderRadius: BorderRadius.circular(10.0)),
        title: Text('Selecciona el comprador...', style: _styleDialogTitle),
        content: SizedBox.fromSize(
          size: Size(double.infinity, 285.0),
          child: Column(
            children: <Widget>[
              Expanded(
                  child: SingleChildScrollView(
                      child: Column(
                children: buttonOptions,
              ))),
              RaisedButton(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  color: Colors.grey[200],
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cerrar')),
            ],
          ),
        ),
      );

      showDialog(context: context, builder: (context) => dialog);
    }
  }

  Widget _buildMarkAsSoldButton() {
    return Container(
        margin: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
        child: SizedBox(
            width: double.infinity,
            child: RaisedButton(
              padding: const EdgeInsets.all(8.0),
              textColor: Colors.white,
              color: Theme.of(context).primaryColor,
              onPressed: _showMarkAsSoldDialog,
              child: new Text('Marcar como vendido',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            )));
  }

  Widget _buildEditButton() {
    return Container(
        margin: EdgeInsets.only(top: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new RaisedButton(
              padding: const EdgeInsets.all(8.0),
              textColor: Colors.white,
              color: _blendColor,
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
          elevation: 4,
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            iniciarChatGanador();
          },
          child: new Text('Contactar con el ganador',
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
          elevation: 4,
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            iniciarChat();
          },
          child: new Text('Contactar con el vendedor',
              style: TextStyle(
                  fontSize: 21.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildRateButton() {
    bool isBuyer =
        miId == _item.buyer?.userId || miId == _item.lastBid?.bidder?.userId;
    return Container(
      padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 25.0),
      child: SizedBox(
        width: double.infinity,
        child: new RaisedButton(
          padding: const EdgeInsets.all(10.0),
          elevation: 4,
          textColor: Colors.white,
          color: Theme.of(context).primaryColor,
          onPressed: () => Navigator.of(context)
              .pushNamed('/rate-user', arguments: [_item, isBuyer]),
          child: new Text('Calificar al ${isBuyer ? 'vendedor' : 'comprador'}',
              style: TextStyle(
                  fontSize: 21.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _leerIdUsuario() async {
    int idItem = _item.owner?.userId;
    miId = await Storage.loadUserId();
    print('Mi id ' + miId.toString());
    print('Id owener item ' + idItem.toString());
    print('Id item ' + _item.itemId.toString());

    if (_item.itemId > 0) {
      if (miId == idItem) {
        print('Construir editar');
        setState(() {
          _buildEditConditional = Column(children: <Widget>[
            _item?.type == "sale" && _item?.status == "en venta"
                ? _buildMarkAsSoldButton()
                : Container(),
            _buildEditButton(),
          ]);
        });

        if (_item?.lastBid?.bidder != null) {
          if (_item.type == "auction" &&
              !_item.endDate.isAfter(DateTime.now()) &&
              _item.lastBid.bidder.userId != miId) {
            _buildChatConditional = _buildChatButtonGanador();
          }
        }
      } else if (idItem != 0) {
        print('Construir chat');
        setState(() {
          _buildChatConditional = _buildChatButton();
        });
      }
    }
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
    String docId;
    if (_item.type == 'auction') {
      docId = 's' +
          _item.itemId.toString() +
          '_a' +
          _item.owner.userId.toString() +
          '_c' +
          miId.toString();
    } else {
      docId = 'p' +
          _item.itemId.toString() +
          '_a' +
          _item.owner.userId.toString() +
          '_c' +
          miId.toString();
    }
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
    // Siempre es subasta en este caso
    String docId = 's' +
        _item.itemId.toString() +
        '_a' +
        miId.toString() +
        '_c' +
        _item.lastBid.bidder.userId.toString();

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
            'idAnunciante': miId,
            'idCliente': _item.lastBid.bidder.userId,
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
              'idAnunciante': miId,
              'idCliente': _item.lastBid.bidder.userId,
              'idProducto': _item.itemId,
              'visible': [miId, _item.lastBid.bidder.userId],
              'ultimoMensaje': document.data['ultimoMensaje'],
              'fechaUltimoMensaje': document['fechaUltimoMensaje'],
              'tipoProducto': _item.type,
            });
          });
        }
        print('CHECK 1');
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
          _item.type == "auction" &&
                  _item.itemId != 0 &&
                  miId != _item.owner.userId
              ? Container(
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
                  ))
              : Container(),
          _item.type == "auction" &&
                  _item.itemId != 0 &&
                  miId != _item.owner.userId
              ? RaisedButton(
                  padding:
                      EdgeInsets.symmetric(vertical: 7.0, horizontal: 40.0),
                  color: Colors.white,
                  child: Text('Pujar',
                      style: TextStyle(fontSize: 19.0, color: Colors.black)),
                  onPressed: pujar,
                )
              : Container()
        ],
      ),
    );

    final ThemeData theme = Theme.of(context);
    final TextStyle descriptionStyle = theme.textTheme.subhead;
    // Item en venta o no (también tener en cuenta si es nulo)
    bool _itemEnVenta = (_item?.status ?? "en venta") == "en venta";
    // Subasta fuera de fecha o no

    // Ubicación del dueño
    CameraPosition _cameraPosition;
    if (_item?.owner?.locationLat != null &&
        _item?.owner?.locationLng != null &&
        _item?.owner?.userId != null) {
      LatLng movedLL = LatLng(_item.owner.locationLat, _item.owner.locationLng);
      // Posición de cámara para mostrarla en el mapa
      _cameraPosition = CameraPosition(
        target: movedLL,
        zoom: 14.5,
      );
    }
    return new Scaffold(
      key: _scaffoldKey,
      floatingActionButton: _item.type == "auction" &&
              _item.status != "vendido" &&
              _item.itemId != 0 &&
              miId != _item.owner?.userId
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
                                    child: _item.itemId == 0
                                        ? Container()
                                        : (_favoriteFunction == null
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
                                              )),
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
                                                            ? _item.status !=
                                                                    "vendido"
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
                                                                _item.status !=
                                                                        "vendido"
                                                                    ? 'Activa'
                                                                    : _item.lastBid ==
                                                                                null ||
                                                                            miId ==
                                                                                _item
                                                                                    .owner.userId
                                                                        ? 'Cerrada'
                                                                        : _item.lastBid.bidder.userId ==
                                                                                miId
                                                                            ? 'Ganada'
                                                                            : 'Perdida',
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
                    _item?.status == "vendido" &&
                            (_item?.buyer?.userId == miId ||
                                _item?.lastBid?.bidder?.userId == miId ||
                                _item?.owner?.userId == miId)
                        ? _buildRateButton()
                        : Container(),
                    _cameraPosition == null
                        ? Container()
                        : _buildOwnerMap(_cameraPosition)
                  ]))))),
    );
  }
}
