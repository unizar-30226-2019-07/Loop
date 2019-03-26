import 'package:flutter/material.dart';
import 'package:selit/class/item_class.dart';
import 'package:selit/util/item_repository.dart';
import 'package:selit/widgets/items/item_tile.dart';
import 'dart:async';

/// Lista con varios productos (por ahora muestra fotos de cervezas
/// por motivos de test) en vista de 1 columna
class ItemList extends StatefulWidget {
  
  @override
  _ItemList createState() => _ItemList();

}

class _ItemList extends State<ItemList> {

  List<ItemClass> _items = <ItemClass>[];

  static const IconData tune = IconData(0xe429, fontFamily: 'MaterialIcons');

  @override
  void initState() {
    super.initState();
    listenForItems();
  }

  void listenForItems() async {
    final Stream<ItemClass> stream = await getItems();
    stream.listen((ItemClass item) =>
      setState(() =>  _items.add(item))
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Container(
        child: Column(
          children: <Widget>[ 
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, index) => ItemTile(_items[index]),
              ),
            ),    
          ],
        )
      ),
    ),  
    
  );

}
