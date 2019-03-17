import 'package:flutter/material.dart';
import 'screens/debug_main.dart';
import 'screens/users/profile.dart';
import 'screens/users/edit_profile.dart';

class Routes {
  final routes = <String, dynamic>{
    '/debug-main': (settings) => _buildRoute(settings, new DebugMain()),
    '/profile': (settings) =>
        _buildRoute(settings, new Profile(userId: settings.arguments)),
    '/edit-profile': (settings) =>
        _buildRoute(settings, new EditProfile(user: settings.arguments)),
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

  Routes() {
    runApp(new MaterialApp(
      title: 'Selit! by Allenship',
      onGenerateRoute: _getRoute,
      initialRoute: '/',
      theme: ThemeData(primaryColor: Color(0xFFC0392B)),
      home: new DebugMain(),
    ));
  }
}
