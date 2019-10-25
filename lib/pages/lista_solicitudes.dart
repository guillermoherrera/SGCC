import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/models/documento.dart';
import 'package:sgcartera_app/models/persona.dart';
import 'package:sgcartera_app/models/solicitud.dart';
import 'package:sgcartera_app/pages/solicitud_editar.dart';
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';
import 'package:sgcartera_app/pages/solicitud.dart' as SolicitudPage;
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart'; 
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String mensaje = "Cargando ...";
  
  Future<void> getListDocumentos() async{
    final pref = await SharedPreferences.getInstance();
    String userID = pref.getString("uid");
    switch (widget.status) {
      case 0:
        gruposGuardados = await ServiceRepositoryGrupos.getAllGruposEspera(userID);
        gruposAbiertos = await ServiceRepositoryGrupos.getAllGrupos(userID);
        solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudes(userID);  
        mensaje = "Sin solicitudes en espera";
        break;
      case 1:
        mensaje = "Sin solicitudes por autorizar";
        await getSolcitudesespera();
        break;
      default:
    }
    setState(() {});
  }

  getSolcitudesespera() async{
    try{
      Query q = _firestore.collection("Solicitudes").where('status', isEqualTo: 1);
      QuerySnapshot querySnapshot = await q.getDocuments().timeout(Duration(seconds: 10));
      for(DocumentSnapshot dato in querySnapshot.documents){
        Solicitud solicitud = new Solicitud(
          apellidoPrimero: dato.data['persona']['apellido'],
          apellidoSegundo: dato.data['persona']['apellidoSegundo'],
          curp: dato.data['persona']['curp'],
          fechaNacimiento: dato.data['persona']['fechaNacimiento'].millisecondsSinceEpoch,
          idGrupo: dato.data['grupoId'],
          idSolicitud: null,
          importe: dato.data['importe'],
          nombrePrimero: dato.data['persona']['nombre'],
          nombreSegundo: dato.data['persona']['nombreSegundo'],
          rfc: dato.data['persona']['rfc'],
          telefono: dato.data['persona']['telefono'],
          nombreGrupo: dato.data['grupoNombre'],
          userID: dato.data['userID'],
          status: dato.data['status'],
          tipoContrato: dato.data['tipoContrato']
        );
        solicitudes.add(solicitud);
      }
    }catch(e){
      mensaje = "Error interno. Revisa tu conexión a internet";
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
          widget.status == 0 ? IconButton(icon: Icon(Icons.cached), color: Colors.white, onPressed: () {showDialogo();},) : Text("")
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
            solicitudes.length > 0 ? listaSolicitudes() : Center(child: Text(mensaje),) 
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
                trailing: solicitudes[index].status == 0 ? getIcono(solicitudes[index]) : Icon(Icons.done_all),
              ) : 
              ListTile(
                leading: Icon(Icons.group, color: widget.colorTema,size: 40.0,),
                title: Text(solicitudes[index].nombreGrupo, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: getLeyendaGrupo(solicitudes[index].idGrupo),
                isThreeLine: true,
                trailing: getIcono2(solicitudes[index].idGrupo, solicitudes[index].nombreGrupo)//gruposGuardados.length > 0 ? getIcono2(solicitudes[index].idGrupo, solicitudes[index].nombreGrupo) : Icon(Icons.done_all),
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

  Widget getLeyendaGrupo(int idGrupo){
    //if(gruposGuardados.length == 0) return null;
    //bool accion;
    bool accion = false;
    try{
      //accion = gruposGuardados.firstWhere((grupo)=>grupo.idGrupo == idGrupo).status == 0;
    }catch(e){
      return null;
    }
    Grupo grupo = gruposGuardados.firstWhere((grupo)=>grupo.idGrupo == idGrupo);
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
                  await ServiceRepositoryGrupos.updateGrupoStatus(1, grupoId);
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
    List<Map> documentos;
    Persona persona;
    for(final solicitud in solicitudes){

      persona = new Persona(
        nombre: solicitud.nombrePrimero,
        nombreSegundo: solicitud.nombreSegundo,
        apellido: solicitud.apellidoPrimero,
        apellidoSegundo: solicitud.apellidoSegundo,
        curp: solicitud.curp,
        rfc: solicitud.rfc,
        fechaNacimiento: DateTime.fromMicrosecondsSinceEpoch(solicitud.fechaNacimiento),
        telefono: solicitud.telefono
      );

      SolicitudObj solicitudObj = new SolicitudObj(
        persona: persona.toJson(),
        importe: solicitud.importe,
        tipoContrato: solicitud.tipoContrato,
        userID: solicitud.userID,
        status: 1,
        grupoId: solicitud.idGrupo,
        grupoNombre: solicitud.idGrupo == null ? null : solicitud.nombreGrupo 
      );
      
      documentos = [];
      await ServiceRepositoryDocumentosSolicitud.getAllDocumentosSolcitud(solicitud.idSolicitud).then((listaDocs){
        for(final doc in listaDocs){
          Documento documento = new Documento(tipo: doc.tipo, documento: doc.documento);
          documentos.add(documento.toJson());
        }
      });

      await saveFireStore(documentos).then((lista) async{
        if(lista.length > 0){
          solicitudObj.documentos = lista;   
          solicitudObj.fechaCaputra = DateTime.now();
          var result = await _firestore.collection("Solicitudes").add(solicitudObj.toJson());
          await ServiceRepositorySolicitudes.updateSolicitudStatus(1, solicitud.idSolicitud);
          if(solicitudObj.grupoId != null) ServiceRepositoryGrupos.updateGrupoStatus(2, solicitudObj.grupoId);
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
        StorageReference reference = _firebaseStorage.ref().child('Documentos').child(DateTime.now().toString()+"_"+doc['tipo'].toString());
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
    Solicitud solicitud = new Solicitud(idSolicitud: solicitudAux.idSolicitud, idGrupo: group.idGrupo, nombreGrupo: group.nombreGrupo, status: 6);
    await ServiceRepositorySolicitudes.updateMoverSolicitud(solicitud);
    Grupo grupoAux = new Grupo(idGrupo: group.idGrupo, cantidad: group.cantidad + 1, importe: group.importe + solicitudAux.importe);
    await ServiceRepositoryGrupos.updateGrupoImpCant(grupoAux);
    widget.actualizaHome();
    getListDocumentos();
    Navigator.of(context).pop();
 }

}