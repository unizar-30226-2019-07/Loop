import 'package:flutter/material.dart';
import 'package:selit/class/item_class.dart';

/// Tile de objeto para la visualizacion en 2 columnas
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
                  onTap: () => Navigator.of(context).pushNamed('/item-details', arguments: _item),
                  // Generally, material cards use onSurface with 12% opacity for the pressed state.
                  splashColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                  // Generally, material cards do not have a highlight overlay.
                  highlightColor: Colors.transparent,
                  child: Container(
                      margin: EdgeInsets.only(bottom: 6.0),
                      child: Column(children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                ),
                                child: Container(
                                  constraints: new BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                              255),
                                  child: Image.network(
                                    'https://i.imgur.com/rqSvE0T.png', // TODO sustituir por .images
                                    width: 65.0,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ]),
                        Row(children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              top: 20,
                            ),
                            child: Container(
                              constraints: new BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width - 255),
                              child: Text(_item?.title ?? '---',
                              style: new TextStyle(
                                fontSize: 16.0,
                                ),),
                            ),
                          )
                        ]),
                        Row(children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              top: 5,
                            ),
                            child: Container(
                              constraints: new BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width - 260),
                              child: Text(
                                _item?.description ?? '---',
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.justify,
                                maxLines: 7,
                                style: new TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          )
                        ]),
                        Row(children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              top: 20,
                            ),
                            child: Container(
                              child: Text('${_item?.price} ${_item?.currency}',
                              style: new TextStyle(
                                
                                fontSize: 16.0,
                                ),),
                            ),
                          )
                        ]),
                      ])),
                      
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
