import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/image_class.dart';

/// Objeto/producto en venta de la aplicación, almacena información
/// sobre su descripción, su tipo de venta y el usuario vendedor (ver [UsuarioClass])
/// Para ver más información acerca de las imágenes del producto, ver [ImageClass]
class ItemClass {
  int itemId;
  String type; // venta, subasta, TODO enum?
  String title;
  String description;
  DateTime published; // día/hora de publicación
  double locationLat;
  double locationLng;
  double distance; // distancia del usuario a ([locationLat], [locationLng])
  String category; // informática, automoción, etc
  double price; // precio en cualquier moneda
  String currency; // eur, usd, etc.
  String status; // TODO enum?
  int numViews;
  int numLikes;
  UsuarioClass owner; // vendedor del item
  List<ImageClass> images; // lista de 0+ imágenes

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

      this.images})
      : assert(type == null || type == "sale" || type == "auction",
            'Tipo inválido para un item (venta/subasta)'),
        assert(distance == null || distance > 0,
            'La distancia debe ser al menos 0'),
        assert(price == null || price >= 0, 'El precio debe ser al menos 0'),
        assert(numViews == null || numViews >= 0,
            'El número de visitas debe ser al menos 0'),
        assert(numLikes == null || numLikes >= 0,
            'El número de likes debe ser al menos 0');

  /// Constructor a partir de JSON
  ItemClass.fromJson(Map<String, dynamic> json)
      : this(
            itemId: json['id_producto'],
            type: json['type'],
            title: json['title'],
            description: json['description'],
            published: DateTime.now() /* TODO */,
            locationLat: json['location']['lat'],
            locationLng: json['location']['lng'],
            distance: json['distance'],
            category: json['category'],
            price: json['price'],
            currency: json['currency'],
            status: json['status'],
            numViews: json['nvis'],
            numLikes: json['nfav'],
            owner: UsuarioClass(), //UsuarioClass.fromJson(json['owner']), TODO ubicacion
            images: List<ImageClass>() /* TODO */);

  void update(String _type, double _price, String _currency) {
    this.type = _type;
    this.price = _price;
    this.currency = _currency;
  }


  Map<String, dynamic> toJsonCreate() => {
        "type": type,
        "title": title,
        "owner_id": 88,
        "description": description,
        "location": {
          "lat": locationLat,
          "lng": locationLng,
        },
        "category": category,
        "price": price,
        "currency": currency,
      };
}
