import 'package:flutter/material.dart';
import 'item.dart';

class ItemTile extends StatelessWidget {
  final Item _item;
  ItemTile(this._item);

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      ListTile(
        title: Text(_item.name),
        subtitle: Text(_item.tagline),
        leading: Container(
          margin: EdgeInsets.only(left: 6.0),
          child: Image.network(_item.image_url, height: 50.0, fit: BoxFit.fill,)
        ),
      ),
      Divider()
    ],
  );
}
