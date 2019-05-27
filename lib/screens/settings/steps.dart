import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';

class Steps extends StatefulWidget {
  @override
  _StepsState createState() => _StepsState();
}

class _StepsState extends State<Steps> {
  static final _styleTitle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.white);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget _buildImages(BuildContext context) {
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
          child: Text('Primeros pasos', style: _styleTitle),
        ),
      ),
      Expanded(
          child: Container(
              margin: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 30.0),
              child: AspectRatio(
                aspectRatio: 9 / 18,
                child: Carousel(
                  images: [
                    new AssetImage('assets/img/paso1.JPG'),
                    new AssetImage('assets/img/paso2.JPG'),
                    new AssetImage('assets/img/paso3.JPG'),
                    new AssetImage('assets/img/paso4.JPG'),
                    new AssetImage('assets/img/paso5.JPG'),
                  ],
                  dotSize: 4.0,
                  dotSpacing: 15.0,
                  dotColor: Colors.black,
                  indicatorBgPadding: 5.0,
                  dotBgColor: Colors.grey.withOpacity(0),
                  borderRadius: true,
                  autoplay: false,
                ),
              )))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _buildImages(context),
      ),
    );
  }
}
