import 'package:flutter/material.dart';
import 'package:selit/class/item_class.dart';

/// Tile de objeto para la visualizacion en 2 columnas
class ItemTileVertical extends StatelessWidget {
  final ItemClass _item;
  ItemTileVertical(this._item);

  static final _styleTitle =
      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
  static final _styleDescription =
      TextStyle(fontSize: 14.0, color: Colors.grey[700]);
  // Nota: stylePrice usa el color rojo de la aplicación (ver más abajo)
  static final _stylePrice =
      TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900);

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
                elevation: 2.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.grey[300], width: 1.0)),
                child: InkWell(
                  onTap: () => Navigator.of(context).pushNamed('/item-details', arguments: _item),
                  splashColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      // Imagen superior: máximo de 200 píxeles
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          constraints: BoxConstraints(maxHeight: 200.0),
                          child: Image.network(
                            'https://images.pexels.com/photos/845405/pexels-photo-845405.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260', // TODO sustituir por .images
                            fit: BoxFit.cover,
                            color: Colors.white12, // filtro para blanquear
                            colorBlendMode: BlendMode.srcOver,
                          ),
                        ),
                      ),
                      // Borde entre la imagen y el resto
                      SizedBox.fromSize(
                        size: Size(double.infinity, 1.0),
                        child: Container(color: Colors.grey[300]),
                      ),
                      // Título, descripción y precio
                      Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(_item?.title ?? '---',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: _styleTitle),
                              Text(
                                _item?.description ?? '---',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 6,
                                style: _styleDescription
                              ),
                              SizedBox.fromSize(
                                size: Size(double.infinity, 30.0),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text('${_item?.price} ${_item?.currency}',
                                    textAlign: TextAlign.end,
                                    style: _stylePrice.copyWith(
                                        color:
                                            Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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
