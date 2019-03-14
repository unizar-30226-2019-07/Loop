import 'package:flutter/material.dart';
import 'screens/debug_main.dart';
import 'screens/users/profile.dart';

class Routes {
  final routes = <String, WidgetBuilder>{
    '/debug-main': (BuildContext context) => new DebugMain(),
    '/profile': (BuildContext context) => new Profile(),
  };

  Routes() {
    runApp(new MaterialApp(
      title: 'Selit! by Allenship',
      routes: routes,
      theme: ThemeData(
				primaryColor: Color(0xFFC0392B)
			),
      home: new DebugMain(),
    ));
  }
}