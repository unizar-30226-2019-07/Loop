import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:selit/widgets/items/item_tile.dart';
import 'package:selit/util/api/item_request.dart';
import 'package:selit/class/item_class.dart';
import 'dart:async';


class ItemList extends StatefulWidget {
  

  @override
  _ItemList createState() => _ItemList();

}

class _ItemList extends State<ItemList> {

  List<ItemClass> _items = <ItemClass>[];

  List<String> _tags=['hola'];
  IconData _times = FontAwesomeIcons.times;

  static const IconData tune = IconData(0xe429, fontFamily: 'MaterialIcons');

  @override
  void initState() {
    super.initState();
    listenForItems();
  }

  void listenForItems() async {
    final Stream<ItemClass> stream = await ItemRequest.getItems();
    stream.listen((ItemClass item) =>
      setState(() =>  _items.add(item))
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(


    /*
    appBar: AppBar(
      centerTitle: true,
      title: Text('Productos'),
    ),*/
    body: SafeArea(
      child: Container(
        child: Column(
          children: <Widget>[
            /*Row(
              children: <Widget>[
                
              ],
            ),*/
            Padding(
              padding: const EdgeInsets.only(bottom:8.0, top:8.0, right:8.0, left:8.0),
                child: TextField(
                  onSubmitted: (value) {
                    print(value);
                  },
                  /*onChanged: (value) {
                    print(value);
                  },*/
                  //controller: editingController,
                  decoration: InputDecoration(
                    labelText: "Buscar",
                    hintText: "Buscar",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0))
                    ),
                    icon: GestureDetector(
                              onTap: (){
                                print('filter_list was tapped');
                              },
                              child: Icon(
                                tune,
                                size: 30.0,
                                color: Colors.black,
                              ),
                            ),
                  ),
                  
                ),
              ),   
            Container(
              margin: EdgeInsets.symmetric(vertical: 5.0),
              height: 50.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  /*
                  ListTile(
                    leading: Icon(_times),
                    title: Text('etiqueta')
                  ),

                  ListTile(
                    leading: Icon(_times),
                    title: Text('etiqueta 2')
                  ),
                  */
                  Container(
                    width: 160.0,
                    child: ListTile(
                      leading: Icon(_times),
                      title: Text('etiqueta 1 se sale por abajo'),
                    ),
                    
                  ),
                  Container(
                    width: 160.0,
                    color: Colors.blue,
                  ),
                  Container(
                    width: 160.0,
                    color: Colors.green,
                  ),
                  Container(
                    width: 160.0,
                    color: Colors.yellow,
                  ),
                  Container(
                    width: 160.0,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
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