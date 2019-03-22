import 'package:flutter/material.dart';
import 'screens/debug_main.dart';
import 'screens/users/profile.dart';
import 'screens/login/login_page.dart';

class Routes {
  final routes = <String, WidgetBuilder>{
    '/debug-main': (BuildContext context) => new DebugMain(),
    '/profile': (BuildContext context) => new Profile(),
    '/login_page': (BuildContext context) => new LoginPage(),
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