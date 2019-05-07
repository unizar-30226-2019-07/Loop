import 'package:flutter/material.dart';
import 'package:selit/class/chat_class.dart';
import 'package:selit/screens/chat/chat.dart';
import 'package:selit/widgets/profile_picture.dart';

class ChatTileLoading extends StatelessWidget {

  ChatTileLoading();

  static final _styleTitle =
      TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
  static final _styleDescription =
      TextStyle(fontSize: 14.0, color: Colors.grey[700]);
  // Nota: stylePrice usa el color rojo de la aplicación (ver más abajo)
  static final _stylePrice =
      TextStyle(fontSize: 16.0, fontWeight: FontWeight.w900);

  static const double height = 86.0;

  

  @override
  Widget build(BuildContext context) {
    Widget image = Container(
                        padding: const EdgeInsets.all(3.0),
                        child: SizedBox.fromSize(
                          size: Size(71.0, double.infinity),));
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 2.0, right: 2.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: height,
              child: Card(
                // This ensures that the Card's children (including the ink splash) are clipped correctly.
                clipBehavior: Clip.antiAlias,
                elevation: 1.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.grey[300], width: 1.0)),
                child: InkWell(
                  splashColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  highlightColor: Colors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      image,
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 7.0, horizontal: 10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('Cargando...',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: _styleTitle),
                              Expanded(
                                child: Stack(
                                  children: <Widget>[
                                    ClipRect(
                                      child: Text('...',
                                          maxLines: 1,
                                          style: _styleDescription),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment(0, -1.0),
                                            end: Alignment(0, 1.0),
                                            stops: [
                                              0.8,
                                              0.9
                                            ],
                                            colors: [
                                              Colors.white12,
                                              Colors.white,
                                            ]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
