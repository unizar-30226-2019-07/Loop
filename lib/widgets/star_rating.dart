import 'package:flutter/material.dart';

/// Widget con rating de estrellas (estático) de 1 a 5 (sin incluir el 0)
/// Ejemplo de uso: child: StarRating(starRating: 3.5)
class StarRating extends StatelessWidget {
  // TODO posibilidad de añadir funcionalidad (mover las estrellas al tocar una)
  // https://stackoverflow.com/questions/46637566/how-to-create-rating-star-bar-properly

  final starColor;
  final starSize;
  final double starRating;
  final bool profileView;

  StarRating({Key key, this.starRating, this.starColor, this.profileView, this.starSize})
      : assert(starRating >= 0 && starRating <= 5,
            'El valor de starRating debe estar entre 0 y 5'),
        super(key: key);

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
    if(this.profileView){
      return Row(
        children:
          new List.generate(5, (i) => Expanded(child: _getStar(starRating, i))),          
      );
    }
    else{
      return Row(
        children:
          new List.generate(5, (i) => Container(child: _getStar(starRating, i))),          
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _createStars();
  }
}
