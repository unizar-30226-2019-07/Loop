import 'package:flutter/material.dart';

/// Widget con rating de estrellas (dinámico) de 1 a 5 (sin incluir el 0)
/// NOTA IMPORTANTE: esta hecho para que solamente uno pueda aparecer en pantalla
/// a la vez (currentRating es static)
class StarRatingInteractive extends StatefulWidget {
  final Color starColor;
  final double starSize;

  // Accesible para obtener las estrellas actuales
  static double currentRating;

  StarRatingInteractive({Key key, this.starColor, this.starSize})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _StarRatingInteractiveState(starColor, starSize);
}

class _StarRatingInteractiveState extends State<StarRatingInteractive> {
  final Color starColor;
  final double starSize;

  _StarRatingInteractiveState(this.starColor, this.starSize) {
    StarRatingInteractive.currentRating = 5;
  }

  /// Devuelve una estrella entera, media o vacía dependiendo
  /// de la puntuación y el numero de estrella a mostrar
  Widget _getStar(double starRating, int starNumber) {
    if (starRating <= starNumber) {
      return Icon(Icons.star_border, color: starColor, size: starSize);
    } else if (starRating >= starNumber + 1) {
      return Icon(Icons.star, color: starColor, size: starSize);
    } else {
      return Icon(Icons.star_half, color: starColor, size: starSize);
    }
  }

  Widget _createStars() {
    return Row(
      children: new List.generate(
        5,
        (i) => Expanded(
              child: IconButton(
                icon: _getStar(StarRatingInteractive.currentRating, i),
                onPressed: () => setState(() {
                      StarRatingInteractive.currentRating = (i + 1).toDouble();
                    }),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _createStars();
  }
}
