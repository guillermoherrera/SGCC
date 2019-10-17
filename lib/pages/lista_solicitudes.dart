import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/pages/solicitud_editar.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';

class ListaSolicitudes extends StatefulWidget {
  ListaSolicitudes({this.title, this.status, this.colorTema, this.actualizaHome});
  final MaterialColor colorTema;
  final String title;
  final int status;
  final VoidCallback actualizaHome;
  @override
  _ListaSolicitudesState createState() => _ListaSolicitudesState();
}

class _ListaSolicitudesState extends State<ListaSolicitudes> {
  List<Solicitud> solicitudes = List();  
  AuthFirebase authFirebase = new AuthFirebase();
  List<String> grupos = List();
  
  Future<void> getListDocumentos() async{
    String userID = await authFirebase.currrentUser();
    switch (widget.status) {
      case 0:
        solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudes(userID);    
        break;
      default:
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: <Widget>[
          widget.status == 0 ? IconButton(icon: Icon(Icons.cached), color: Colors.white, onPressed: () {},) : Text("")
        ],
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
            solicitudes.length > 0 ? listaSolicitudes() : Center(child: Text("Sin Información"),) 
          ]
        )
      ),
    );
  }

  Widget listaSolicitudes(){     
    return ListView.builder(
      itemCount: solicitudes.length,
      itemBuilder: (context, index){
        if(grupos.contains(solicitudes[index].nombreGrupo)) return Padding(padding: EdgeInsets.all(0),);
        if(solicitudes[index].idGrupo != null) grupos.add(solicitudes[index].nombreGrupo);
        return InkWell(
          child: Card(
            child: Container(

              child: solicitudes[index].idGrupo == null ?
              ListTile(
                leading: Icon(Icons.person, color: widget.colorTema,size: 40.0,),
                title: Text(getNombre(solicitudes[index]), style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(getImporte(solicitudes[index])),
                isThreeLine: true,
                trailing: getIcono(solicitudes[index]),
              ) : 
              ListTile(
                leading: Icon(Icons.group, color: widget.colorTema,size: 40.0,),
                title: Text(solicitudes[index].nombreGrupo, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("El grupo debe estar cerrado para poder sincronizarlo."),
                isThreeLine: true,
                trailing: getIcono2(),
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
                  grupos.clear();
                  widget.actualizaHome();
                  getListDocumentos();
                }
              )
            ],
      );
    });
  }

  Widget getIcono2(){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: 
      <Widget>[
        Icon(Icons.access_time,color: Colors.yellow[700],),
        PopupMenuButton(
          itemBuilder: (_) => <PopupMenuItem<int>>[
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.person_add, color: Colors.green,),Text(" Agregar Solicitud")],), value: 1),
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.list, color: Colors.blue),Text(" Ver Solicitudes")],), value: 2),
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.lock, color: Colors.grey),Text(" Cerrar Grupo")],), value: 3),
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.delete, color: Colors.red),Text(" Eliminar Grupo")],), value: 4),
          ],
          onSelected: (value){
            if(value == 1){
              //Navigator.push(context, MaterialPageRoute(builder: (context) => Solicitud(title: "Solicitud Grupal: "+grupo.nombreGrupo, colorTema: widget.colorTema, grupoId: grupo.idGrupo, grupoNombre: grupo.nombreGrupo,)));
            }
            else if(value == 2){
              //Navigator.push(context, MaterialPageRoute(builder: (context) => ListaSolicitudesGrupo(colorTema: widget.colorTema,title: grupo.nombreGrupo,)));
            }
          }
        )
      ],
    );
  }
}