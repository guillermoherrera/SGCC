import 'package:flutter/material.dart';

class About extends StatefulWidget {
  About({this.colorTema});
  MaterialColor colorTema;
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Acerca De..."),
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
            Center(child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(),
                  child: Card(
                    color: Colors.white70,
                    margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 20.0,
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        children: contenido(),
                      ),
                    ),
                  )
                )
              ))
          ]
        )
      ),
    );
  }

  List<Widget> contenido(){
    return [
      Image.asset("images/adminconfia.png"),
      Center(child: Text("App Asesores desarrollada por Admnistracion Confiable."),),
      Center(child: Text('''\nAplicación creada para la precaptura de prospectos de clientes, los datos que se registran son los minimos necesarios para realizar la consulta de buró y para la identificación del cliente, dicho proceso se realiza para una posible futura originación.''', textAlign: TextAlign.justify),),
      Container(child: Text("version 1.0."), alignment: Alignment.centerRight,),
    ];
  }
}