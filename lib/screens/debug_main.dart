import 'package:flutter/material.dart';
import 'package:selit/screens/users/profile.dart';


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
						],
					),
				),
			),
		);
	}

}
