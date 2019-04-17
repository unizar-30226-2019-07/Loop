import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/image_class.dart';
import 'package:intl/intl.dart';

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
      this.media})
      : assert(type == null || type == "sale" || type == "auction",
            'Tipo inválido para un item (venta/subasta)'),
        assert(status == null || status == "en venta" || status == "vendido",
            'Status inválido para un item (en venta/vendido)'),
        assert(distance == null || distance >= 0,
            'La distancia debe ser al menos 0'),
        assert(price == null || price >= 0, 'El precio debe ser al menos 0'),
        assert(numViews == null || numViews >= 0,
            'El número de visitas debe ser al menos 0'),
        assert(numLikes == null || numLikes >= 0,
            'El número de likes debe ser al menos 0');

  static List<ImageClass> _getImages(List<dynamic> json, String tokenHeader) {
    List<ImageClass> images = List<ImageClass>();
    if (json != null) {
      json.forEach((imageJson) {
        images.add(ImageClass.network(imageId: imageJson['idImagen'], tokenHeader: tokenHeader));
      });
    }
    return images;
  }

  /// Constructor a partir de JSON
  ItemClass.fromJson(Map<String, dynamic> json, String tokenHeader)
      : this(
            itemId: json['id_producto'],
            type: json['type'],
            title: json['title'],
            description: json['description'],
            published: DateFormat("yyyy-MM-dd").parse(json['publicate_date']),
            locationLat: json['location']['lat'],
            locationLng: json['location']['lng'],
            distance: json['distance'],
            category: json['category'],
            price: json['price'],
            currency: json['currency'],
            status: json['status'],
            numViews: json['nvis'],
            numLikes: json['nfav'],
            owner: UsuarioClass.fromJson(json['owner'], tokenHeader),
            media: _getImages(json['media'], tokenHeader)
          );

  void update({String type, double price, String currency}) {
    this.type = type;
    this.price = price;
    this.currency = currency;
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
  
}
