import 'package:flutter/material.dart';
import 'screens/debug_main.dart';
import 'screens/users/profile.dart';
import 'screens/login/login_page.dart';
import 'screens/items/items_list.dart';

class Routes {
  final routes = <String, WidgetBuilder>{
    '/debug-main': (BuildContext context) => new DebugMain(),
    '/profile': (BuildContext context) => new Profile(),
    '/login_page': (BuildContext context) => new LoginPage(),
    '/items_list': (BuildContext context) => new ItemList(),
  };

  Routes() {
    runApp(new MaterialApp(
      title: 'Selit!',
      routes: routes,
      theme: ThemeData(
				primaryColor: Color(0xFFC0392B)
			),
      home: new DebugMain(),
    ));
  }
}