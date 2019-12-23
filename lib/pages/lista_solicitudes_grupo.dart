import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/pages/home.dart';
import 'package:sgcartera_app/pages/solicitud.dart' as SolicitudPage;
import 'package:sgcartera_app/pages/root_page.dart';
import 'package:sgcartera_app/pages/solicitud_editar.dart';
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_catIntegrantes.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Grupo> gruposAbiertos = List();  
  int userType;

  Future<void> getListDocumentos() async{
    status = widget.grupo.status == 0 ? true : false;
    final pref = await SharedPreferences.getInstance();
    String userID = pref.getString("uid");
    userType = pref.getInt('tipoUsuario');
    gruposAbiertos = await ServiceRepositoryGrupos.getAllGrupos(userID);
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
      //onWillPop: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootPage(authFirebase: authFirebase, colorTema: widget.colorTema,))),
      onWillPop: ()=> Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomePage(onSingIn: (){}, colorTema: widget.colorTema,)), (Route<dynamic> route) => false),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
          actions: status ? <Widget>[
            IconButton(icon: Icon(Icons.lock), onPressed: () {
              cerrarGrupo(widget.grupo);
            },),
            IconButton(icon: Icon(Icons.person_add), onPressed: () {
              //cerrarGrupo(widget.grupo);
              Navigator.push(context, MaterialPageRoute(builder: (context) => SolicitudPage.Solicitud(title: "Solicitud Grupal: "+widget.grupo.nombreGrupo, colorTema: widget.colorTema, grupoId: widget.grupo.idGrupo, grupoNombre: widget.grupo.nombreGrupo, actualizaHome: widget.actualizaHome)));
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
              solicitudes.length > 0 ? listaSolicitudes() : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text("Grupo sin solicitudes para mostrar 📦☹️", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema))))//Center(child: Text("Sin solicitudes para este Grupo"),) 
            ]
          )
        ),
        bottomNavigationBar: InkWell(
          child:  Container(
              child: ListTile(
                leading: Icon(Icons.group, color: Colors.white,size: 40.0,),
                title: Row(children: <Widget>[Icon(Icons.error, color: status ? Colors.yellow : Colors.green,),Text(" Este grupo esta en status "+(status ? "Abierto" : "Cerrado") )],),
                subtitle: status ? Row(children: <Widget>[Text("Da click en "), Icon(Icons.lock, color: Colors.white,), Text(" para cerrar el grupo")],) : Text(""),
              ),
              color: widget.colorTema
            ),
          
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
                trailing: solicitudes[index].status != 0 && solicitudes[index].status != 6 ? Tooltip(message: "Integrante sincronizado.", child: Icon(Icons.done_all)) : getIcono(solicitudes[index]),
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
              child: Row(children: <Widget>[Icon(Icons.mode_edit, color: status ? Colors.green : Colors.grey,),Text(" Ver/Editar Solicitud")],), value: 1),
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.person_pin, color: status ? Colors.blue : Colors.grey),Text(" Mover a Individual")],), value: 3),
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.group_work, color: status ? Colors.blue : Colors.grey),Text(" Mover a otro Grupo")],), value: 4),
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.delete, color: status ? Colors.red : Colors.grey),Text(" Eliminar Solicitud")],), value: 2),
                      ],
          onSelected: (value){
            if(value == 1){
              if(status) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SolicitudEditar(title: "Solicitud Editar:", colorTema: widget.colorTema, idSolicitud: solicitud.idSolicitud )));
            }
            else if(value == 2){
              if(status) eliminarSolicitud(solicitud);
              //Navigator.push(context, MaterialPageRoute(builder: (context) => ListaSolicitudesGrupo(colorTema: widget.colorTema,title: grupo.nombreGrupo,)));
            }else if(value == 3){
              if(userType == 2){
                showSnackBar("Acción no valida. No puedes mover esta solicitud a Individual.", Colors.red);
              }else{
                if(status) moverAIndividual(solicitud);
              } 
            }else if(value == 4){
              if(status) mostrarActionSheet(context, solicitud);
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
                  Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(solicitud.idGrupo);
                  Grupo grupoAux = new Grupo(idGrupo: grupo.idGrupo, cantidad: grupo.cantidad - 1, importe: grupo.importe - solicitud.importe);
                  await ServiceRepositoryGrupos.updateGrupoImpCant(grupoAux);
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
                Text("\nAl cerrar el grupo no podrá agregar ni eliminar solicitudes y estará listo para sincronizarse.\n\n¿Desea cerrar el grupo "+grupo.nombreGrupo+"?"),
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
                  var result = await RepositoryServiceCatIntegrantes.getAllCatIntegrantes();
                  int cantidad = result[0].cantidad;
                  if(solicitudes.length >= cantidad){
                    await ServiceRepositoryGrupos.updateGrupoStatus(1, null, grupo.idGrupo);
                    for(final solicitud in solicitudes){
                      if(solicitud.idGrupo == grupo.idGrupo) await ServiceRepositorySolicitudes.updateSolicitudStatus(0, solicitud.idSolicitud);
                    }
                    widget.actualizaHome();
                    setState(() {
                    status = false; 
                    });
                  }else{
                    showSnackBar("El grupo no pudo ser cerrado. Debe tener al menos "+cantidad.toString()+" integrantes", Colors.red);
                  }
                }
              )
            ],
      );
    });
  }

  moverAIndividual(Solicitud solicitudAux)async{
    
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text("Mover a individual")),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.yellow, size: 100.0,),
                Text("\n¿Desea mover esta solicitud a Individual?"),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("No"),
                onPressed: (){Navigator.pop(context);}
              ),
              new FlatButton(
                child: const Text("Sí, mover."),
                onPressed: ()async{
                  Navigator.pop(context);
                  Solicitud solicitud = new Solicitud(idSolicitud: solicitudAux.idSolicitud, idGrupo: null, nombreGrupo: null, status: 0, tipoContrato: 1
                  );
                  await ServiceRepositorySolicitudes.updateMoverSolicitud(solicitud);
                  Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(solicitudAux.idGrupo);
                  Grupo grupoAux = new Grupo(idGrupo: grupo.idGrupo, cantidad: grupo.cantidad - 1, importe: grupo.importe - solicitudAux.importe);
                  await ServiceRepositoryGrupos.updateGrupoImpCant(grupoAux);
                  widget.actualizaHome();
                  getListDocumentos();
                }
              )
            ],
      );
    });
  }

  showSnackBar(String texto, MaterialColor color){
    final snackBar = SnackBar(
      content: Text(texto, style: TextStyle(fontWeight: FontWeight.bold),),
      backgroundColor: color[300],
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  mostrarActionSheet(BuildContext context, Solicitud solicitud){
    showCupertinoModalPopup(
      context: context,
      builder: (context){
        return CupertinoActionSheet(
          title: Text("Confirma el grupo"),
          message: Text(gruposAbiertos.length > 0 ? "Selecciona el grupo al que se agregará la solicitud" : "No tienes grupos abiertos"),
          cancelButton: CupertinoActionSheetAction(
            child: Text("Cancelar"),
            onPressed: (){Navigator.of(context).pop();},
          ),
          actions: getGrupos(solicitud),
        );
      }
    );
  }

 List<Widget> getGrupos(Solicitud solicitud){
   List<Widget> listaGrupos = List();
   for(Grupo grupo in gruposAbiertos){
     listaGrupos.add(
       CupertinoActionSheetAction(
        child: Text(grupo.nombreGrupo),
        onPressed: () => moverGrupo(solicitud, grupo),
       )
     );
   }
   return listaGrupos;
 }

  moverGrupo(Solicitud solicitudAux, Grupo group)async{
    if(solicitudAux.idGrupo != group.idGrupo){
      Solicitud solicitud = new Solicitud(idSolicitud: solicitudAux.idSolicitud, idGrupo: group.idGrupo, nombreGrupo: group.nombreGrupo, status: 6, tipoContrato: 2);
      await ServiceRepositorySolicitudes.updateMoverSolicitud(solicitud);
      Grupo grupoAux = new Grupo(idGrupo: group.idGrupo, cantidad: group.cantidad + 1, importe: group.importe + solicitudAux.importe);
      await ServiceRepositoryGrupos.updateGrupoImpCant(grupoAux);
      Grupo grupoviejo = await ServiceRepositoryGrupos.getOneGrupo(solicitudAux.idGrupo);
      Grupo grupoAux2 = new Grupo(idGrupo: solicitudAux.idGrupo, cantidad: grupoviejo.cantidad - 1, importe: grupoviejo.importe - solicitudAux.importe);
      await ServiceRepositoryGrupos.updateGrupoImpCant(grupoAux2);
      widget.actualizaHome();
      getListDocumentos();
    }
    Navigator.of(context).pop();
 }
}