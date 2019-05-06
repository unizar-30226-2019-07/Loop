import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:selit/util/bubble_indication_painter.dart';
import 'package:selit/widgets/items/item_tile.dart';
import 'package:selit/util/bar_color.dart';

/// Lista de productos o subastas deseados por el usuario,
/// en dos listas de igual forma que se muestra en el perfil
class Wishes extends StatefulWidget {
  final UsuarioClass user;

  Wishes({@required this.user});

  @override
  _WishesState createState() => new _WishesState(user);
}

class _WishesState extends State<Wishes> {
  // Estilos para los diferentes textos
  static final _styleTitle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.white);
  static final _styleNothing =
      const TextStyle(fontSize: 20.0, color: Colors.grey);

  /// Controlador tabs "en venta" y "vendido"
  PageController _pageController = PageController(initialPage: 0);

  /// Controlador listas "en venta" y "vendido"
  ScrollController _controllerProducts =
      ScrollController(initialScrollOffset: 0, keepScrollOffset: false);
  ScrollController _controllerAuctions =
      ScrollController(initialScrollOffset: 0, keepScrollOffset: false);

  /// Color de "en venta" (necesario alternarlo entre blanco-negro)
  Color _tabColorLeft = Colors.black;

  /// Color de "vendido" (necesario alternarlo entre blanco-negro)
  Color _tabColorRight = Colors.white;

  // Objetos en venta y vendidos
  List<ItemClass> _wishlistProducts = <ItemClass>[];
  bool _wishListProductsEmpty = false; // diferenciar entre cargando y no hay
  List<ItemClass> _wishlistAuctions = <ItemClass>[];
  bool _wishListAuctionsEmpty = false; // diferenciar entre cargando y no hay
  bool _cancelled; // evitar bug al pedir objetos y cambiar de pantalla

  UsuarioClass _user;

  _WishesState(this._user) {
    _loadProfileItems();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelled = true;
  }

  void _loadProfileItems() async {
    if (_user?.locationLat == null || _user?.locationLng == null) {
      print('ERROR: Intentando cargar objetos sin tener un usuario');
    } else {
      // Cargar los objetos deseados (productos y subastas) del usuario
      UsuarioRequest.getWishlist(
              auctions: false, lat: _user.locationLat, lng: _user.locationLng)
          .then((wishlistProducts) {
        _cancelled = false;
        if (!_cancelled) {
          setState(() {
            if (wishlistProducts.isEmpty) {
              _wishListProductsEmpty = true;
            } else {
              _wishlistProducts = wishlistProducts;
            }
          });
        }
      }).catchError((error) {
        print('Error al cargar los productos deseados: $error');
        _wishListProductsEmpty = true;
      });
      UsuarioRequest.getWishlist(
              auctions: true, lat: _user.locationLat, lng: _user.locationLng)
          .then((wishlistAuctions) {
        if (!_cancelled) {
          setState(() {
            if (wishlistAuctions.isEmpty) {
              _wishListAuctionsEmpty = true;
            } else {
              _wishlistAuctions = wishlistAuctions;
            }
          });
        }
      }).catchError((error) {
        print('Error al cargar las subastas deseadas: $error');
        _wishListAuctionsEmpty = true;
      });
    }
  }

  // Pulsación del boton "ventas"
  void _onPressedProducts() {
    _pageController.animateToPage(0,
        duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    if (_controllerProducts.hasClients) {
      _controllerProducts.animateTo(0,
          duration: Duration(milliseconds: 150), curve: Curves.linear);
    }
  }

  // Pulsación del boton "subastas"
  void _onPressedAuctions() {
    _pageController.animateToPage(1,
        duration: Duration(milliseconds: 300), curve: Curves.decelerate);
    if (_controllerAuctions.hasClients) {
      _controllerAuctions.animateTo(0,
          duration: Duration(milliseconds: 150), curve: Curves.linear);
    }
  }

  /// Indicación de lista vacía (se ha recibido info de que es vacía)
  Widget _buildEmptyList() {
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
  }

  /// Todavía no se ha recibido información sobre la lista
  Widget _buildLoadingList() {
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

  /// Lista de productos (no subastas) deseados
  Widget _buildProductList() {
    if (_wishlistProducts.isEmpty) {
      if (_wishListProductsEmpty) {
        return _buildEmptyList();
      } else {
        return _buildLoadingList();
      }
    } else {
      return Container(
        margin: EdgeInsets.only(top: 5),
        child: ListView.builder(
          controller: _controllerProducts,
          padding: EdgeInsets.symmetric(horizontal: 15),
          itemCount: _wishlistProducts.length,
          itemBuilder: (context, index) =>
              ItemTile(_wishlistProducts[index], index % 2 == 0),
        ),
      );
    }
  }

  /// Lista de subastas (no productos) deseados
  Widget _buildAuctionList() {
    if (_wishlistAuctions.isEmpty) {
      if (_wishListAuctionsEmpty) {
        return _buildEmptyList();
      } else {
        return _buildLoadingList();
      }
    } else {
      return Container(
        margin: EdgeInsets.only(top: 5),
        child: ListView.builder(
          controller: _controllerAuctions,
          padding: EdgeInsets.symmetric(horizontal: 15),
          itemCount: _wishlistAuctions.length,
          itemBuilder: (context, index) =>
              ItemTile(_wishlistAuctions[index], index % 2 == 0),
        ),
      );
    }
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

  /// Toda la pantalla, dos tabs con las dos listas
  Widget _buildWishlist() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.fromLTRB(20.0, 25.0, 0.0, 15.0),
            child: Text('Lista de deseados', style: _styleTitle),
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(50.0),
                child: Container(
                  margin: EdgeInsets.symmetric(
                      horizontal:
                          (MediaQuery.of(context).size.width - 300) / 2),
                  decoration: BoxDecoration(
                    color: Color(0x552B2B2B),
                    borderRadius: BorderRadius.all(Radius.circular(25.0)),
                  ),
                  child: CustomPaint(
                    painter:
                        TabIndicationPainter(pageController: _pageController),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildTabButton(
                            "Ventas", _onPressedProducts, _tabColorLeft),
                        _buildTabButton(
                            "Subastas", _onPressedAuctions, _tabColorRight),
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
                  children: <Widget>[_buildProductList(), _buildAuctionList()]),
            ),
          )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    BarColor.changeBarColor(color: Colors.transparent, whiteForeground: true);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment(0.15, -1.0),
              end: Alignment(-0.15, 1.0),
              stops: [
                0.35,
                0.35
              ],
              colors: [
                Theme.of(context).primaryColor,
                Colors.grey[100],
              ]),
        ),
        child: SafeArea(
          child: _buildWishlist(),
        ),
      ),
    );
  }
}
