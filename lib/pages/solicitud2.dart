import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/models/solicitud.dart';

class SolicitudArchivos extends StatefulWidget {
  SolicitudArchivos({this.title, this.datos});
  final String title;
  final SolicitudObj datos;
  @override
  _SolicitudArchivosState createState() => _SolicitudArchivosState();
}

class _SolicitudArchivosState extends State<SolicitudArchivos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            SingleChildScrollView(
              child: Container(
                child: Card(
                  color: Colors.white70,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 8.0,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: formSolicitud(),
                    ),
                  ),
                ),
              ),
            )
          ]
        )
      ),
    );
  }

  List<Widget> formSolicitud(){
    return [
      Container(
        child: Center(
          child: Text("ADJUNTAR ARCHIVOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
      ),
      Divider(),
      datosPrevios(),
      Divider(),
      Column(
        children: buttonWidget(),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text("Paso 2 de 2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      )
    ];
  }

  Widget datosPrevios(){
    return Column(
      children: <Widget>[
        Container(child:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("DATOS DEL CLIENTE:", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ), margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("NOMBRE: "),
            Text(widget.datos.nombre +" "+ widget.datos.nombreSegundo +" "+ widget.datos.apellido +" "+ widget.datos.apellidoSegundo),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("FECHA DE NACIMIENTO: "),
            Text(formatDate(widget.datos.fechaNacimiento, [dd, '/', mm, '/', yyyy])),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("CURP: "),
            Text(widget.datos.curp),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("RFC: "),
            Text(widget.datos.rfc),
          ],
        ),
      ],
    );
  }

  List<Widget> buttonWidget(){
    return [
      styleButton((){}, "GUARDAR")
    ];
  }

  Widget styleButton(VoidCallback onPressed, String text){
    return RaisedButton(
      onPressed: onPressed,
      color: Colors.blue,
      textColor: Colors.white,
      child: Text(text),
    );
  }
}