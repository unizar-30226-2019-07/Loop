import 'package:flutter/material.dart';
import 'package:selit/class/item_class.dart';

/// Tile de objeto para la visualizacion en 1 columna
class ItemTile extends StatelessWidget {
  final ItemClass _item;
  ItemTile(this._item);

  static const double height = 129.0;

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
              height: height,
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
                    child: ListTile(
                      title: Text(_item.name),
                      trailing: Text(_item.price),
                      subtitle: Text(_item.description),
                      leading: Container(
                        margin: EdgeInsets.only(left: 6.0, bottom: 15.0),
                        child: Image.network(_item.image_url, width: 65.0, fit: BoxFit.contain,)
                      ),
                    ),
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
