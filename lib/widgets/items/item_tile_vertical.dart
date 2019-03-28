import 'package:flutter/material.dart';
import 'package:selit/class/item_class.dart';

/// Tile de objeto para la visualizacion en 2 columnas
/// TODO sin terminar, por ahora solo muestra la imagen
class ItemTileVertical extends StatelessWidget {
  final ItemClass _item;
  ItemTileVertical(this._item);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Widget>[
            //SectionTitle(title: 'Tappable'),
            SizedBox(
              width: double.infinity,
              child: Card(
                // This ensures that the Card's children (including the ink splash) are clipped correctly.
                clipBehavior: Clip.antiAlias,
                //shape: shape,
                child: InkWell(
                  onTap: () {
                    print('Card was tapped'); //Acción asociada (ir a item details)
                  },
                  // Generally, material cards use onSurface with 12% opacity for the pressed state.
                  splashColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                  // Generally, material cards do not have a highlight overlay.
                  highlightColor: Colors.transparent,
                  child:
                  Container(
                    margin: EdgeInsets.only(bottom: 6.0),
                    child: Image.network(_item.imageUrl, width: 65.0, fit: BoxFit.contain,)
                  ),
                  
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
