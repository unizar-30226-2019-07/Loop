import 'package:flutter/material.dart';

class Question extends StatefulWidget {
  final List answer;

  Question({@required this.answer});

  @override
  _QuestionState createState() => _QuestionState(answer);
}

class _QuestionState extends State<Question> {
  static final _styleTitle = const TextStyle(
      fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.white);

  static final _styleBody = TextStyle(
      fontSize: 18.0, color: Colors.grey[800], fontWeight: FontWeight.normal);

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List _answer;

  _QuestionState(List _answer) {
    this._answer = _answer;
  }

  Widget _buildQ(BuildContext context) {
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
          child: Text(_answer[0], style: _styleTitle),
        ),
      ),
      Expanded(
        child: Container(
            margin: EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 10,
                      child: Container(
                        margin: EdgeInsets.only(left: 10, top: 10),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 6, top: 10, bottom: 10, right: 20),
                          child: Text(_answer[1],
                              textAlign: TextAlign.justify, style: _styleBody),
                        ),
                      ),
                    )
                  ],
                )
              ],
            )),
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
        child: _buildQ(context),
      ),
    );
  }
}
