

/// Datos de usuario registrado, ya sea para mostrarlos en el perfil
/// o para cualquier otro uso. Puede tener campos nulos aunque sean
/// campos obligatorios para un usuario registrado, ya que un campo nulo
/// representa el usuario por defecto hasta que cargue el usuario real
class UsuarioClass {
  // TODO por ahora contiene los datos que se muestran en el perfil,
  // supongo más adelante contendrá toda la información relacionada
  String nombre;
  String apellidos;
  String sexo;
  String email;
  int edad;
  String ubicacionCiudad; // Ej: Zaragoza
  String ubicacionResto; // Ej: Aragon, España
  double numeroEstrellas;
  int reviews;
  String urlPerfil;
  int user_id;
  double locationLat;
  double locationLng;
  String pictureMime;
  String pictureCharset;
  String pictureBase64;

  UsuarioClass(
      {
      this.nombre,
      this.apellidos,
      this.sexo,
      this.email,
      this.edad,
      this.ubicacionCiudad,
      this.ubicacionResto,
      this.numeroEstrellas,
      this.reviews,
      this.urlPerfil,
      this.user_id,
      this.pictureBase64,
      this.pictureCharset,
      this.pictureMime,
      this.locationLat,
      this.locationLng})
      : assert(edad == null || edad > 0, 'Un usuario no puede tener edad negativa'),
        assert(reviews == null || reviews > 0,
            'Un usuario no puede tener número de reviews negativo'),
        assert(numeroEstrellas == null || numeroEstrellas >= 0 && numeroEstrellas <= 5,
            'Un usuario debe tener un número de estrellas entre 1 y 5');

  UsuarioClass.fromJson(Map<String, dynamic> json)
      : this(
            user_id: json['idUsuario'],
            nombre: json['first_name'],
            apellidos: json['last_name'],
            edad: 18,
            reviews: 30,
            numeroEstrellas: json['rating'],
            sexo: json["gender"],
            email: json["email"],
            locationLat: json['location']['lat'],
            locationLng: json['location']['lng'],
            pictureMime: json['picture']['mime'],
            pictureCharset: json['picture']['charset'],
            pictureBase64: json['picture']['base64'],

            );

  void update(String _nombre, String _apellidos, String _sexo, double lat, double long, String _mime, String _base64, String _charset){
    this.nombre=_nombre;
    this.apellidos=_apellidos;
    this.sexo=_sexo;
    this.locationLat=lat;
    this.locationLng=long;
    this.pictureBase64 = _base64;
    this.pictureCharset = _charset;
    this.pictureMime= _mime;
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
    "picture": {
      "mime" : pictureMime,
      "charset" : pictureCharset,
      "base64" : pictureBase64
    },
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
