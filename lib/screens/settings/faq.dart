import 'package:flutter/material.dart';

class FAQ extends StatefulWidget {
  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  static final _styleTitle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.white);

  static final _styleSection = TextStyle(
      fontSize: 22.0, color: Colors.grey[800], fontWeight: FontWeight.bold);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  //Compras
  final String consejos =
      "Si al chatear con la persona no te inspira confianza, busca otro vendedor. Fíjate en sus valoraciones, si las fotos son suyas, etc. En caso de que detectes algo raro, ayúdanos y repórtalo a través de la app.\n\n" +
          "Te recomendamos hacer las transacciones en persona.\n\n" +
          "Evita la transferencia bancaria o cualquier método de pago que no permita verificar el producto antes de comprarlo\n\n" +
          "No te fíes de productos con precios ridículamente bajos o con fotos de catálogo. En Selit! hay gangas, si, ¡pero todo tiene un límite!\n\n" +
          "Las ofertas de compradores extranjeros que ofrecen más dinero de lo normal por el producto y se ofrecen a asumir los gastos de envío acostumbran a ser fraudes. Si detectas este tipo de oferta, repórtala a través de la app y no envíes el producto hasta que no te confirmemos que se trata de un comprador fiable.\n\n" +
          "Selit! nunca te enviará mensajes con links para poder ver tus mensajes o posicionar tus anuncios gratuitamente. Si detectas este tipo de actividad, denúnciala para que podamos tomar las acciones necesarias.\n\n";

  final String comprar =
      "Selit! es una aplicación que te permite comprar y vender productos cerca de ti. Los productos pueden ordenarse según su ubicación, por lo que puedes ver primero aquellos que estén más próximos a tu dirección.\n\n" +
          "Puedes además utilizar nuestros filtros de búsqueda, que encontrarás en la parte superior izquierda de la pantalla principal. Con los filtros puedes buscar en todo wallapop o escoger una categoría concreta.\n\n" +
          "Una vez encuentres el producto que te interesa, lo único que tienes que hacer es pulsar el botón \"Chat\" y entablar una conversación con el vendedor.\n\n" +
          "Una vez cerrado el trato, tendréis que acordar entre vosotros las condiciones de la transacción.\n\n";

  final String pujar = "Selit! te permite pujar por aquellas subastas que estén activas. Para ello, solo tienes que pulsar el botón que se encuentra en la parte inferior derecha del detalle de una subasta e introducir la cantidad deseada.\n\n"+
  "Además, puedes consultar información de la subasta como la fecha ímite, precio de salida o la última puja.\n\n"+
  "Cuando una subasta termine, aparecerá un indicador en el detalle de esta indicando si ha sido ganada por ti, perdida, o está cerrada (en caso de que sea tu propia subasta o no haya pujas). \n\n";

  final String deseados =
      "Para marcar un producto como deseado simplemente pulsa el icono del corazón que encontrarás entrando en el detalle del producto.\n\n" +
          "El listado de productos favoritos lo encontrarás en tu área personal, en el botón flotante de la parte inferior.\n\n" +
          "Si quieres eliminar un deseado de la lista, simplemente pulsa de nuevo el icono en forma de corazón y el artículo desaparecerá del listado.\n\n";

  //Ventas
  final String subir =
      "Para subir un producto a tu perfil simplemente pulsa el símbolo +  que encontrarás al pulsar el botón flotante de la parte inferior de tu perfil.\n\n" +
          "Una vez dentro, deberás escribir un título y una descripción del producto. Selecciona también una categoría y sube fotos del producto desde la galería del terminal (hasta un máximo de 5 en cualquier anuncio). Recuerda que no está permitido utilizar fotos de terceros o extraídas de Internet.\n\n" +
          "Nuestra recomendación es que las fotografías estén tomadas con luz natural y muestren bien los detalles del producto a vender (puedes hacer una foto principal y utilizar las otras para enseñar diferentes vistas o detalles). Un buen título y descripción también ayudan a vender más rápido.\n\n" +
          "Después deberás seleccionar si estableces un precio fijo o quieres crear una subasta. En caso de que tu producto tenga un precio fijo, escribe el precio y la divisa. En caso de que desees crear una subasta, establece el precio de salida, la divisa y la fecha límite.\n\n";

  final String vendido =
      "Para marcar un producto como vendido, simplemente entra en el detalle del mismo a través de tu perfil y pulsa el botón “Marcar como vendido” que encontrarás en la parte superior.\n\n" +
          "Una vez marques el producto como vendido no será posible volver a publicarlo, asegúrate de que realmente está vendido antes de cambiar su estado.\n\n" +
          "Encontrarás el listado de tus productos vendidos en tu área personal.\n\n" +
          "En el caso de las subastas, una vez pase la fecha límite establecida, se marcará la subasta como cerrada de forma automática.\n\n";

  final String modificar =
      "Para modificar un anuncio, entra en el detalle del mismo desde tu perfil y pulsa el botón “Editar producto”.\n\n" +
          "Para eliminar un anuncio, entra en el detalle del mismo desde tu perfil y pulsa el botón “Eliminar producto”. Ten en cuenta que si eliminas un anuncio, no podrás recuperarlo.\n\n";

  //Cuenta
  final String ubicacion =
      "Es imprescindible establecer una ubicación en tu perfil para vender en Selit!. Por ello, cuando crees tu cuenta, necesitarás aceptar los permisos de localización. La aplicación vinculará tu perfil a la zona indicada y los usuarios cercanos verán tus productos a la venta.\n\n" +
          "Desde el área personal puedes modificar la ubicación que se asocia a tu perfil. Accede a la edición de tu perfil y en Mi ubicación selecciona en el mapa la ubicación deseada. También puedes editar tu foto de perfil, nombre de usuario, fecha de nacimiento, contraseña…en definitiva, prácticamente todo lo que esté relacionado con tu cuenta registrada en Selit!.\n\n";

  final String editar =
      "Para editar la información de tu perfil simplemente pulsa “Editar perfil” que encontrarás en la parte superior derecha de tu área personal.\n\n";

  final String sesion =
      "Para cerrar sesión en la aplicación, deberás dirigirte a la pantalla de ajustes y pulsar el botón “Cerrar sesión” de la parte inferior.\n\n";

  final String valoraciones =
      "Si eres comprador, cuando realices una compra, podrás valorar la experiencia de 0 a 5 estrellas y dejar un comentario (esto último no es obligatorio, pero recomendable).\n\n ";

  final String eliminar =
      "Si ya te lo has pensado bien y quieres eliminar tu cuenta en Selit!, encontrarás la opción en la sección Cuenta de la pantalla de ajustes. Una vez dentro, deberás escribir tu contraseña actual para poder eliminarla.\n\n";

  //Problemas
  final String reportar =
      "Si quieres denunciar el comportamiento de otro usuario de Selit!, entra en el perfil de ese usuario y pulsa el botón “Reportar usuario”.\n\n" +
          "Verás que la aplicación te da opción a seleccionar entre varios motivos de denuncia. Intenta escoger el que más se ajuste a lo sucedido y si no encuentras la opción, selecciona \"Otros\" y explícanos qué ha pasado para que te podamos ayudar.\n\n";

  final String tecnicos =
      "¿Ha surgido un problema mientras utilizabas Selit!? Escríbenos a través del formulario de contacto. Cuantos más detalles nos des sobre el problema, más fácil nos será ayudarte :)\n\n";

  Widget _buildFAQ(BuildContext context) {
    return Column(children: [
      SizedBox.fromSize(
        size: Size(double.infinity, 90.0),
        child: Container(
          padding: EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 30.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment(0.007, -1.0),
                end: Alignment(-0.007, 1.0),
                stops: [
                  0.8,
                  0.8
                ],
                colors: [
                  Theme.of(context).primaryColor,
                  Colors.grey[100],
                ]),
          ),
          child: Text('FAQ', style: _styleTitle),
        ),
      ),
      Expanded(
        child: Container(
          margin: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
          child: ListView(children: <Widget>[
            //COMPRAS
            Container(
              margin: EdgeInsets.only(left: 10, top: 3),
              child: Padding(
                padding: EdgeInsets.only(left: 0, bottom: 15),
                child: Row(children: <Widget>[
                  Row(children: <Widget>[
                    Text('Compras', style: _styleSection)
                  ]),
                ]),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Consejos de seguridad"),
                          onTap: () {
                            Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Consejos de seguridad", consejos]);
                          }))),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Comprar"),
                          onTap: () {
                           Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Comprar",comprar]);
                          }))),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Pujar"),
                          onTap: () {
                           Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Pujar",pujar]);
                          }))),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Lista de deseados"),
                          onTap: () {
                            Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Lista de deseados",deseados]);
                          }))),
            ),

            //VENTAS
            Container(
              margin: EdgeInsets.only(left: 10, top: 20),
              child: Padding(
                padding: EdgeInsets.only(left: 0, bottom: 15),
                child: Row(children: <Widget>[
                  Row(children: <Widget>[Text('Ventas', style: _styleSection)]),
                ]),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Subir un producto"),
                          onTap: () {
                            Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Subir un producto",subir]);
                          }))),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Marcar producto como vendido"),
                          onTap: () {
                            Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Marcar producto como vendido",vendido]);
                          }))),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Modificar y eliminar producto"),
                          onTap: () {
                            Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Modificar y eliminar producto",modificar]);
                          }))),
            ),
            

            //CUENTA
            Container(
              margin: EdgeInsets.only(left: 10, top: 20),
              child: Padding(
                padding: EdgeInsets.only(left: 0, bottom: 15),
                child: Row(children: <Widget>[
                  Row(children: <Widget>[
                    Text('Mi cuenta', style: _styleSection)
                  ]),
                ]),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Establecer ubicación"),
                          onTap: () {
                            Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Establecer ubicación",ubicacion]);
                          }))),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Editar perfil"),
                          onTap: () {
                            Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Editar perfil",editar]);
                          }))),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Cerrar sesión"),
                          onTap: () {
                            Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Cerrar sesión",sesion]);
                          }))),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Valoraciones"),
                          onTap: () {
                            Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Valoraciones",valoraciones]);
                          }))),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Eliminar mi cuenta"),
                          onTap: () {
                           Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Eliminar mi cuenta",eliminar]);
                          }))),
            ),

            //PROBELMAS
            Container(
              margin: EdgeInsets.only(left: 10, top: 20),
              child: Padding(
                padding: EdgeInsets.only(left: 0, bottom: 15),
                child: Row(children: <Widget>[
                  Row(children: <Widget>[
                    Text('Problemas', style: _styleSection)
                  ]),
                ]),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Reportar un usuario"),
                          onTap: () {
                            Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Reportar un usuario",reportar]);
                          }))),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 15,
                right: 10,
                bottom: 10,
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Container(
                      color: Colors.grey[300],
                      padding: EdgeInsets.only(left: 10),
                      child: ListTile(
                          title: Text("Problemas técnicos"),
                          onTap: () {
                            Navigator.of(context).pushNamed('/question', arguments:  <dynamic>["Problemas técnicos",tecnicos]);
                          }))),
            ),
          ]),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _buildFAQ(context),
      ),
    );
  }
}
