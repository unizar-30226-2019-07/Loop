import 'routes.dart';

import 'package:selit/util/seruser.dart'; // TODO evitar usar la variable global storage (juntar con UsuarioRequest?)

Future<void> main() async => new Routes(await storage.read(key: 'token') == null); 