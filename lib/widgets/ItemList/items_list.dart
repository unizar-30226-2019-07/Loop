import 'package:flutter/material.dart';
import 'item_tile.dart';
import 'item_repository.dart';
import 'item.dart';
import 'dart:async';


class ItemList extends StatefulWidget {
  
  @override
  _ItemList createState() => _ItemList();

}

class _ItemList extends State<ItemList> {

  List<Item> _items = <Item>[];

  static const IconData tune = IconData(0xe429, fontFamily: 'MaterialIcons');

  @override
  void initState() {
    super.initState();
    listenForItems();
  }

  void listenForItems() async {
    final Stream<Item> stream = await getItems();
    stream.listen((Item item) =>
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
