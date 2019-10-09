import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/components/custom_drawer.dart';
import 'package:sgcartera_app/pages/solicitud.dart';

class HomePage extends StatefulWidget {
  HomePage({this.onSingIn, this.colorTema});
  final VoidCallback onSingIn;
  final MaterialColor colorTema;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sistema Originación"),
        centerTitle: true,
      ),
      drawer: CustomDrawer(authFirebase: AuthFirebase(),onSingIn: widget.onSingIn, colorTema: widget.colorTema),
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
                      leading: Icon(Icons.person, color: widget.colorTema,size: 40.0,),
                      title: Text("Nueva Solicitud Individual", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Captura de una solicitud de credito individual."),

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
                      title: Text("Nueva Solicitud Grupal", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Captura de una solicitud de credito grupal."),

                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [widget.colorTema[400], Colors.white])
                      ),
                    )
                  ),
                  onTap: (){},
                )
              ],
            )
          ]
        )
      )
    );
  }
}