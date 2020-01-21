import 'package:flutter/material.dart';

class CarteraDetalle extends StatefulWidget {
  CarteraDetalle({this.colorTema, this.title});
  final MaterialColor colorTema;
  final String title;
  @override
  _CarteraDetalleState createState() => _CarteraDetalleState();
}

class _CarteraDetalleState extends State<CarteraDetalle> {
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