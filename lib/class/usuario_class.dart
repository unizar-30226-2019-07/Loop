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
  int edad;
  String ubicacionCiudad; // Ej: Zaragoza
  String ubicacionResto; // Ej: Aragon, España
  double numeroEstrellas;
  int reviews;
  String urlPerfil;

  UsuarioClass(
      {this.nombre,
      this.apellidos,
      this.sexo,
      this.edad,
      this.ubicacionCiudad,
      this.ubicacionResto,
      this.numeroEstrellas,
      this.reviews,
      this.urlPerfil})
      : assert(edad > 0, 'Un usuario no puede tener edad negativa'),
        assert(reviews > 0,
            'Un usuario no puede tener número de reviews negativo'),
        assert(numeroEstrellas >= 1 && numeroEstrellas <= 5,
            'Un usuario debe tener un número de estrellas entre 1 y 5');

  // TODO una vez acordado el formato del JSON, crear el constructor
  //UsuarioClass.fromJson(Map<String, dynamic> json)
  //    : this(nombre: json['nombre'], apellidos: json['apellidos']);

}
