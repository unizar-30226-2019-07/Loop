import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/image_class.dart';
import 'package:selit/class/items/filter_list_class.dart';
import 'package:intl/intl.dart';
import 'package:selit/class/lastBid_class.dart';

/// Objeto/producto en venta de la aplicación, almacena información
/// sobre su descripción, su tipo de venta y el usuario vendedor (ver [UsuarioClass])
/// Para ver más información acerca de las imágenes del producto, ver [ImageClass]
class ItemClass {
  int itemId;
  String type; // sale / auction
  String title;
  String description;
  DateTime published; // día/hora de publicación
  double locationLat;
  double locationLng;
  double distance; // distancia del usuario a ([locationLat], [locationLng])
  String category; // informática, automoción, etc
  double price; // precio en cualquier moneda
  String currency; // eur, usd, etc.
  String status; // en venta / vendido
  int numViews;
  int numLikes;
  UsuarioClass owner; // vendedor del item
  List<ImageClass> media; // lista de 0+ imágenes
  bool favorited; // si está en la lista de deseados
  DateTime endDate; //Fecha de finalización   yyyy-MM-dd
  LastBid lastBid;

  /// Constructor por defecto, comprobar que los atributos son correctos
  ItemClass(
      {this.itemId,
      this.type,
      this.title,
      this.description,
      this.published,
      this.locationLat,
      this.locationLng,
      this.distance,
      this.category,
      this.price,
      this.currency,
      this.status,
      this.numViews,
      this.numLikes,
      this.owner,
      this.media,
      this.favorited,
      this.endDate, 
      this.lastBid})
      : assert(type == null || type == "sale" || type == "auction",
            'Tipo inválido para un item (venta/subasta)'),
        assert(status == null || status == "en venta" || status == "vendido",
            'Status inválido para un item (en venta/vendido)'),
        assert(
            category == null ||
                FilterListClass.categoryNames.containsKey(category),
            'Categoría no válida para el item: $category'),
        assert(distance == null || distance >= 0,
            'La distancia debe ser al menos 0'),
        assert(title == null || title.length <= 50,
            'El título de un producto debe tener como máximo 50 caracteres'),
        assert(description == null || description.length <= 300,
            'La descripción de un producto debe tener como máximo 300 caracteres'),
        assert(price == null || price >= 0, 'El precio debe ser al menos 0'),
        assert(numViews == null || numViews >= 0,
            'El número de visitas debe ser al menos 0'),
        assert(numLikes == null || numLikes >= 0,
            'El número de likes debe ser al menos 0');

  static List<ImageClass> _getImages(List<dynamic> json, String tokenHeader) {
    List<ImageClass> images = List<ImageClass>();
    if (json != null) {
      json.forEach((imageJson) {
        images.add(ImageClass.network(
            imageId: imageJson['idImagen'], tokenHeader: tokenHeader));
      });
    }
    return images;
  }

  /// Constructor a partir de JSON
  ItemClass.fromJsonProducts(Map<String, dynamic> json, String tokenHeader)
      : this(
            itemId: json['id_producto'],
            type: 'sale',
            title: json['title'],
            description: json['description'],
            published: json['publicate_date'] == null
                ? null
                : DateFormat("yyyy-MM-dd").parse(json['publicate_date']),
            locationLat: json['location']['lat'],
            locationLng: json['location']['lng'],
            distance: json['distance'],
            category: json['category'],
            price: json['price'],
            currency: json['currency'],
            status: json['status'],
            numViews: json['nvis'],
            numLikes: json['nfav'],
            favorited: json['in_wishlist'],
            owner: UsuarioClass.fromJson(json['owner'], tokenHeader),
            media: _getImages(json['media'], tokenHeader));
  
  /// Constructor a partir de JSON (auctions)
  ItemClass.fromJsonAuctions(Map<String, dynamic> json, String tokenHeader)
      : this(
            itemId: json['idSubasta'],
            type: "auction",
            title: json['title'],
            description: json['description'],
            published: json['published'] == null
               ? null
               : DateFormat("yyyy-MM-dd").parse(json['published']),
            locationLat: json['location']['lat'],
            locationLng: json['location']['lng'],
            distance: json['distance'],
            category: json['category'],
            price: json['startPrice'],
            currency: json['currency'],
            status: json['status'],
            numViews: json['nvis'],
            numLikes: json['nfav'],
            favorited: json['in_wishlist'],
            owner: UsuarioClass.fromJson(json['owner'], tokenHeader),
            endDate: json['endDate'] == null
                ? null
               : DateFormat("yyyy-MM-dd").parse(json['endDate']),
            lastBid: json['lastBid'] == null
              ? null
              : LastBid.fromJson(json['lastBid'], tokenHeader),
            media: _getImages(json['media'], tokenHeader)
           );

  void update({String type, double price, String currency}) {
    this.type = type;
    this.price = price;
    this.currency = currency;
  }

  void updateAuction(
      {String type,
      double price,
      String currency,
      DateTime endDate}) {
    this.type = type;
    this.price = price;
    this.currency = currency;
    this.endDate = endDate;

  }

  bool isAuction() {
    return this.type.compareTo("auction") == 0;
  }

  Map<String, dynamic> toJsonCreate() => {
        "type": type,
        "title": title,
        "owner_id": owner.userId,
        "description": description,
        "location": {
          "lat": locationLat,
          "lng": locationLng,
        },
        "category": category,
        "price": price,
        "currency": currency,
        "media": List.generate(media.length, (i) => media[i].toJson()),
      };

  Map<String, dynamic> toJsonCreateAuction() => {
        "type": type,
        "title": title,
        "owner_id": owner.userId,
        "description": description,
        "location": {
          "lat": locationLat,
          "lng": locationLng,
        },
        "category": category,
        "startPrice": price,
        "currency": currency,
        "media": List.generate(media.length, (i) => media[i].toJson()),
        "endDate": _dateTimeString(endDate),
      };

  Map<String, dynamic> toJsonEdit() => {
        "type": type,
        "title": title,
        "owner_id": owner.userId,
        "description": description,
        "location": {
          "lat": locationLat,
          "lng": locationLng,
        },
        "category": category,
        "price": price,
        "currency": currency,
        "status": status,
        "media": List.generate(media.length, (i) => media[i].toJson()),
      };

  String _dateTimeString(DateTime fecha) {
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2
    , '0')}';
  } 

  Map<String, dynamic> toJsonEditAuction() => {
        "type": type,
        "title": title,
        "owner_id": owner.userId,
        "description": description,
        "location": {
          "lat": locationLat,
          "lng": locationLng,
        },
        "category": category,
        "startPrice": price,
        "currency": currency,
        "media": List.generate(media.length, (i) => media[i].toJson()),
        "status": status,
        "endDate": _dateTimeString(endDate),
      };
}
