import 'package:flutter/material.dart';

class RenovacionesDetalle extends StatefulWidget {
  RenovacionesDetalle({this.colorTema, this.title});
  final MaterialColor colorTema;
  final String title;
  @override
  _RenovacionesDetalleState createState() => _RenovacionesDetalleState();
}

class _RenovacionesDetalleState extends State<RenovacionesDetalle> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: ()async{
          await Future.delayed(Duration(seconds:1));
        },
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