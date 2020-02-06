import 'package:flutter/material.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:sgcartera_app/pages/grupos.dart';
import 'package:sgcartera_app/pages/solicitud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NuevasSolicitudes extends StatefulWidget {
  NuevasSolicitudes({this.colorTema, this.actualizaHome});
  final Color colorTema;
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
        title: Text("Nuevas Solicitudes", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      body: userType == null ? Container() : userType == 0 ? Center(child: Padding(padding: EdgeInsets.all(50), child:Text("Tu Usuario no esta asignado.  ☹️☹️☹️\n\nPonte en contacto con soporte para mas información.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema)))) : Container(
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
                      leading: Icon(Icons.create_new_folder,color: Colors.white, size: 40.0,),
                      title: Text("\nNUEVAS SOLICITUDES DE CRÉDITO", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white)),
                      subtitle: Text("Crea nuevas solicitudes de crédito.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
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
                    child:  Padding(padding: EdgeInsets.all(5.0), child: Column(children: opciones()),
                  )
                )))
                /*ResponsiveContainer(
                  heightPercent: 30.0,
                  widthPercent: 100.0,
                  child: Container(color: widget.colorTema, child: Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center ,children: <Widget>[Icon(Icons.create_new_folder,color: Colors.white60, size: 150.0), Text("CREA NUEVAS SOLICITUDES DE CREDITO", style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),)]),
                  )),
                ),
                Expanded(child: ListView(
                  children: <Widget>[
                    userType == 2 ? Container() : InkWell(
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
                            colors: [widget.colorTema, Colors.white])
                          ),
                        )
                      ),
                      onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Solicitud(title: "Solicitud Individual", colorTema: widget.colorTema,)));},
                    ),
                    userType == 1 ? Container() : InkWell(
                      child: Card(
                        child: Container(
                          child: ListTile(
                          leading: Icon(Icons.group_add, color: widget.colorTema,size: 40.0,),
                          title: Text("Grupos", style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Captura nuevas solicitudes de Credito Grupal."),
                          trailing: Icon(Icons.arrow_forward_ios),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [widget.colorTema, Colors.white])
                          ),
                        )
                      ),
                      onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Group(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome )));},
                    )
                  ],
                ))*/
              ])
          ]
        )
      )
    );
  }

  List<Widget> opciones(){
    return [
      Expanded(child: Padding(padding: EdgeInsets.fromLTRB(5, 10, 5, 0), child: ListView(
        children: <Widget>[
          userType == 2 ? Container() : InkWell(
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color:widget.colorTema, width:3.0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                  bottomLeft: Radius.circular(50.0),
                  bottomRight: Radius.circular(50.0)
                ),
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 60, 20, 60),
                child: ListTile(
                leading: Icon(Icons.person_add, color: widget.colorTema,size: 80.0,),
                title: Text("Nueva Solicitud Individual", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                subtitle: Text("Captura solicitudes de credito individual."),
                //trailing: Icon(Icons.arrow_forward_ios),
                //isThreeLine: true,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.white, Colors.white]),
                ),
              )
            ),
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Solicitud(title: "Solicitud Individual", colorTema: widget.colorTema,)));},
          ),
          userType == 1 ? Container() : InkWell(
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color:widget.colorTema, width:3.0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  topRight: Radius.circular(50.0),
                  bottomLeft: Radius.circular(50.0),
                  bottomRight: Radius.circular(50.0)
                ),
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 60, 20, 60),
                child: ListTile(
                leading: Icon(Icons.group_add, color: widget.colorTema,size: 80.0,),
                title: Text("Grupal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                subtitle: Text("Solicitudes de Credito Grupal."),
                //trailing: Icon(Icons.arrow_forward_ios),
                //isThreeLine: true,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Colors.white, Colors.white]),
                ),
              )
            ),
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Group(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome )));},
          )
        ],
      )))
    ];
  }
  
}