import 'package:flutter/material.dart';
import 'package:selit/util/seruser.dart';


// Vista temporal con varios botones que llevan a diferentes vistas
// de forma que se pueda acceder a ellas de alguna forma
class DebugMain extends StatelessWidget {

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('Debug Menu'),
			),
			body: Container(
				margin: EdgeInsets.all(30),
				child: Center(
					child: Column(
						children: <Widget>[
							RaisedButton(
								child: const Text('Perfil'),
								onPressed: () {
                  // Mostrar el perfil del usuario 1
									Navigator.of(context).pushNamed('/profile',
                  arguments: 1);
								},
							),
              RaisedButton(
								child: const Text('Login'),
								onPressed: () {
									Navigator.of(context).pushNamed('/login-page');
								},
                
							),
              RaisedButton(
								child: const Text('Items'),
								onPressed: () {
									Navigator.of(context).pushNamed('/items-list');
								},
                
							),
              RaisedButton(
								child: const Text('Pr'),
								onPressed: () {
									Navigator.of(context).pushNamed('/hola-hola');
								},
                
							),
						RaisedButton(
								child: const Text('Sign out'),
								onPressed: () {
									storage.delete(key: 'token');
                  print("Sesión cerrada");

								},
            ),
            ],
					),
				),
			),
		);
	}

}
