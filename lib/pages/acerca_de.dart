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
                      title: Text("\n", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white)),
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
                      padding: EdgeInsets.all(5.0),
                      child: Column(children: contenido()), 
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
      Image.asset("images/adminconfia.png"),
      Container(child:
        Center(child: Text("App Asesores desarrollada por Admnistracion Confiable.", style: TextStyle(fontWeight: FontWeight.bold),),),
        padding: EdgeInsets.all(10),
        color: Color(0xfff2f2f2),
      ),
      Container(
        child: Center(child:
          Text('''\nAplicación creada para la precaptura de prospectos de clientes, los datos que se registran son los minimos necesarios para realizar la consulta de buró y para la identificación del cliente, dicho proceso se realiza para una posible futura originación.''', textAlign: TextAlign.justify)
        ),
        padding: EdgeInsets.all(10),
        color: Color(0xfff2f2f2),
      ),
      Container(child:
        Text("version 1.0."),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(10),
        color: Color(0xfff2f2f2),
      ),
    ];
  }
}