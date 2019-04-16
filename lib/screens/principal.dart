import 'package:flutter/material.dart';
import 'package:selit/widgets/fancy_bottom_navigation.dart';
import 'package:selit/screens/items/item_list.dart';
import 'package:selit/screens/login/login_page.dart';
import 'package:selit/screens/settings/settings.dart';
import 'package:selit/screens/users/profile.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

// Pantalla principal para navegar entre pantallas
// por medio de la barra de navegación inferior.
class Principal extends StatefulWidget {

  @override
  _Principal createState() => _Principal();
}


class _Principal extends State<Principal> {

  // Página actual (al principio es 0 -> home)
  static int _currentPage = 0;
  static int _userId = 0; //Valor 0 usuario interno

  // Lista de pantallas (en orden según aparecen en la barra de navegación)
  List<Widget> screenList = [ItemList(), LoginPage(), Profile(userId: _userId), Settings()];

	@override
	Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
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
          onTabChangedListener: (position) {
            setState(() {
              _currentPage = position;
            });
          },
        ),     
      ),
    );
	}

}
