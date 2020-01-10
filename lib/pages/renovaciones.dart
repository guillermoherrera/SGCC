import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Renovaciones extends StatefulWidget {
  @override
  _RenovacionesState createState() => _RenovacionesState();
}

class _RenovacionesState extends State<Renovaciones> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Renovaciones"),
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
                colors: [Colors.green[100], Colors.white])
              ),
            ),
          ]
        )
      ),
    );
  }
}