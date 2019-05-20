import 'package:flutter/material.dart';
import 'package:selit/util/storage.dart';
import 'package:selit/util/bar_color.dart';
import 'package:selit/widgets/fancy_bottom_navigation.dart';
import 'package:selit/screens/items/item_list.dart';
import 'package:selit/screens/settings/settings.dart';
import 'package:selit/screens/users/profile.dart';
import 'package:selit/screens/chat/chat_list.dart';

// Pantalla principal para navegar entre pantallas
// por medio de la barra de navegación inferior.
class Principal extends StatefulWidget {
  @override
  _Principal createState() => _Principal();
}

class _Principal extends State<Principal> {
  // Página actual (al principio es 0 -> home)
  static int _currentPage = 0;
  static int _idUsuario = 0; //Valor 0 usuario interno

  final _styleLoading = TextStyle(color: Colors.white, fontSize: 18.0);

  _Principal() {
    _leerIdUsuario();
  }

  // Lista de pantallas (en orden según aparecen en la barra de navegación)
  List<Widget> screenList = [];

  void _leerIdUsuario() async {
    int idStorage = await Storage.loadUserId();
    setState(() {
      _idUsuario = idStorage;
      _currentPage = 0;
      screenList = [
        ItemList(),
        ChatList(_idUsuario),
        Profile(userId: 0),
        Settings()
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    BarColor.changeBarColor(
        color: Theme.of(context).primaryColor, whiteForeground: true);
    if (screenList.isEmpty) {
      // Pantalla "Cargando..." mientras se lee el ID de usuario
      return Scaffold(
          body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColorLight,
                    Theme.of(context).primaryColorDark,
                  ],
                  stops: [0.0, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(
                      strokeWidth: 5.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                  Container(
                    margin: EdgeInsets.only(top: 25.0),
                    child: Text('Cargando...', style: _styleLoading),
                  ),
                ],
              ))));
    } else {
      // Pantalla principal normal
      return Scaffold(
        body: screenList[_currentPage], // Pantalla en curso
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: SafeArea(
          child: FancyBottomNavigation(
            tabs: [
              // Tabs que aparecen en la barra de navegación inferior
              TabData(iconData: Icons.home, title: "Home"),
              TabData(iconData: Icons.chat, title: "Chats"),
              TabData(iconData: Icons.person, title: "Usuario"),
              TabData(iconData: Icons.settings, title: "Ajustes")
            ],
            // Cambiar la pantalla
            onTabChangedListener: (position) =>
                setState(() => _currentPage = position),
          ),
        ),
      );
    }
  }
}
