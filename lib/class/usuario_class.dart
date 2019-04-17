import 'package:selit/class/image_class.dart';
import 'package:intl/intl.dart';

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
      this.numeroEstrellas,
      this.reviews,
      this.token,
      this.nacimiento,
      this.locationLat,
      this.locationLng,
      this.profileImage})
      : assert(reviews == null || reviews > 0,
            'Un usuario no puede tener número de reviews negativo'),
        assert(
            sexo == null ||
                sexo == "hombre" ||
                sexo == "mujer" ||
                sexo == "otro",
            'Un usuario debe tener sexo "hombre", "mujer" u "otro".'),
        assert(nombre == null || nombre.length <= 50,
            'El nombre de un usuario debe tener como máximo 50 caracteres'),
        assert(apellidos == null || apellidos.length <= 100,
            'Los apellidos de un usuario deben tener como máximo 100 caracteres'),
        assert(email == null || email.length <= 100,
            'El email de un usuario debe tener como máximo 100 caracteres'),
        assert(
            numeroEstrellas == null ||
                numeroEstrellas >= 0 && numeroEstrellas <= 5,
            'Un usuario debe tener un número de estrellas entre 1 y 5');

  UsuarioClass.fromJson(Map<String, dynamic> json, String tokenHeader)
      : this(
            userId: json['idUsuario'],
            nombre: json['first_name'],
            apellidos: json['last_name'],
            reviews: 30, // TODO esperar a que se implemente en la API
            numeroEstrellas: json['rating'],
            nacimiento: json['birth_date'] == null
                ? null
                : DateFormat("yyyy-MM-dd").parse(json['birth_date']),
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
      String email,
      double locationLat,
      double locationLng,
      DateTime nacimiento,
      ImageClass image}) {
    this.nombre = nombre;
    this.apellidos = apellidos;
    this.sexo = sexo;
    this.email = email;
    this.locationLat = locationLat;
    this.locationLng = locationLng;
    this.nacimiento = nacimiento;
    this.profileImage = image;
  }

  String _nacimientoString(DateTime fecha) {
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJsonEdit() => {
        "email": email,
        "first_name": nombre,
        "last_name": apellidos,
        "gender": sexo,
        "birth_date": nacimiento != null ? _nacimientoString(nacimiento) : null,
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
