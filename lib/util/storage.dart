import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstracción de lectura/escritura de variables que se quieren leer/escribir
/// en diferentes puntos de la aplicación
class Storage {
  
  static const String TOKEN_KEY = 'token'; // Key para guardar el token de usuario
  static const String USER_ID_KEY = 'user_id'; // Key para guardar el ID de usuario
  static const String LAT_KEY = 'lat';
  static const String LNG_KEY = 'lng';

  static final _secureStorage = new FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: TOKEN_KEY, value: token);
  }

  static Future<String> loadToken() async {
    return await _secureStorage.read(key: TOKEN_KEY);
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: TOKEN_KEY);
  }

  static Future<void> saveUserId(int userId) async {
    await _secureStorage.write(key: USER_ID_KEY, value: userId.toString());
  }

  static Future<int> loadUserId() async {
    String intStr = await _secureStorage.read(key: USER_ID_KEY);
    if (intStr == null) {
      return -1;
    } else {
      return int.parse(intStr);
    }
  }

  static Future<void> saveLocation(double lat, double lng) async {
    await _secureStorage.write(key: LAT_KEY, value: lat.toString());
    await _secureStorage.write(key: LNG_KEY, value: lng.toString());
  }

  static Future<double> loadLat() async {
    String str = await _secureStorage.read(key: LAT_KEY);
    if (str == null) {
      return 0.0;
    } else {
      return double.parse(str);
    }
  }

  static Future<double> loadLng() async {
    String str = await _secureStorage.read(key: LNG_KEY);
    if (str == null) {
      return 0.0;
    } else {
      return double.parse(str);
    }
  }

}