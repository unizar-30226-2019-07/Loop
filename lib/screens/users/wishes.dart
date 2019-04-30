import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/util/api/item_request.dart';
import 'package:selit/util/bubble_indication_painter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/widgets/items/item_tile.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';


class Wishes extends StatefulWidget {
  final UsuarioClass user;

  Wishes({@required this.user});

  @override
  _WishesState createState() => new _WishesState(user);
}

class _WishesState extends State<Wishes> {
  // Estilos para los diferentes textos
  static final _styleNothing =
      const TextStyle(fontSize: 20.0, color: Colors.grey);

  /// Controlador tabs "en venta" y "vendido"
  PageController _pageController = PageController(initialPage: 0);

  /// Controlador listas "en venta" y "vendido"
  ScrollController _controllerEnVenta =
      ScrollController(initialScrollOffset: 0, keepScrollOffset: false);

  // Objetos en venta y vendidos
  List<ItemClass> _itemsEnVenta = <ItemClass>[];
  bool _itemsEnVentaEmpty = false; // diferenciar entre cargando y no hay
  bool _cancelled; // evitar bug al pedir objetos y cambiar de pantalla

  /// Usuario a mostrar en el perfil (null = placeholder)
  UsuarioClass _user;
  int _loggedUserId;

  _WishesState(UsuarioClass _user) {
    this._user = _user;
    ///TODO: Actualmente carga la lista de productos en venta para debug. Cambiar por lista de deseos.
    _loadProfileItems();
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
      });
    }
  }
  Widget _buildProductList() {
    Widget wProductListSelling;

    if (_itemsEnVenta.isEmpty) {
      if (_itemsEnVentaEmpty) {
        return SizedBox.expand(
            // expandir horizontalmente
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.not_interested, color: Colors.grey, size: 65.0),
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Text('Nada por aquí...', style: _styleNothing),
            )
          ],
        ));
      } else {
        return SizedBox.expand(
            // expandir horizontalmente
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(
                strokeWidth: 5.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600])),
          ],
        ));
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
              
              
            ),
          ),
        ),
      ),
      body: wProductListSelling,
    );

    return Column(
      children: <Widget>[
        Expanded(
          child: wProductList,
        ),
      ],
    );

  }
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return Scaffold(
      appBar: new AppBar(
        leading: Container(),
        title: new Text("Lista de deseos",
            style: TextStyle(
                fontSize: 22.0,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment(0.15, -1.0),
              end: Alignment(-0.15, 1.0),
              stops: [
                0.4,
                0.4
              ],
              colors: [
                Theme.of(context).primaryColor,
                Colors.grey[100],
              ]),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  child: _buildProductList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}