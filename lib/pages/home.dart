import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/classes/sincroniza.dart';
import 'package:sgcartera_app/components/custom_drawer.dart';
import 'package:sgcartera_app/models/auth_res.dart';
import 'package:sgcartera_app/models/direccion.dart';
import 'package:sgcartera_app/models/documento.dart';
import 'package:sgcartera_app/models/grupo.dart';
import 'package:sgcartera_app/models/persona.dart';
import 'package:sgcartera_app/models/solicitud.dart';
import 'package:sgcartera_app/pages/grupos.dart';
import 'package:sgcartera_app/pages/lista_solicitudes.dart';
import 'package:sgcartera_app/pages/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/grupo.dart' as grupoModel;
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart' as solicitudModel;
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class HomePage extends StatefulWidget {
  HomePage({this.onSingIn, this.colorTema});
  final VoidCallback onSingIn;
  final MaterialColor colorTema;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<solicitudModel.Solicitud> solicitudes = List();
  AuthFirebase authFirebase = new AuthFirebase();
  Firestore _firestore = Firestore.instance;
  Sincroniza sincroniza = new Sincroniza();
  bool sincManual = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int userType;
  int cantSolicitudesCambios;

  Future<void> getListDocumentos() async{
    final pref = await SharedPreferences.getInstance();
    String userID = pref.getString("uid");
    userType = pref.getInt('tipoUsuario');
    solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudes(userID);
    cantSolicitudesCambios = await ServiceRepositorySolicitudes.solicitudesCambioCount(userID); 
    print("******** "+this.mounted.toString()+"**********");
    try{ setState(() {}); }catch(e){ print("ERROR: linea 49 Home:"+e.toString()); }
  }

  void _moveToSignInScreen(BuildContext context) =>
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage(colorTema: widget.colorTema, onSingIn: widget.onSingIn,) ));

  @override
  void initState() {
    getListDocumentos();  
    sincronizarInfo();
    super.initState();
  }

  sincronizarInfo()async{
    sincManual = false;
    await sincroniza.sincronizaDatos();
    actualizaInfo();
    sincManual = true;
    print("Sincronización Realizada: "+DateTime.now().toString());
    const oneSec = const Duration(seconds:300);
    new Timer.periodic(oneSec, (Timer t)async{
      if(this.mounted){
        sincManual = false;
        await sincroniza.sincronizaDatos();
        actualizaInfo();
        sincManual = true;
        print("Sincronización Realizada: "+DateTime.now().toString());
      }else{
        t.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){return new Future(() => false);},
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("App Originación"),
          centerTitle: true,
        ),
        drawer: CustomDrawer(authFirebase: AuthFirebase(),onSingIn: widget.onSingIn, colorTema: widget.colorTema, actualizaHome: ()=>actualizaInfo(), cantSolicitudesCambios: cantSolicitudesCambios, ),
        body: userType == 0 ? Center(child: Padding(padding: EdgeInsets.all(50), child:Text("Tu Usuario no esta asignado. :(\n\nPonte en contacto con soporte para mas información."))) : Container(
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
                        leading: getIcono(),
                        title: Text(getMensaje(), style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: getLeyenda(),
                        trailing: getAcciones(),
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
                  ),
                  Divider(),
                  userType == 2 ? Text("") : InkWell(
                    child: Card(
                      child: Container(
                        child: ListTile(
                        leading: Icon(Icons.person_add, color: widget.colorTema,size: 40.0,),
                        title: Text("Nueva Solicitud Individual", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Captura solicitudes de credito individual en 3 pasos."),

                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [widget.colorTema[400], Colors.white])
                        ),
                      )
                    ),
                    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Solicitud(title: "Solicitud Individual", colorTema: widget.colorTema,actualizaHome: ()=>actualizaInfo(),)));},
                  ),
                  userType == 1 ? Text("") :InkWell(
                    child: Card(
                      child: Container(
                        child: ListTile(
                        leading: Icon(Icons.group_add, color: widget.colorTema,size: 40.0,),
                        title: Text("Nueva solicitud de credito Grupal", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Captura solicitudes de Credito Grupal."),

                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [widget.colorTema[400], Colors.white])
                        ),
                      )
                    ),
                    onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Group(colorTema: widget.colorTema,actualizaHome: ()=>actualizaInfo())));},
                  )
                ],
              )
            ]
          )
        )
      ),
    );
  }

  String getMensaje(){
    String mensaje = "";
    if(solicitudes.length > 0){
      List<String> solicitudesGrupos = List();
      List<String> solicitudesIndividuales = List();
      for(final solicitud in solicitudes){
        if(!solicitudesGrupos.contains(solicitud.nombreGrupo)){
          if(solicitud.idGrupo != null){
            solicitudesGrupos.add(solicitud.nombreGrupo);
          }else{
            solicitudesIndividuales.add(solicitud.nombreGrupo);
          }
        }
      }
      mensaje = "Tienes "+(solicitudesGrupos.length+solicitudesIndividuales.length).toString()+" solicitud(es) por sincronizar";
    }else{
      mensaje = "Sin solicitudes por sincronizar.";
    }
    return mensaje;
  }

  Icon getIcono(){
    if(solicitudes.length > 0)
      return Icon(Icons.error_outline, color: Colors.red ,size: 40.0,);
    else 
      return Icon(Icons.done, color: Colors.blue ,size: 40.0,);
  }

  Widget getLeyenda(){
    if(solicitudes.length > 0)
      return Row(children: <Widget>[
        Text("Da clic en "),
        Icon(Icons.more_vert, size: 13.0,),
        Text(" para tomar acciones.")
      ],);
    else 
      return Text("Todo marcha bien.");
  }

  Widget getAcciones(){
    return solicitudes.length > 0 ? PopupMenuButton(
      itemBuilder: (_) => <PopupMenuItem<int>>[
        new PopupMenuItem<int>(
            child: Row(children: <Widget>[Icon(Icons.cached, color: Colors.green,),Text(" Sincronizar")],), value: 1),
        new PopupMenuItem<int>(
            child: Row(children: <Widget>[Icon(Icons.list, color: Colors.blue),Text(" Ver Solicitudes")],), value: 2),
      ],
      onSelected: (value){
        if(value == 1){
          if(sincManual){
            showDialogo();
          }else{
            showSnackBar("Atención: El proceso de sincronizaición esta en curso, por favor espera un momento.", Colors.red);
          }
        }
        else if(value == 2){
          if(sincManual){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ListaSolicitudes(colorTema: widget.colorTema,title: "En Espera (no sincronizadas)",status: 0,actualizaHome: ()=>actualizaInfo() )));
          }else{
            showSnackBar("Atención: El proceso de sincronizaición esta en curso, por favor espera un momento.", Colors.red);
          }
        }
      }
    ) : Text("");
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
          //documentos.add(documento.toJson());
          Map docMap = documento.toJson();
          docMap.removeWhere((key, value) => key == "idDocumentoSolicitud");
          documentos.add(docMap);
        }
      });

      await saveFireStore(documentos).then((lista) async{
        if(lista.length > 0){
          
          GrupoObj grupoObj = new GrupoObj();
          if(solicitud.idGrupo != null && !gruposSinc.contains(solicitud.nombreGrupo)){
            grupoModel.Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(solicitud.idGrupo);
            grupoObj = new GrupoObj(nombre: solicitud.nombreGrupo, status: 2, userID: solicitud.userID, importe: grupo.importe, integrantes: grupo.cantidad);
            if(grupo.grupoID == null){
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

  showSnackBar(String texto, MaterialColor color){
    final snackBar = SnackBar(
      content: Text(texto, style: TextStyle(fontWeight: FontWeight.bold),),
      backgroundColor: color[300],
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void actualizaInfo(){
    getListDocumentos();
  }
}