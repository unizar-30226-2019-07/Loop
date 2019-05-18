import 'package:flutter/material.dart';
import 'package:selit/class/usuario_class.dart';
import 'package:selit/class/rating_class.dart';
import 'package:selit/util/api/usuario_request.dart';
import 'package:selit/widgets/profile_picture.dart';
import 'package:selit/widgets/star_rating.dart';
import 'package:selit/util/bar_color.dart';

/// Pantalla para calificar otro usuario, con información sobre el
/// usuario que va a ser calificado, un número de estrellas entre 1 y 5
/// y un comentario adicional sobre la calificación.
/// Con estos campos establecen un formulario a enviar
class RatingList extends StatefulWidget {
  final UsuarioClass user;

  RatingList({@required this.user});
  @override
  State<StatefulWidget> createState() => _RatingListState(user);
}

class _RatingListState extends State<RatingList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  static final _styleTitle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.white);
  static final TextStyle _styleCardDescription = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 15.0); // luego color gris
  static final TextStyle _styleCardTitle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 20.0, color: Colors.black);

  UsuarioClass _user;
  List<RatingClass> ratings = [];

  // Constructor
  _RatingListState(this._user) {
        print('cargando');
    _loadRatings();
  }

  void _loadRatings() async {
    UsuarioRequest.getRatingsFromUser(userId: _user.userId).then((list) {
      list.forEach((item) {
        print('cargado');
        item.usuarioComprador = _user;
      });
      setState(() {
        ratings = list;
      });
    }).catchError((error) {
      print('Error al obtener las calificaciones: $error');
    });
  }

  Widget _buildRatingsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
            margin: EdgeInsets.fromLTRB(20.0, 25.0, 0.0, 10.0),
            child: Text('Calificaciones ', style: _styleTitle)),
        Expanded(
          child: ratings.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                      SizedBox(
                          width: double.infinity,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CircularProgressIndicator(
                                    strokeWidth: 5.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey[600]))
                              ])),
                    ])
              : ListView.builder(
                  itemCount: ratings.length,
                  itemBuilder: (ctx, i) => Container(
                        margin: EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            color: Colors.grey[300],
                            padding: EdgeInsets.all(2.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                  color: Colors.grey[50],
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(right: 10.0),
                                        child: SizedBox.fromSize(
                                            size: Size(100, 100),
                                            child: ProfilePicture(ratings[i]
                                                .usuarioComprador
                                                ?.profileImage)),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                                ratings[i]
                                                        .usuarioComprador
                                                        .nombre +
                                                    ' ' +
                                                    ratings[i]
                                                        .usuarioComprador
                                                        .apellidos,
                                                style: _styleCardTitle,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            StarRating(
                                              starRating:
                                                  ratings[i].numeroEstrellas,
                                              starColor: Colors.yellow[800],
                                              starSize: 30.0,
                                              profileView: false,
                                            ),
                                            Container(
                                              margin:
                                                  EdgeInsets.only(top: 10.0),
                                              child: Text(
                                                  '"${ratings[i].descripcion}"',
                                                  style: _styleCardDescription
                                                      .copyWith(
                                                          color: Colors
                                                              .grey[700])),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ),
                        ),
                      ),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    BarColor.changeBarColor(color: Colors.transparent, whiteForeground: true);
    return Stack(children: <Widget>[
      Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment(0.10, -1.0),
                end: Alignment(-0.10, 1.0),
                stops: [
                  0.5,
                  0.5
                ],
                colors: [
                  Theme.of(context).primaryColor,
                  Colors.grey[100],
                ]),
          ),
        ),
      ),
      Scaffold(
          resizeToAvoidBottomInset: true,
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: _buildRatingsList(),
          )),
    ]);
  }
}
