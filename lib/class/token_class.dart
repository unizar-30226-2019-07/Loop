/// Token de sesión a emplear en la aplicación
/// Abstraido en una clase separada por si se decide cambiar
/// su representación de String a otro tipo de dato
class TokenClass {

  String token;

  TokenClass(this.token);

  TokenClass.fromJson(Map<String, dynamic> json) {
    this.token = json['token'];
  }

}