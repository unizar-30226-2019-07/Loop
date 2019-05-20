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

    @override
  void initState() {
    _leerIdUsuario();
    super.initState();
    print('Valor after _idUsuario: ' + _idUsuario.toString());
  }

  void _leerIdUsuario() async {
    int idStorage = await Storage.loadUserId();
    setState(() {
      _idUsuario = idStorage;
    });
    print('Valor _idUsuario: ' + _idUsuario.toString());
  }

  // Lista de pantallas (en orden según aparecen en la barra de navegación)
  static List<Widget> screenList = [ItemList(), ChatList(_idUsuario), Profile(userId: _idUsuario), Settings()];

	@override
	Widget build(BuildContext context) {
    BarColor.changeBarColor(
        color: Theme.of(context).primaryColor, whiteForeground: true);
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
            print('Valor al cambiar tab _idUsuario: ' + _idUsuario.toString());
            setState(() {
              _currentPage = position;
            });
          },
        ),     
      ),
    );
	}

}
