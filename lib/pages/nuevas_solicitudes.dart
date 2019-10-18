import 'package:flutter/material.dart';
import 'package:sgcartera_app/pages/grupos.dart';
import 'package:sgcartera_app/pages/solicitud.dart';

class NuevasSolicitudes extends StatefulWidget {
  NuevasSolicitudes({this.colorTema, this.actualizaHome});
  final MaterialColor colorTema;
  final VoidCallback actualizaHome;
  @override
  _NuevasSolicitudesState createState() => _NuevasSolicitudesState();
}

class _NuevasSolicitudesState extends State<NuevasSolicitudes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nuevas Solicitudes"),
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
                  colors: [widget.colorTema[100], Colors.white])
                ),
              ),
              ListView(
              children: <Widget>[
                InkWell(
                  child: Card(
                    child: Container(
                      child: ListTile(
                      leading: Icon(Icons.person_add, color: widget.colorTema,size: 40.0,),
                      title: Text("Nueva Solicitud Individual", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Captura solicitudes de credito individual."),

                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [widget.colorTema[400], Colors.white])
                      ),
                    )
                  ),
                  onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Solicitud(title: "Solicitud Individual", colorTema: widget.colorTema,)));},
                ),
                InkWell(
                  child: Card(
                    child: Container(
                      child: ListTile(
                      leading: Icon(Icons.group, color: widget.colorTema,size: 40.0,),
                      title: Text("Grupos", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Captura y revisa tus solicitudes de Credito Grupal."),

                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [widget.colorTema[400], Colors.white])
                      ),
                    )
                  ),
                  onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Group(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome )));},
                )
              ],
            )
          ]
        )
      )
    );
  }
}