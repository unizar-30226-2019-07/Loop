import 'package:date_format/date_format.dart';
import 'package:selit/class/image_class.dart';
import 'package:selit/util/storage.dart';

/// Datos de usuario registrado, ya sea para mostrarlos en el perfil
/// o para cualquier otro uso. Puede tener campos nulos aunque sean
/// campos obligatorios para un usuario registrado, ya que un campo nulo
/// representa el usuario por defecto hasta que cargue el usuario real
class UsuarioClass {
  int userId;
  String nombre;
  String apellidos;
  String sexo;
  String email;
  int edad;
  DateTime nacimiento;
  double numeroEstrellas;
  int reviews;
  String token;
  double locationLat;
  double locationLng;
  ImageClass profileImage;

  UsuarioClass(
      {this.userId,
      this.nombre,
      this.apellidos,
      this.sexo,
      this.email,
      this.edad,
      this.numeroEstrellas,
      this.reviews,
      this.token,
      this.nacimiento,
      this.locationLat,
      this.locationLng,
      this.profileImage})
      : assert(edad == null || edad > 0,
            'Un usuario no puede tener edad negativa'),
        assert(reviews == null || reviews > 0,
            'Un usuario no puede tener número de reviews negativo'),
        assert(
            numeroEstrellas == null ||
                numeroEstrellas >= 0 && numeroEstrellas <= 5,
            'Un usuario debe tener un número de estrellas entre 1 y 5');

  UsuarioClass.fromJson(Map<String, dynamic> json, String tokenHeader)
      : this(
            userId: json['idUsuario'],
            nombre: json['first_name'],
            apellidos: json['last_name'],
            edad: 18,
            reviews: 30,
            numeroEstrellas: json['rating'],
            sexo: json["gender"],
            email: json["email"],
            locationLat: json['location']['lat'],
            locationLng: json['location']['lng'],
            profileImage: ImageClass.network(
              imageId: json['picture']['idImagen'],
              tokenHeader: tokenHeader,
            ));

  void update(
      {String nombre,
      String apellidos,
      String sexo,
      double locationLat,
      double locationLng,
      ImageClass image}) {
    this.nombre = nombre;
    this.apellidos = apellidos;
    this.sexo = sexo;
    this.locationLat = locationLat;
    this.locationLng = locationLng;
    this.profileImage = image;
  }

  Map<String, dynamic> toJsonEdit() => {
        "email": email,
        "first_name": nombre,
        "last_name": apellidos,
        "gender": sexo,
        "location": {
          "lat": locationLat,
          "lng": locationLng,
        },
        "picture": profileImage.toJson(),
      };

  Map<String, dynamic> toJsonForSignUp() => {
        "email": email,
        "first_name": nombre,
        "last_name": apellidos,
        "location": {
          "lat": locationLat,
          "lng": locationLng,
        },
      };
}
