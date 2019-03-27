<p align="center">
  <img width="550" height="400" src="https://i.imgur.com/uskIN8z.gif">
</p>
Repositorio de trabajo para el apartado de Front-End de Aplicaciones Móviles.

## Estructura del proyecto

El proyecto Flutter organiza sus componentes [de la siguiente forma](https://hackernoon.com/scalable-app-structure-in-flutter-dad61a4bc389):
```
assets/
|- fonts/
|- img/
lib/
|- main.dart
|- routes.dart
|- class/
   |- usuario_class.dart
|- screens/
   |- users/
      |- profile.dart
      |- edit_profile.dart
   |- products/
|- util/
   |- api/
      |- api_config.dart
      |- usuario_request.dart
|- widgets/
```
- `lib`
  - `main.dart`: punto de entrada de la aplicación
  - `routes.dart`: importa las vistas de la aplicación y contiene las rutas de la aplicación (por ejemplo, _/profile_ corresponde con la vista de perfil). Además, guarda la información del tema de la aplicación (colores empleados)
  - `class`: contiene los modelos/clases empleados para almacenar y transmitir información en el código (usuario, item, etc.)
  - `screens`: contiene las vistas de la aplicación. Ordenadas en sub-carpetas (_users_, _items_)
  - `util`: contiene funciones útiles comunes a varias vistas de la aplicación. La sub-carpeta `api` contiene todas las funciones necesarias para interactuar con la API.
  - `widgets`: contiene widgets comunes a varias vistas de la aplicación (foto de perfil, item de la lista)