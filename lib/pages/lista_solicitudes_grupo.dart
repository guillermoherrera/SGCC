import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/pages/root_page.dart';
import 'package:sgcartera_app/pages/solicitud_editar.dart';
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListaSolicitudesGrupo extends StatefulWidget {
  ListaSolicitudesGrupo({this.title, this.colorTema, this.actualizaHome, this.grupo});
  final MaterialColor colorTema;
  final String title;
  final VoidCallback actualizaHome;
  final Grupo grupo;
  
  @override
  _ListaSolicitudesGrupoState createState() => _ListaSolicitudesGrupoState();
}

class _ListaSolicitudesGrupoState extends State<ListaSolicitudesGrupo> {
  List<Solicitud> solicitudes = List();  
  AuthFirebase authFirebase = new AuthFirebase();
  bool status;

  Future<void> getListDocumentos() async{
    status = widget.grupo.status == 0 ? true : false;
    final pref = await SharedPreferences.getInstance();
    String userID = pref.getString("uid");
    solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudesGrupo(userID, widget.title);   
    setState(() {});
  }

  @override
  void initState() {
    getListDocumentos();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootPage(authFirebase: authFirebase, colorTema: widget.colorTema,))),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          actions: status ? <Widget>[
            IconButton(icon: Icon(Icons.lock), onPressed: () {
              cerrarGrupo(widget.grupo);
            },)
          ] : null,
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
              solicitudes.length > 0 ? listaSolicitudes() : Center(child: Text("Sin solicitudes para este Grupo"),) 
            ]
          )
        ),
        bottomNavigationBar: InkWell(
          child: Card(
            child: Container(
              child: ListTile(
                leading: Icon(Icons.group, color: widget.colorTema,size: 40.0,),
                title: Row(children: <Widget>[Icon(Icons.error, color: status ? Colors.yellow : Colors.green,),Text(" Este grupo esta en status "+(status ? "Abierto" : "Cerrado") )],),
                subtitle: status ? Row(children: <Widget>[Text("Da click en "), Icon(Icons.lock, color: Colors.white,), Text(" para cerrar el grupo")],) : Text(""),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [widget.colorTema[400], Colors.blueGrey[100]])
              ),
            ),
          )
        ),
      )
    );
  }

  Widget listaSolicitudes(){        
    return ListView.builder(
      itemCount: solicitudes.length,
      itemBuilder: (context, index){
        return InkWell(
          child: Card(
            child: Container(
              child: ListTile(
                leading: Icon(Icons.person, color: widget.colorTema,size: 40.0,),
                title: Text(getNombre(solicitudes[index]), style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(getImporte(solicitudes[index])),
                isThreeLine: true,
                trailing: solicitudes[index].status != 0 ? Icon(Icons.verified_user) : getIcono(solicitudes[index]),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [widget.colorTema[400], Colors.white])
              ),
            ),
          )
        );
      },
    );
  }

  String getNombre(Solicitud solicitud){
    String nombre = solicitud.nombrePrimero+" "+solicitud.nombreSegundo+" "+solicitud.apellidoPrimero+" "+solicitud.apellidoSegundo;
    return nombre;
  }

  String getImporte(Solicitud solicitud){
    double importe = solicitud.importe;
    return "TELÉFONO: "+solicitud.telefono+"\nIMPORTE: "+importe.toStringAsFixed(2);
  }

  Widget getIcono(Solicitud solicitud){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: 
      <Widget>[
        Icon(Icons.access_time,color: Colors.yellow[700],),
        PopupMenuButton(
          itemBuilder: (_) => <PopupMenuItem<int>>[
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.mode_edit, color: Colors.green,),Text(" Ver/Editar Solicitud")],), value: 1),
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.delete, color: Colors.red),Text(" Eliminar Solicitud")],), value: 2),
          ],
          onSelected: (value){
            if(value == 1){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SolicitudEditar(title: "Solicitud Editar:", colorTema: widget.colorTema, idSolicitud: solicitud.idSolicitud )));
            }
            else if(value == 2){
              eliminarSolicitud(solicitud);
              //Navigator.push(context, MaterialPageRoute(builder: (context) => ListaSolicitudesGrupo(colorTema: widget.colorTema,title: grupo.nombreGrupo,)));
            }
          }
        )
      ],
    );
  }

  eliminarSolicitud(Solicitud solicitud) async{
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text("Elminar Solicitud")),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.yellow, size: 100.0,),
                Text("\n¿Desea elminar la solicitud a nombre de "+getNombre(solicitud)+"?"),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("No"),
                onPressed: (){Navigator.pop(context);}
              ),
              new FlatButton(
                child: const Text("Sí, eliminar."),
                onPressed: ()async{
                  Navigator.pop(context);
                  await ServiceRepositorySolicitudes.deleteSolicitudCompleta(solicitud);
                  solicitudes.clear();
                  widget.actualizaHome();
                  getListDocumentos();
                }
              )
            ],
      );
    });
  }

  cerrarGrupo(Grupo grupo){
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text("Cerrar Grupo")),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.yellow, size: 100.0,),
                Text("\nAl cerrar el grupo no podrá agregarle mas solicitudes y estará listo para sincronizarse.\n\n¿Desea cerrar el grupo "+grupo.nombreGrupo+"?"),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("No"),
                onPressed: (){Navigator.pop(context);}
              ),
              new FlatButton(
                child: const Text("Sí, cerrar."),
                onPressed: ()async{
                  Navigator.pop(context);
                  await ServiceRepositoryGrupos.updateGrupoStatus(1, grupo.idGrupo);
                  for(final solicitud in solicitudes){
                    if(solicitud.idGrupo == grupo.idGrupo) await ServiceRepositorySolicitudes.updateSolicitudStatus(0, solicitud.idSolicitud);
                  }
                  //grupos.clear();
                  widget.actualizaHome();
                  setState(() {
                   status = false; 
                  });
                  //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ListaSolicitudesGrupo(colorTema: widget.colorTema,title: grupo.nombreGrupo, actualizaHome: widget.actualizaHome, grupo: grupo)));
                  //getListDocumentos();
                }
              )
            ],
      );
    });
  }
}