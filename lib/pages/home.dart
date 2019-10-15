import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/components/custom_drawer.dart';
import 'package:sgcartera_app/models/documento.dart';
import 'package:sgcartera_app/models/persona.dart';
import 'package:sgcartera_app/models/solicitud.dart';
import 'package:sgcartera_app/pages/lista_solicitudes.dart';
import 'package:sgcartera_app/pages/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart' as solicitudModel;
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';

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
    String userID = await authFirebase.currrentUser();
    solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudes(userID);    
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

  String getMensaje(){
    String mensaje;
    if(solicitudes.length > 0)
      mensaje = "Tienes "+solicitudes.length.toString()+" solicitud(es) por sincronizar";
    else
      mensaje = "Sin solicitudes por sincronizar.";
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
    return new PopupMenuButton(
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => ListaSolicitudes(colorTema: widget.colorTema,title: "En Espera (no sincronizadas)",status: 0,)));
        }
      }
    );
  }

  showDialogo() async{
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              Text("\nSINCRONIZANDO ..."),
            ],
          )
        );
      },
    );

    await sincronizarDatos().then((_){
      Navigator.pop(context);
    });

    /*new Future.delayed(new Duration(seconds: 3), () {
      Navigator.pop(context); //pop dialog
    });*/
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
        tipoContrato: 1,////////////////////////////////AGREGAR A LA TABLA SQFLITE
        userID: solicitud.userID,
      );
      
      documentos = [];
      await ServiceRepositoryDocumentosSolicitud.getAllDocumentosSolcitud(solicitud.idSolicitud).then((listaDocs){
        for(final doc in listaDocs){
          Documento documento = new Documento(tipo: doc.tipo, documento: doc.documento);
          documentos.add(documento.toJson());
        }
      });

      await saveFireStore(documentos).then((lista) async{
        solicitudObj.documentos = lista;   
        solicitudObj.fechaCaputra = DateTime.now();
        var result = await _firestore.collection("Solicitudes").add(solicitudObj.toJson());
        print(result);
      });
    } 
  }

  Future<List<Map>> saveFireStore(listaDocs) async{
    FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
    for(var doc in listaDocs){
      StorageReference reference = _firebaseStorage.ref().child('Documentos').child(DateTime.now().toString()+"_"+doc['tipo'].toString());
      StorageUploadTask uploadTask = reference.putFile(File(doc['documento']));
      StorageTaskSnapshot downloadUrl = await uploadTask.onComplete;
      doc['documento'] = await downloadUrl.ref.getDownloadURL();
    }
    return listaDocs;
  }  
}