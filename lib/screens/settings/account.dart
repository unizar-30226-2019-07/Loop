import 'package:flutter/material.dart';
import 'package:selit/util/storage.dart';

// Vista temporal con varios botones que llevan a diferentes vistas
// de forma que se pueda acceder a ellas de alguna forma

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  static final _styleTitle = TextStyle(
      fontSize: 22.0, color: Colors.grey[800], fontWeight: FontWeight.bold);

  final TextEditingController _passController = new TextEditingController();

Widget _buildForm() {

  Widget wTitle = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
            margin: EdgeInsets.only(left: 10, top:25),
            child: 
              Padding(
                  padding: EdgeInsets.only(
                    left: 6,
                    top: 15,
                    bottom: 10
                  ),
                  child: Row(children: <Widget>[
                    Row(children: <Widget>[
                      Text('Eliminar cuenta', style: _styleTitle)
                    ]),
                  ]),
                ),
                
            ),
        )
      ],
    );
    Widget wPassword = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
              margin: EdgeInsets.only(left: 30, right: 20, bottom: 20),
              //color: Colors.red, // util para ajustar margenes
              child: Column(
                children: <Widget>[
                  
                  new TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                    ),
                    controller: _passController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                ],
              )),
        )
      ],
    );

    Widget wButton = Row(
      children: <Widget>[
        Expanded(
          flex: 10,
          child: Container(
            margin: EdgeInsets.all(20),
            child:
            
                new Container(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 55),
                    child: new RaisedButton(
                      color: Color(0xffc0392b),
                      child: const Text('Eliminar cuenta',
                          style: TextStyle(color: Colors.white)),
                      onPressed: () async {
                        
                      },
                    )),
            ),
        )
      ],
    );


  

    return SafeArea(
        top: false,
        bottom: false,
        child: new Form(
            key: _formKey,
            autovalidate: true,
            child: new ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                wTitle,
                wPassword,
                wButton

              ],
            )));
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Cuenta'),
        ),
        body: _buildForm());
  }
}
