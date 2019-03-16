import 'package:flutter/material.dart';

/// Perfil de usuario, tal como aparece en el wireframe
/// dividido en dos partes: profile_user (superior) y profile_products (inferior)
class StarRating extends StatelessWidget {
  // TODO posibilidad de añadir funcionalidad (mover las estrellas al tocar una)
  // https://stackoverflow.com/questions/46637566/how-to-create-rating-star-bar-properly

  final _starColor = Colors.yellow[600];

  final double starRating;

  StarRating({Key key, this.starRating}) : super(key: key);

  /// Devuelve una estrella entera, media o vacía dependiendo
  /// de la puntuación y el numero de estrella a mostrar
  Widget _getStar(double starRating, int starNumber) {
    if (starRating <= starNumber) {
      return Icon(Icons.star_border, color: _starColor);
    } else if (starRating >= starNumber + 1) {
      return Icon(Icons.star, color: _starColor);
    } else {
      return Icon(Icons.star_half, color: _starColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          new List.generate(5, (i) => Expanded(child: _getStar(starRating, i))),
    );
  }
}
