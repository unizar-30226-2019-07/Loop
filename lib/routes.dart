import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:selit/screens/loading_screen.dart';
import 'package:selit/screens/principal.dart';
import 'package:selit/screens/users/profile.dart';
import 'package:selit/screens/users/wishes.dart';
import 'package:selit/screens/users/rate_user.dart';
import 'package:selit/screens/users/report_user.dart';
import 'package:selit/screens/users/edit_profile.dart';
import 'package:selit/screens/login/login_page.dart';
import 'package:selit/screens/items/item_list.dart';
import 'package:selit/screens/items/item_details.dart';
import 'package:selit/screens/items/new_item.dart';
import 'package:selit/screens/items/new_item_2.dart';
import 'package:selit/screens/settings/settings.dart';
import 'package:selit/screens/settings/account.dart';

class Routes {
  final routes = <String, dynamic>{
    '/': (settings) => _buildRoute(settings, new LoadingScreen()),
    '/settings': (settings) => _buildRoute(settings, new Settings()),
    '/account': (settings) => _buildRoute(settings, new Account()),
    '/profile': (settings) =>
        _buildRoute(settings, new Profile(userId: settings.arguments)),
    '/edit-profile': (settings) =>
        _buildRoute(settings, new EditProfile(user: settings.arguments)),
    '/whises': (settings) =>
        _buildRoute(settings, new Wishes(user: settings.arguments)),
    '/rate-user': (settings) =>
        _buildRoute(settings, new RateUser(referencedItem: settings.arguments)),
    '/report-user': (settings) =>
        _buildRoute(settings, new ReportUser(otherUser: settings.arguments)),
    '/login-page': (settings) => _buildRoute(settings, new LoginPage()),
    '/items-list': (settings) => _buildRoute(settings, new ItemList()),
    '/item-details': (settings) =>
        _buildRoute(settings, new ItemDetails(item: settings.arguments)),
    '/new-item': (settings) =>
        _buildRoute(settings, new NewItem.args(settings.arguments)),
    '/new-item2': (settings) =>
        _buildRoute(settings, new NewItem2(item: settings.arguments)),
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

  Routes() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
        .then((_) {
      runApp(new MaterialApp(
        title: 'Selit!',
        onGenerateRoute: _getRoute,
        initialRoute: '/',
        theme: ThemeData(
          primaryColor: Color(0xFFC0392B),
          primaryColorLight: Color(0xFFC11328),
          primaryColorDark: Color(0xFF9A0F1F),
          fontFamily: 'Nunito',
        ),
        home: LoadingScreen(),
      ));
    });
  }
}
