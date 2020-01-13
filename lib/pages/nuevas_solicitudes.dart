import 'package:flutter/material.dart';
import 'package:sgcartera_app/pages/grupos.dart';
import 'package:sgcartera_app/pages/solicitud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NuevasSolicitudes extends StatefulWidget {
  NuevasSolicitudes({this.colorTema, this.actualizaHome});
  final MaterialColor colorTema;
  final VoidCallback actualizaHome;
  @override
  _NuevasSolicitudesState createState() => _NuevasSolicitudesState();
}

class _NuevasSolicitudesState extends State<NuevasSolicitudes> {
  int userType;

  Future<void> getInfo() async{
    final pref = await SharedPreferences.getInstance();
    userType = pref.getInt('tipoUsuario');
    setState(() {
      
    });
  }

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nuevas Solicitudes"),
        centerTitle: true,
      ),
      body: userType == null ? Container() : userType == 0 ? Center(child: Padding(padding: EdgeInsets.all(50), child:Text("Tu Usuario no esta asignado.  ☹️☹️☹️\n\nPonte en contacto con soporte para mas información.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema)))) : Container(
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
                userType == 2 ? Text("") : InkWell(
                  child: Card(
                    child: Container(
                      child: ListTile(
                      leading: Icon(Icons.person_add, color: widget.colorTema,size: 40.0,),
                      title: Text("Nueva Solicitud Individual", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Captura solicitudes de credito individual."),
                      trailing: Icon(Icons.arrow_forward_ios),
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
                userType == 1 ? Text("") : InkWell(
                  child: Card(
                    child: Container(
                      child: ListTile(
                      leading: Icon(Icons.group_add, color: widget.colorTema,size: 40.0,),
                      title: Text("Grupos", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Captura y revisa tus solicitudes de Credito Grupal."),
                      trailing: Icon(Icons.arrow_forward_ios),
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