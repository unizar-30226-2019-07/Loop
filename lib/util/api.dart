import 'package:selit/class/usuario_class.dart';

class API { // TODO elegir un nombre mejor
  
  /// Realiza una petición GET para obtener los datos del usuario
  /// userId y al recibirlos actualiza el perfil para que muestre
  /// los datos de dicho usuario
  static Future<UsuarioClass> getUser(userId) async {
    // TODO hacer una petición en lugar de simular una carga de 1 segundo
    // y usar el constructor de JSON
    return Future.delayed(Duration(seconds: 3), () {
      print('cargando el perfil con id ' + userId.toString());
      return new UsuarioClass(
          nombre: 'Nombre',
          apellidos: 'Apellidos',
          sexo: 'Hombre',
          edad: 21,
          ubicacionCiudad: 'Zaragoza',
          ubicacionResto: 'Aragon, España',
          numeroEstrellas: 2.5,
          reviews: 30,
          urlPerfil:
              'https://avatars0.githubusercontent.com/u/17049331');
    });
  }

}