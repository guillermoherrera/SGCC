import 'package:flutter/material.dart';

class Cartera extends StatefulWidget {
  @override
  _CarteraState createState() => _CarteraState();
}

class _CarteraState extends State<Cartera> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mi Cartera"),
        centerTitle: true,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.blue[100], Colors.white])
              ),
            ),
          ]
        )
      ),
    );
  }
}