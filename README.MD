<p align="center">
  <img width="550" height="400" src="https://i.imgur.com/uskIN8z.gif">
</p>
Repositorio de trabajo para el apartado de Front-End de Aplicaciones Móviles.

## Estructura del proyecto

El proyecto Flutter organiza sus componentes [de la siguiente forma](https://hackernoon.com/scalable-app-structure-in-flutter-dad61a4bc389):
```
lib/
|- main.dart
|- routes.dart
|- screens/
   |- users/
      |- profile.dart
      |- login.dart
   |- products/
|- util/
|- widgets/
```
- `main.dart`: punto de entrada de la aplicación
- `routes.dart`: importa las vistas de la aplicación y contiene las rutas de la aplicación (por ejemplo, _/profile_ corresponde con la vista de perfil)
- `screens`: contiene las vistas de la aplicación. Pueden ir ordenadas en sub-carpetas (_users_, _products_) o no
- `util`: contiene funciones útiles comunes a varias vistas de la aplicación
- `widgets`: contiene widgets comunes a varias vistas de la aplicación