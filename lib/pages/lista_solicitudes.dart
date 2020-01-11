import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/models/direccion.dart';
import 'package:sgcartera_app/models/documento.dart';
import 'package:sgcartera_app/models/grupo.dart';
import 'package:sgcartera_app/models/persona.dart';
import 'package:sgcartera_app/models/solicitud.dart';
import 'package:sgcartera_app/pages/cambio_documento.dart';
import 'package:sgcartera_app/pages/solicitud_editar.dart';
import 'package:sgcartera_app/sqlite_files/models/documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';
import 'package:sgcartera_app/pages/solicitud.dart' as SolicitudPage;
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart'; 
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path/path.dart' as path;

import 'lista_solicitudes_grupo.dart';

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
  List<Grupo> gruposGuardados = List(); 
  List<Grupo> gruposAbiertos = List();  
  AuthFirebase authFirebase = new AuthFirebase();
  List<String> grupos = List();
  Firestore _firestore = Firestore.instance;
  FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  String mensaje = "Cargando ...🕔";
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();

  bool downloading = false;
  var progressString = "";
  
  Future<void> getListDocumentos() async{
    final pref = await SharedPreferences.getInstance();
    String userID = pref.getString("uid");
    switch (widget.status) {
      case 0:
        gruposGuardados = await ServiceRepositoryGrupos.getAllGruposEspera(userID);
        gruposAbiertos = await ServiceRepositoryGrupos.getAllGrupos(userID);
        solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudes(userID);  
        mensaje = "Sin solicitudes en espera para mostrar 📦☹️";
        break;
      case 1:
        mensaje = "Sin solicitudes por autorizar para mostrar 📦☹️";
        await getSolcitudesespera(userID,1);
        await getSolcitudesespera(userID,6);
        await getSolcitudesespera(userID,7);
        await getSolcitudesespera(userID,8);
        await getSolcitudesespera(userID,9);
        await getSolcitudesespera(userID,10);
        break;
      case 2:
        mensaje = "Sin Solicitudes con peticiones de cambio de documentos para mostrar 📦☹️";
        solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudesCambio(userID);
        break;
      case 3:
        mensaje = "Sin solicitudes Aprobadas para mostrar 📦☹️";
        await getSolcitudesespera(userID,2);
        break;
      case 4:
        mensaje = "Sin solicitudes Denegadas para mostrar 📦☹️";
        await getSolcitudesespera(userID,3);
        break;
      case 5:
        gruposGuardados = await ServiceRepositoryGrupos.getAllGruposSync(userID);
        //gruposAbiertos = await ServiceRepositoryGrupos.getAllGrupos(userID);
        solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudesSync(userID);  
        mensaje = "Sin historial para mostrar 📦☹️";
        break;
      default:
        mensaje = "Error en la busqueda, vuelve a intentarlo 📦☹️";
        break;
    }
    try{
      setState(() {});
    }catch(e){
      print("*** Error lista");
    }
  }

  getSolcitudesespera(userID, status) async{
    try{
      Query q;
      if(status == 2){
        q = _firestore.collection("Solicitudes").where('dictamen', isEqualTo: true).where('userID', isEqualTo:userID);
      }else if(status == 3){
        q = _firestore.collection("Solicitudes").where('dictamen', isEqualTo: false).where('userID', isEqualTo:userID);
      }else{
        q = _firestore.collection("Solicitudes").where('status', isEqualTo: status).where('userID', isEqualTo:userID);
      }
      QuerySnapshot querySnapshot = await q.getDocuments().timeout(Duration(seconds: 10));
      if(status == 2 || status == 3) solicitudes.clear();
      for(DocumentSnapshot dato in querySnapshot.documents){
        Solicitud solicitud = new Solicitud(
          apellidoPrimero: dato.data['persona']['apellido'],
          apellidoSegundo: dato.data['persona']['apellidoSegundo'],
          curp: dato.data['persona']['curp'],
          fechaNacimiento: dato.data['persona']['fechaNacimiento'].millisecondsSinceEpoch,
          //idGrupo: dato.data['grupoId'],
          grupoID: dato.data['grupoID'],
          idSolicitud: null,
          importe: dato.data['importe'],
          nombrePrimero: dato.data['persona']['nombre'],
          nombreSegundo: dato.data['persona']['nombreSegundo'],
          rfc: dato.data['persona']['rfc'],
          telefono: dato.data['persona']['telefono'],
          nombreGrupo: dato.data['grupoNombre'],
          userID: dato.data['userID'],
          status: dato.data['status'],
          tipoContrato: dato.data['tipoContrato'],
          documentID: dato.documentID
        );
        solicitudes.add(solicitud);
      }

      Query q2 = _firestore.collection("Grupos").where('status', isEqualTo: 2).where('userID', isEqualTo:userID);
      QuerySnapshot querySnapshot2 = await q2.getDocuments().timeout(Duration(seconds: 10));
      gruposGuardados.clear();
      for(DocumentSnapshot dato in querySnapshot2.documents){
        Grupo grupo = new Grupo(
          grupoID: dato.documentID,
          nombreGrupo: dato.data['nombre'],
          status: dato.data['status'],
          userID: dato.data['userID'],
          cantidad: dato.data['integrantes'],
          importe: dato.data['importe']
        );
        gruposGuardados.add(grupo);
      }

    }catch(e){
      solicitudes.clear();
      mensaje = "Error interno. Revisa tu conexión a internet 🚫☹️";
    }
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
          //widget.status == 0 ? IconButton(icon: Icon(Icons.cached), color: Colors.white, onPressed: () {showDialogo();},) : Text("")
        ],
      ),
      body: downloading ? Center(child: Container(
          height: 120.0,
          width: 200.0,
          child: Card(
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 20.0,
                ),
                Text(
                  " Descargarndo Información:\n$progressString",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        )) :  RefreshIndicator(
        key: refreshKey,
        onRefresh: ()async{
          solicitudes.clear(); 
          gruposGuardados.clear(); 
          gruposAbiertos.clear();
          grupos.clear(); 
          await getListDocumentos();
        },
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
            solicitudes.length > 0 ? listaSolicitudes() : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema)))),
            ListView()
          ]
        )
      ),
      bottomNavigationBar: widget.status == 0 ? InkWell(
          child:  Container(
            child: ListTile(
              trailing: InkWell(onTap: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "Historial", status: 5, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome,) ));}, child: Text("Historial", style: TextStyle(color: Colors.black12))),
            ),
          ), 
        ) : Text("-"),
    );
  }

  Widget listaSolicitudes(){     
    return ListView.builder(
      itemCount: solicitudes.length,
      itemBuilder: (context, index){
        if(grupos.contains(solicitudes[index].nombreGrupo)) return Padding(padding: EdgeInsets.all(0),);
        if(solicitudes[index].grupoID != null || solicitudes[index].idGrupo != null) grupos.add(solicitudes[index].nombreGrupo);
        return InkWell(
          child: Card(
            child: Container(

              child: solicitudes[index].grupoID == null && solicitudes[index].idGrupo == null ?
              InkWell(child:  ListTile(
                leading: Icon(Icons.person, color: widget.colorTema,size: 40.0,),
                title: Text(getNombre(solicitudes[index]), style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(getImporte(solicitudes[index])),
                isThreeLine: true,
                trailing: solicitudes[index].status == 0 ? getIcono(solicitudes[index]) : getIconoMenu(solicitudes[index]),//Icon(Icons.done_all),//getIconoRecuperar(solicitudes[index]),
              ), onTap: (){
                solicitudes[index].status == 99 ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CambioDocumento(title: getNombre(solicitudes[index]), colorTema: widget.colorTema, idSolicitud: solicitudes[index].idSolicitud ))) : null; },) : 
              ListTile(
                leading: Icon(Icons.group, color: widget.colorTema,size: 40.0,),
                title: Text(solicitudes[index].nombreGrupo, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: solicitudes[index].status == 0 ? getLeyendaGrupo(solicitudes[index].idGrupo) : getImpCant(solicitudes[index]),//Text("Importe:\nIntegrantes:"),
                isThreeLine: true,
                trailing: solicitudes[index].status == 0 ? getIcono2(solicitudes[index].idGrupo, solicitudes[index].nombreGrupo) : getIconoMenuGpal(solicitudes[index]),//Tooltip(message: "Los integrantes estan en proceso de aprobación.", child: Icon(Icons.done_all))//gruposGuardados.length > 0 ? getIcono2(solicitudes[index].idGrupo, solicitudes[index].nombreGrupo) : Icon(Icons.done_all),
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

  Widget getImpCant(Solicitud solicitud){
    Grupo grupo;
    if(widget.status == 0){
      grupo = gruposGuardados.firstWhere((grupo)=>grupo.grupoID == solicitud.grupoID);
      return Text("Importe: "+grupo.importe.toString()+"\nIntegrantes: "+grupo.cantidad.toString());
    }else{
      return Text("");
    }
  }

  Widget getLeyendaGrupo(int idGrupo){
    //if(gruposGuardados.length == 0) return null;
    //bool accion;
    bool accion = false;
    Grupo grupo;
    try{
      //accion = gruposGuardados.firstWhere((grupo)=>grupo.idGrupo == idGrupo).status == 0;
      grupo = gruposGuardados.firstWhere((grupo)=>grupo.idGrupo == idGrupo);
    }catch(e){
      return Row(children: <Widget>[
          Icon(accion ? Icons.lock_open : Icons.lock, size: 20,),
          Text("Integrantes: "+0.toString()+"\nImporte: "+0.toString())
        ],
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,);
    }
    
    String texto;
    texto = "Integrantes: "+grupo.cantidad.toString()+"\nImporte: "+grupo.importe.toString();
    //texto = accion ? "Grupo Abierto.\nCierralo para sincronizar." : "Grupo Cerrado.\nListo para sincronizar.";
    return Row(children: <Widget>[
      Icon(accion ? Icons.lock_open : Icons.lock, size: 20,),
      Text(texto)
    ],
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.start,);
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
              child: Row(children: <Widget>[Icon(Icons.group_work, color: Colors.blue,),Text(" Mover a Grupal")],), value: 3),
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
            }else if(value == 3){
              mostrarActionSheet(context, solicitud);
            }
          }
        )
      ],
    );
  }

  Widget getIconoMenu(Solicitud solicitud){
    if(solicitud.status == 99){
      return Column(children: <Widget>[ Icon(Icons.arrow_forward_ios)], mainAxisAlignment: MainAxisAlignment.center,);
      /*return PopupMenuButton(
        itemBuilder: (_) => <PopupMenuItem<int>>[
          new PopupMenuItem<int>(
            child: Row(children: <Widget>[Icon(Icons.add_photo_alternate, color: Colors.green,),Text(" Atender cambio de documentos")],), value: 1),
        ],
        onSelected: (value){
          if(value == 1){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CambioDocumento(title: getNombre(solicitud), colorTema: widget.colorTema, idSolicitud: solicitud.idSolicitud )));
          }
        }
      );*/
    }else{
      Widget icono;
      switch (solicitud.status) {
        case 1:
          icono = Tooltip(message: "Por autorizar consulta de Buró", child: Icon(Icons.done_all));
          break;
        case 2:
          icono = Tooltip(message: "Aprobado", child: Icon(Icons.done_all, color: Colors.green));
          break;
        case 3:
          icono = Tooltip(message: "Denegado", child: Icon(Icons.block, color: Colors.red));
          break;
        case 6:
          icono = Tooltip(message: "En revisión por cambio de documentos", child: Icon(Icons.done_all, color: Colors.yellow));
          break;
        case 7:
          icono = Tooltip(message: "En espera de consulta de Buró", child: Icon(Icons.done_all, color: Colors.blue));
          break;
        case 8:
          icono = Tooltip(message: "En proceso de consulta de Buró", child: Icon(Icons.done_all, color: Colors.blue));
          break;
        case 9:
          icono = Tooltip(message: "Por dictaminar (consulta de buró exitosa)", child: Icon(Icons.done_all, color: Colors.white));
          break;
        case 10:
          icono = Tooltip(message: "Error en consulta de Buró", child: Icon(Icons.done_all, color: Colors.red));
          break;
        default:
          icono = Tooltip(message: "Sin estatus, contactar a soporte", child: Icon(Icons.close, color: Colors.red));
          break;
      }
      return icono;
    }
  }

  Widget getIconoMenuGpal(Solicitud solicitud){
    switch (widget.status) {
      case 1:
        return Tooltip(message: "Los integrantes estan en proceso de aprobación.", child: Icon(Icons.done_all)); 
        break;
      case 3:
        return Tooltip(message: "El grupo fue Aprobado.", child: Icon(Icons.done_all, color: Colors.green,)); 
        break;
      case 4:
        return Tooltip(message: "El grupo fue Denegado.", child: Icon(Icons.done_all, color: Colors.red,)); 
        break;
      case 5:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: 
          <Widget>[
            Icon(Icons.done_all, color: Colors.black,),
            PopupMenuButton(
              itemBuilder: (_) => <PopupMenuItem<int>>[
                new PopupMenuItem<int>(
                  child: Row(children: <Widget>[Icon(Icons.list, color: Colors.blue),Text(" Ver Solicitudes", style: TextStyle(color: Colors.blue),)],), value: 2),
              ],
              onSelected: (value)async{
                if(value == 2){
                  Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(solicitud.idGrupo); 
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ListaSolicitudesGrupo(colorTema: widget.colorTema,title: solicitud.nombreGrupo, actualizaHome: widget.actualizaHome, grupo: grupo)));
                }
              }
            )
          ],
        );
        break;
      default:
        return Tooltip(message: "Default .", child: Icon(Icons.done_all, color: Colors.black,));
        break;
    }
  }

  Widget getIconoRecuperar(Solicitud solicitud){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: 
      <Widget>[
        PopupMenuButton(
          itemBuilder: (_) => <PopupMenuItem<int>>[
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.assignment_return, color: Colors.green,),Text(" Regresar a 'En espera...'")],), value: 1),
          ],
          onSelected: (value){
            if(value == 1){
              recuperarSolicitud(solicitud);
            }
          }
        ),
        Icon(Icons.done_all)
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

  cerrarGrupo(grupoId, grupoNombre){
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text("Cerrar Grupo")),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.yellow, size: 100.0,),
                Text("\nAl cerrar el grupo no podrá agregarle mas solicitudes y estará listo para sincronizarse.\n\n¿Desea cerrar el grupo "+grupoNombre+"?"),
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
                  await ServiceRepositoryGrupos.updateGrupoStatus(1, null, grupoId);
                  for(final solicitud in solicitudes){
                    if(solicitud.idGrupo == grupoId) ServiceRepositorySolicitudes.updateSolicitudStatus(0, solicitud.idSolicitud);
                  }
                  grupos.clear();
                  widget.actualizaHome();
                  getListDocumentos();
                }
              )
            ],
      );
    });
  }

  eliminarGrupo(grupoId, grupoNombre) async{
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text("Elminar Solicitud")),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.yellow, size: 100.0,),
                Text("\n¿Desea elminar el grupo "+grupoNombre+" y sus solicitudes?"),
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
                  List<Solicitud> solicitudes = List();
                  final pref = await SharedPreferences.getInstance();
                  String userID = pref.getString("uid");
                  solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudesGrupo(userID, grupoNombre);   
                  for(final solicitud in solicitudes){
                    await ServiceRepositorySolicitudes.deleteSolicitudCompleta(solicitud);
                  }
                  await ServiceRepositoryGrupos.deleteGrupo(grupoId);
                  grupos.clear();
                  widget.actualizaHome();
                  getListDocumentos();
                }
              )
            ],
      );
    });
  }

  Widget getIcono2(grupoId, grupoNombre) {
    bool accion = false;
    try{
      //accion = gruposGuardados.firstWhere((grupo)=>grupo.idGrupo == grupoId).status == 0;
    }catch(e){
      return null;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: 
      <Widget>[
        Icon(Icons.access_time,color: Colors.yellow[700],),
        PopupMenuButton(
          itemBuilder: (_) => <PopupMenuItem<int>>[
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.group_add, color: accion ? Colors.green : Colors.grey,),Text(" Agregar Solicitud", style: TextStyle(color: accion ? Colors.green : Colors.grey),)],), value: 1),
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.list, color: Colors.blue),Text(" Ver Solicitudes", style: TextStyle(color: Colors.blue),)],), value: 2),
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.lock, color: accion ? Colors.blueGrey : Colors.grey),Text(" Cerrar Grupo", style: TextStyle(color: accion ? Colors.blueGrey : Colors.grey),)],), value: 3),
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.delete, color: Colors.red),Text(" Eliminar Grupo", style: TextStyle(color: Colors.red),)],), value: 4),
          ],
          onSelected: (value)async{
            if(value == 1){
              accion ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SolicitudPage.Solicitud(title: "Solicitud Grupal: "+grupoNombre, colorTema: widget.colorTema, grupoId: grupoId, grupoNombre: grupoNombre, actualizaHome: widget.actualizaHome))) : null;
            }else if(value == 2){
              Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(grupoId); 
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ListaSolicitudesGrupo(colorTema: widget.colorTema,title: grupoNombre, actualizaHome: widget.actualizaHome, grupo: grupo)));
            }else if(value == 3){
              if(accion){
                cerrarGrupo(grupoId, grupoNombre);
              }
            }else if(value == 4){
              eliminarGrupo(grupoId, grupoNombre);
            }
          }
        )
      ],
    );
  }

  showDialogo() async{
    final pref = await SharedPreferences.getInstance();
    var _email = pref.getString("email");
    var _pass = pref.getString("pass");
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        mostrarShowDialog(true);
        var authRes = await authFirebase.signIn(_email, _pass);//poner aqui datos reales cuenta
        print('connected');
        if(authRes.result){
          await sincronizarDatos().then((_){
            Navigator.pop(context);
            widget.actualizaHome();
          });
        }else{
          Navigator.pop(context);
          mostrarShowDialog(false);
        }
      }
    } on SocketException catch (_) {
      print('not connected');
      mostrarShowDialog(false);
    }
    /*new Future.delayed(new Duration(seconds: 3), () {
      Navigator.pop(context); //pop dialog
    });*/
  }

  mostrarShowDialog(bool conectado){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: (){},
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                conectado ? CircularProgressIndicator() : Icon(Icons.error, color: Colors.red, size: 100.0,),
                conectado ? Text("\nSINCRONIZANDO ...") : Text("\nSIN CONEXIÓN"),
              ],
            ),
            actions: <Widget>[
              !conectado ?
              new FlatButton(
                child: const Text("CERRAR"),
                onPressed: (){Navigator.pop(context);}
              ) : null
            ],
          )
        );
      },
    );
  }

  sincronizarDatos() async{
    //List<File> documentos;
    List<String> gruposSinc = List();
    List<GrupoObj> gruposGuardados = List();
    List<Map> documentos;
    Persona persona;
    Direccion direccion;
    for(final solicitud in solicitudes){

      persona = new Persona(
        nombre: solicitud.nombrePrimero,
        nombreSegundo: solicitud.nombreSegundo,
        apellido: solicitud.apellidoPrimero,
        apellidoSegundo: solicitud.apellidoSegundo,
        curp: solicitud.curp,
        rfc: solicitud.rfc,
        fechaNacimiento: DateTime.fromMillisecondsSinceEpoch(solicitud.fechaNacimiento),
        telefono: solicitud.telefono
      );
      
      direccion = new Direccion(
        ciudad: solicitud.ciudad,
        coloniaPoblacion: solicitud.coloniaPoblacion,
        cp: solicitud.cp,
        delegacionMunicipio: solicitud.delegacionMunicipio,
        direccion1: solicitud.direccion1,
        estado: solicitud.estado,
        pais: solicitud.pais
      );

      documentos = [];
      await ServiceRepositoryDocumentosSolicitud.getAllDocumentosSolcitud(solicitud.idSolicitud).then((listaDocs){
        for(final doc in listaDocs){
          Documento documento = new Documento(tipo: doc.tipo, documento: doc.documento, version: doc.version);
          documentos.add(documento.toJson());
        }
      });

      await saveFireStore(documentos).then((lista) async{
        if(lista.length > 0){

          GrupoObj grupoObj = new GrupoObj();
          if(solicitud.idGrupo != null && !gruposSinc.contains(solicitud.nombreGrupo)){
            Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(solicitud.idGrupo);
            grupoObj = new GrupoObj(nombre: solicitud.nombreGrupo, status: 2, userID: solicitud.userID, importe: grupo.importe, integrantes: grupo.cantidad);
            if(grupo.grupoID == null || grupo.grupoID == "null"){
              var result = await _firestore.collection("Grupos").add(grupoObj.toJson());
              await ServiceRepositoryGrupos.updateGrupoStatus(2, result.documentID, solicitud.idGrupo);
              grupoObj.grupoID = result.documentID;
            }else{
              grupoObj.grupoID = grupo.grupoID;
            }
            gruposSinc.add(grupoObj.nombre);
            gruposGuardados.add(grupoObj);
          }else if(solicitud.idGrupo != null && gruposSinc.contains(solicitud.nombreGrupo)){
            grupoObj.grupoID = gruposGuardados.firstWhere((grupo)=> grupo.nombre == solicitud.nombreGrupo).grupoID;
          }

          SolicitudObj solicitudObj = new SolicitudObj(
            persona: persona.toJson(),
            direccion: direccion.toJson(),
            importe: solicitud.importe,
            tipoContrato: solicitud.tipoContrato,
            userID: solicitud.userID,
            status: 1,
            grupoID: solicitud.idGrupo == null ? null : grupoObj.grupoID,
            grupoNombre: solicitud.idGrupo == null ? null : solicitud.nombreGrupo
          );

          solicitudObj.documentos = lista;   
          solicitudObj.fechaCaputra = DateTime.now();
          var result = await _firestore.collection("Solicitudes").add(solicitudObj.toJson());
          await ServiceRepositorySolicitudes.updateSolicitudStatus(1, solicitud.idSolicitud);
          //if(solicitudObj.grupoId != null) ServiceRepositoryGrupos.updateGrupoStatus(2, grupoObj.grupoID, solicitudObj.grupoId);
          print(result);
          getListDocumentos();
        }else{
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 100.0,),
                    Text("\nSIN CONEXIÓN"),
                  ],
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: const Text("CERRAR"),
                    onPressed: (){Navigator.pop(context);}
                  )
                ],
              );
            },
          );
        }
      });
    } 
  }

  Future<List<Map>> saveFireStore(listaDocs) async{
    FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
    try{
      for(var doc in listaDocs){
        String mimeType = mime(path.basename(doc['documento']));
        String ext = "."+mimeType.split("/")[1];
        StorageReference reference = _firebaseStorage.ref().child('Documentos').child(DateTime.now().millisecondsSinceEpoch.toString()+"_"+doc['tipo'].toString()+ext);
        StorageUploadTask uploadTask = reference.putFile(File(doc['documento']));
        StorageTaskSnapshot downloadUrl = await uploadTask.onComplete.timeout(Duration(seconds: 10));
        doc['documento'] = await downloadUrl.ref.getDownloadURL();
      }
    }catch(e){
      listaDocs = [];
    }
    return listaDocs;
  }

  mostrarActionSheet(BuildContext context, Solicitud solicitud){
    showCupertinoModalPopup(
      context: context,
      builder: (context){
        return CupertinoActionSheet(
          title: Text("Confirma el grupo "),
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
    Solicitud solicitud = new Solicitud(idSolicitud: solicitudAux.idSolicitud, idGrupo: group.idGrupo, nombreGrupo: group.nombreGrupo, status: 6, tipoContrato: 2);
    await ServiceRepositorySolicitudes.updateMoverSolicitud(solicitud);
    Grupo grupoAux = new Grupo(idGrupo: group.idGrupo, cantidad: group.cantidad + 1, importe: group.importe + solicitudAux.importe);
    await ServiceRepositoryGrupos.updateGrupoImpCant(grupoAux);
    widget.actualizaHome();
    getListDocumentos();
    Navigator.of(context).pop();
 }

  recuperarSolicitud(Solicitud solicitud)async{
    setState(() {
      downloading = true;
      progressString = "";
    });
    
    Solicitud _solicitud = solicitud;
    try{
      var document = await _firestore.collection("Solicitudes").document(_solicitud.documentID).get().timeout(Duration(seconds:10));
      final int _id = await ServiceRepositorySolicitudes.solicitudesCount();
      final pref = await SharedPreferences.getInstance();
      final String userID = pref.getString("uid");
      final Solicitud solicitud = new Solicitud(
        idSolicitud: _id + 1,
        importe: document.data['importe'],
        nombrePrimero: document.data['persona']['nombre'],
        nombreSegundo: document.data['persona']['nombreSegundo'],
        apellidoPrimero: document.data['persona']['apellido'],
        apellidoSegundo: document.data['persona']['apellidoSegundo'],
        fechaNacimiento: document.data['persona']['fechaNacimiento'].millisecondsSinceEpoch,
        curp: document.data['persona']['curp'],
        rfc: document.data['persona']['rfc'],
        telefono:  document.data['persona']['telefono'],
        userID: userID,
        status: 0,
        tipoContrato: document.data['tipoContrato'],
        idGrupo: null,
        nombreGrupo: null,

        direccion1: document.data['direccion']['direccion1'],
        coloniaPoblacion: document.data['direccion']['coloniaPoblacion'],
        delegacionMunicipio: document.data['direccion']['delegacionMunicipio'],
        ciudad: document.data['direccion']['ciudad'],
        estado: document.data['direccion']['estado'],
        cp: document.data['direccion']['cp'],
        pais: document.data['direccion']['pais']
      );
 
      Dio dio = Dio();
      var dir = await getApplicationDocumentsDirectory();
      List<Map> listaDocs = List();

      try{
        //if(document.data['documentos'].length > 0) downloading = true;
        int iteracion = 0;
        for(final documento in document.data['documentos']){
          iteracion ++;
          String filename = documento['documento'].replaceAll(new 
                  RegExp(r'https://firebasestorage.googleapis.com/v0/b/sgcc-57fde.appspot.com/o/Documentos%2F'), '').split('?')[0];
          String rutaImagen = "${dir.path}/"+filename;
          
          await dio.download(documento['documento'], rutaImagen,
            onReceiveProgress: (rec,total){
              setState(() {
                progressString = " Documento "+iteracion.toString()+" de "+document.data['documentos'].length.toString()+" "+((rec / total) * 100).toStringAsFixed(0) + "%";
              });
            }
          );
          Documento docu = new Documento(tipo:documento['tipo'], documento: rutaImagen);//creo falta la version
          listaDocs.add(docu.toJson());
        }
      }catch(e){
        print(e);
      }
      
      print("Download completed");
      
      await ServiceRepositorySolicitudes.addSolicitud(solicitud).then((_) async{
        for(var doc in listaDocs){
          final int _idD = await ServiceRepositoryDocumentosSolicitud.documentosSolicitudCount();
          final DocumentoSolicitud documentoSolicitud = new DocumentoSolicitud(
            idDocumentoSolicitud: _idD + 1,
            idSolicitud: solicitud.idSolicitud,
            tipo: doc['tipo'],
            documento: doc['documento'] 
          );//creo que falta version
          await ServiceRepositoryDocumentosSolicitud.addDocumentoSolicitud(documentoSolicitud);
        }
        await _firestore.collection("Solicitudes").document(_solicitud.documentID).delete();
        
        for(final documento in document.data['documentos']){
          String filePath = documento['documento'].replaceAll(new 
                    RegExp(r'https://firebasestorage.googleapis.com/v0/b/sgcc-57fde.appspot.com/o/Documentos%2F'), '').split('?')[0];
          await _firebaseStorage.ref().child("Documentos").child(filePath).delete();
        }
        
        await getListDocumentos();
        setState(() {
          widget.actualizaHome();
          downloading = false;
          progressString = "Completed";
          grupos.clear();
        });
      });
      
    }catch(e){
      
    }
  }
}