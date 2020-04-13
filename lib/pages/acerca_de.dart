import 'package:flutter/material.dart';

class About extends StatefulWidget {
  About({this.colorTema});
  Color colorTema;
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Acerca De...", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [widget.colorTema, widget.colorTema])
              ),
            ),
            Column(children: <Widget>[
                InkWell(
                  child: Card(
                    elevation: 0.0,
                    child: Container(
                      child: ListTile(
                      //leading: Icon(Icons.group,color: Colors.white, size: 40.0,),
                      title: Text("", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white)),
                      subtitle: Center(child: Icon(Icons.info,color: Colors.white, size: 40.0,)),
                      //trailing: Text(""),
                      isThreeLine: true,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [widget.colorTema, widget.colorTema])
                      ),
                    )
                  ),
                  onTap: (){},
                ),
                Expanded(child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
                    ),
                    child:  Padding(
                      padding: EdgeInsets.all(13.0),
                      child: SingleChildScrollView(child: Column(children: contenido())), 
                    ),
                  )
                )),
              ]
            ),  
          ]
        )
      ),
    );
  }

  List<Widget> contenido(){
    return [
      //Image.asset("images/adminconfia.png"),
      Container(child:
        Image.asset("images/source_.png"),
        padding: EdgeInsets.all(10),
      ),
      Padding(padding: EdgeInsets.all(20), child:Text("Información acerca de esta app.", style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 35))),
      Padding(padding: EdgeInsets.only(top:20, left:20, right:20, bottom:5), child:Text("Aplicación creada para funcionar como herramienta de trabajo para los asesores de créditos grupales, sus principales funciones son las de facilitar y validar la captura de solicitudes para agilizar el proceso de originación y mejorar la calidad del servicio ofrecido. Algunas de las características principales que se pueden encontrar en esta app son:", style: TextStyle(fontSize: 15))),
      /*Container(child:
        Center(child: Text("App Asesores desarrollada por Admnistracion Confiable.", style: TextStyle(fontWeight: FontWeight.bold),),),
        padding: EdgeInsets.all(10),
        //color: Color(0xfff2f2f2),
      ),*/
      Container(
        child: Center(child:
          Text(/*"Caracteristicas y funciones: \n\n*/"° Captura de nuevas Solicitudes Grupales.\n° Creación de grupos.\n° Captura de integrantes.\n° Seguimiento a solicitudes.\n° Revisión de cartera activa.\n° Consulta de contratos proximos a terminar.\n° Solicitud de renovaciones.\n° ConfiaShop.",
          textAlign: TextAlign.justify,
          style: TextStyle(fontSize: 15))
        ),
        padding: EdgeInsets.all(0),
        //color: Color(0xfff2f2f2),
      ),
      Container(child:
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Image.asset("images/adminconfia.png", width: 100,),
          Tooltip(message: "App desarrollada por el\n Ing. Guillermo Herrera" , child: Text("version 1.0"), waitDuration: Duration(seconds: 10))
        ]),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(10),
        color: Color(0xfff2f2f2),
      ),
    ];
  }
}