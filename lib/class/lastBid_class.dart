import 'package:selit/class/usuario_class.dart';
import 'package:intl/intl.dart';

class LastBid {
  double amount;
  UsuarioClass bidder;
  DateTime date;


  /// Constructor por defecto, comprobar que los atributos son correctos
  LastBid(
      {this.amount,
      this.bidder,
      this.date})
      : assert(amount == null || amount >= 0, 'El precio debe ser al menos 0');


  /// Constructor a partir de JSON
  LastBid.fromJson(Map<String, dynamic> json, String tokenHeader)
      : this(
            amount: json['amount'],
            bidder: UsuarioClass.fromJson(json['bidder'], tokenHeader),
            date: json['date'] == null
                ? null
                : DateFormat("yyyy-MM-dd").parse(json['date']));
}
