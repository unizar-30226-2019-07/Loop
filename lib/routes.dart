import 'package:flutter/material.dart';
import 'package:selit/screens/debug_main.dart';
import 'package:selit/screens/principal.dart';
import 'package:selit/screens/users/profile.dart';
import 'package:selit/screens/users/edit_profile.dart';
import 'package:selit/screens/login/login_page.dart';
import 'package:selit/screens/items/item_list.dart';
import 'package:selit/screens/items/new_item.dart';
import 'package:selit/screens/items/new_item_2.dart';

class Routes {
  final routes = <String, dynamic>{
    '/debug-main': (settings) => _buildRoute(settings, new DebugMain()),
    '/profile': (settings) =>
        _buildRoute(settings, new Profile(userId: settings.arguments)),
    '/edit-profile': (settings) =>
        _buildRoute(settings, new EditProfile(user: settings.arguments)),
    '/login-page': (settings) => _buildRoute(settings, new LoginPage()),
    '/items-list': (settings) => _buildRoute(settings, new ItemList()),
    '/new-item': (settings) => _buildRoute(settings, new NewItem()),
    '/new-item2': (settings) => _buildRoute(settings, new NewItem2(item: settings.arguments)),
    '/principal': (settings) => _buildRoute(settings, new Principal()),
  };

  Route<dynamic> _getRoute(RouteSettings settings) {
    return routes[settings.name](settings);
  }

  static MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return new MaterialPageRoute(
      settings: settings,
      builder: (ctx) => builder,
    );
  }

  Routes(bool newUser) {
    runApp(new MaterialApp(
      title: 'Selit!',
      onGenerateRoute: _getRoute,
      initialRoute: '/',
      theme: ThemeData(
        primaryColor: Color(0xFFC0392B),
        fontFamily: 'Nunito',
      ),
      home: newUser ? LoginPage() : Principal(),
    ));
  }

}
