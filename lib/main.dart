import 'routes.dart';

import 'package:selit/util/api/usuario_request.dart'; // TODO evitar usar la variable global storage (juntar con UsuarioRequest?)

Future<void> main() async => new Routes(await legit().timeout(const Duration(seconds: 5))); 