import 'package:flutter/material.dart';

class MessageReceivedTile extends StatelessWidget {

  final String mensaje;
  final String hora;

  MessageReceivedTile(this.mensaje, this.hora);

  static const double height = 75.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(
            top: 5.0, bottom: 5.0, left: 10.0, right: 100.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    side: BorderSide(color: Colors.grey[200], width: 0.5)),
                child: InkWell(
                  splashColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                  highlightColor: Colors.transparent,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                  margin: const EdgeInsets.only(top: 10.0),
                                  child: new Text(mensaje,
                                      style: new TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold))),
                              new Container(
                                  margin: const EdgeInsets.only(
                                      top: 3.0, bottom: 3.0),
                                  child: new Text(hora,
                                      style: new TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold)))
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
