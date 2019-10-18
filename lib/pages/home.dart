import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/components/custom_drawer.dart';
import 'package:sgcartera_app/models/auth_res.dart';
import 'package:sgcartera_app/models/documento.dart';
import 'package:sgcartera_app/models/persona.dart';
import 'package:sgcartera_app/models/solicitud.dart';
import 'package:sgcartera_app/pages/grupos.dart';
import 'package:sgcartera_app/pages/lista_solicitudes.dart';
import 'package:sgcartera_app/pages/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart' as solicitudModel;
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  Future<void> getListDocumentos() async{
    final pref = await SharedPreferences.getInstance();
    String userID = pref.getString("uid");
    solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudes(userID);    
    setState(() {});
  }

  void _moveToSignInScreen(BuildContext context) =>
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage(colorTema: widget.colorTema, onSingIn: widget.onSingIn,) ));

  @override
  void initState() {
    getListDocumentos();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){return new Future(() => false);},
      child: Scaffold(
        appBar: AppBar(
          title: Text("Sistema Originación"),
          centerTitle: true,
        ),
        drawer: CustomDrawer(authFirebase: AuthFirebase(),onSingIn: widget.onSingIn, colorTema: widget.colorTema, actualizaHome: ()=>actualizaInfo() ),
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
                  InkWell(
                    child: Card(
                      child: Container(
                        child: ListTile(
                        leading: Icon(Icons.person_add, color: widget.colorTema,size: 40.0,),
                        title: Text("Nueva Solicitud Individual", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Captura solicitudes de credito individual."),

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
                  InkWell(
                    child: Card(
                      child: Container(
                        child: ListTile(
                        leading: Icon(Icons.group, color: widget.colorTema,size: 40.0,),
                        title: Text("Grupos", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Captura y revisa tus solicitudes de Credito Grupal."),

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
          showDialogo();
        }
        else if(value == 2){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ListaSolicitudes(colorTema: widget.colorTema,title: "En Espera (no sincronizadas)",status: 0,actualizaHome: ()=>actualizaInfo() )));
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
          print(result);
          getListDocumentos();
        }{
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

  void actualizaInfo(){
    getListDocumentos();
  }
}