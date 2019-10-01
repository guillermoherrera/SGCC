import 'package:flutter/material.dart';

class MisSolicitudes extends StatefulWidget {
  @override
  _MisSolicitudesState createState() => _MisSolicitudesState();
}

class _MisSolicitudesState extends State<MisSolicitudes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Solicitudes"),
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