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
      this.user_id})
      : assert(edad > 0, 'Un usuario no puede tener edad negativa'),
        assert(reviews > 0,
            'Un usuario no puede tener número de reviews negativo'),
        assert(numeroEstrellas >= 1 && numeroEstrellas <= 5,
            'Un usuario debe tener un número de estrellas entre 1 y 5');

  UsuarioClass.fromJson(Map<String, dynamic> json)
      : this(
            user_id: json['id'],
            nombre: json['first_name'],
            apellidos: json['last_name'],
            edad: 18,
            reviews: 30,
            numeroEstrellas: json['rating'],
            sexo: json["gender"],
            email: json["email"]);

  void update(String _nombre, String _apellidos, String _sexo){
    this.nombre=_nombre;
    this.apellidos=_apellidos;
    this.sexo=_sexo;
  }

  Map<String, dynamic> toJsonEdit() => {
    "email": email,
    "first_name": nombre,
    "last_name": apellidos,
    "gender": sexo,
  };
}

/*
    idUsuario: json["idUsuario"],
    gender: json["gender"],
    birth_date: json["birth_date"],
    posX: json["posX"],
    posY: json["posY"],
    rating: json["rating"],
    status: json["status"],
    email: json["email"],
    last_name: json["last_name"],
    first_name: json["first_name"],
    usuario: json["usuario"],
  */
