import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/classes/backblaze.dart';
import 'package:sgcartera_app/classes/shared_class.dart';
import 'package:sgcartera_app/models/backBlaze_request.dart';
import 'package:sgcartera_app/models/documento.dart';
import 'package:sgcartera_app/models/solicitud.dart';
import 'package:sgcartera_app/pages/home.dart';
import 'package:sgcartera_app/sqlite_files/models/cat_documento.dart';
import 'package:sgcartera_app/sqlite_files/models/documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_catDocumento.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sgcartera_app/pages/solicitud.dart' as PageSolicitud;
import 'lista_solicitudes.dart';
import 'lista_solicitudes_grupo.dart';

class SolicitudDocumentos extends StatefulWidget {
  SolicitudDocumentos({this.title, this.datos, this.colorTema, this.actualizaHome, this.esRenovacion});
  final String title;
  final SolicitudObj datos;
  final Color colorTema;
  final VoidCallback actualizaHome;
  bool esRenovacion;
  @override
  _SolicitudDocumentosState createState() => _SolicitudDocumentosState();
}

class _SolicitudDocumentosState extends State<SolicitudDocumentos> {
  
  bool buttonEnabled = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Firestore _firestore = Firestore.instance;
  var SolicitudID;
  List<CatDocumento> catDocumentos = List();
  List<DocumentoArchivo> docArchivos = List();
  AuthFirebase authFirebase = new AuthFirebase();
  Shared shared = Shared();

  @override
  void initState() {
    if(widget.esRenovacion == null){widget.esRenovacion = false;}
    getCatDocumentos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      body: Container(
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
            LayoutBuilder(
              builder: (context, constraint){
              return SingleChildScrollView(
                child: ConstrainedBox( constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: Card(
                    color: Colors.white,
                    margin: EdgeInsets.all(4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
                    ),
                    elevation: 0.0,
                    child: IntrinsicHeight( child:Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: formSolicitud(),
                            ),  
                          ),
                          Expanded(child:  
                            Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: styleButton(validaSubmit, buttonEnabled ? "FINALIZAR" : "GUARDANDO ..."),
                            ),
                          )
                        ]
                      )
                    )
                  ),
                ),
              );
            })
          ]
        )
      ),
    );
  }

  List<Widget> formSolicitud(){
    return [
      Container(
        child: Center(
          child: Text("ADJUNTAR DOCUMENTOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
      ),
      Divider(),
      adjuntarId(),
      Container(
        child: datosPrevios(),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Color(0xfff2f2f2)
        ),
      ),
      /*Column(
        //mainAxisAlignment: MainAxisAlignment.center,
        children: buttonWidget(),
      ),*/
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text("Paso 3 de 3", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      )
    ];
  }

  Widget adjuntarId(){
    //
    List<TableRow> tablesRows = List();
    for(CatDocumento catDoc in catDocumentos){
      tablesRows.add(itemsFiles(catDoc.descDocumento,catDoc.tipo));
      tablesRows.add(TableRow(children: [Divider(color: widget.colorTema),Divider(color: widget.colorTema,),Divider(color: widget.colorTema)]));

      if(docArchivos.length != catDocumentos.length){
        DocumentoArchivo documentoArchivo = new DocumentoArchivo(tipo: catDoc.tipo, archivo: null, version: 1);
        docArchivos.add(documentoArchivo);
      }
    }
    
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: tablesRows,
    );
  }

  Future<void> getCatDocumentos() async{
    catDocumentos = await RepositoryServiceCatDocumento.getAllCatDocumentos();
    setState(() {});
  }

  TableRow itemsFiles(titulo, tipo){
    return TableRow(
      children: [
        Container(child:  Text(titulo, style: TextStyle(fontWeight: FontWeight.bold),), padding: EdgeInsets.all(5),),
        Column(children: <Widget>[
          ButtonTheme(
            minWidth: 50.0,
            height: 30.0,
            child:RaisedButton(onPressed: ()=> imageSelectorGallery(1,tipo), child: Icon(Icons.add_photo_alternate),color: Colors.white,textColor: widget.colorTema,)
          ),
          ButtonTheme(
            minWidth: 50.0,
            height: 30.0,
            child:RaisedButton(onPressed: ()=> imageSelectorGallery(2,tipo), child: Icon(Icons.add_a_photo),color: Colors.white,textColor: widget.colorTema)
          ),
        ],),
        Padding(
          padding: EdgeInsets.only(bottom: 5.0),
          child: SizedBox(
            child: showImage(tipo),
            width: 100,
            height: 100,
          ),
        ) 
      ]
    );
  }

  imageSelectorGallery(opc, tipo) async{
    File auxFile;
    try{
      if(opc == 1)
        auxFile = await ImagePicker.pickImage(
          source: ImageSource.gallery,
          maxHeight: 800.0,
          maxWidth: 700.0
        );
      else{
        auxFile = await ImagePicker.pickImage(
          source: ImageSource.camera,
          maxHeight: 800.0,
          maxWidth: 700.0
        );
      }
      print(auxFile.path);
    }catch(e){

    }
    var objetoArchivo = docArchivos.firstWhere((archivo) => archivo.tipo == tipo);
    objetoArchivo.archivo = auxFile;
    
    setState(() {});
  }

  showImage(tipo){
    File auxFile;
    
    if(catDocumentos.length == docArchivos.length) auxFile = docArchivos.singleWhere((archivo) => archivo.tipo == tipo).archivo;
    
    if(auxFile != null){
      String titulo = catDocumentos.singleWhere((archivo) => archivo.tipo == tipo).descDocumento;
      return Container(color: Colors.black,child: Hero(
        tag: "image"+tipo.toString(),
        child: GestureDetector(
          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> ImageDetail(tipo: tipo,image: auxFile, titulo: titulo))),
          child: Image.file(auxFile)
        ),
      ));
    }else
      return Image.asset("images/noImage.png");
  }

  Widget datosPrevios(){
    return Column(
      children: <Widget>[
        Container(child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.person, color: widget.colorTema,),
            Text("DATOS DEL CLIENTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ), margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0)),
        Table(
          columnWidths: {1: FractionColumnWidth(.5)},
          children: [
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("IMPORTE CAPITAL: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.datos.importe.toStringAsFixed(2)),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("NOMBRE: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.datos.persona['nombre'] +" "+ widget.datos.persona['nombreSegundo'] +" "+ widget.datos.persona['apellido'] +" "+ widget.datos.persona['apellidoSegundo']),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("FECHA DE NACIMIENTO: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(formatDate(widget.datos.persona['fechaNacimiento'], [dd, '/', mm, '/', yyyy])),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("CURP: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.datos.persona['curp']),
              ],
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("RFC: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.datos.persona['rfc']),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("TELÉFONO: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.datos.persona['telefono']),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("DIRECCIÖN: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.datos.direccion['direccion1']+" "+widget.datos.direccion['coloniaPoblacion']+" C.P. "+widget.datos.direccion['cp'].toString()+" "+widget.datos.direccion['delegacionMunicipio']+" "+widget.datos.direccion['ciudad']+", "+widget.datos.direccion['estado']+" "+widget.datos.direccion['pais']),
              ]
            )
          ],
        )
      ],
    );
  }

  List<Widget> buttonWidget(){
    return [
      styleButton(validaSubmit, buttonEnabled ? "GUARDAR" : "GUARDANDO ..."),
    ];
  }

  Widget styleButton(VoidCallback onPressed, String text){
    return SizedBox(width: double.infinity, child:RaisedButton(
      onPressed: buttonEnabled ? onPressed : (){},
      color: Color(0xff1A9CFF),
      textColor: Colors.white,
      padding: EdgeInsets.all(12),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.arrow_forward),Text(text, style: TextStyle(fontSize: 20),)]),
    ));
  }

  void validaSubmit() async{
    
    var objetosArchivos = docArchivos.where((archivo) => archivo.archivo == null);
    if(objetosArchivos.length == 0){
      _buttonStatus();
      
      List<Map> documentos = [];
      for(DocumentoArchivo docArchivo in docArchivos){
        Documento documento = new Documento(tipo:docArchivo.tipo, documento: "", version: docArchivo.version);
        documentos.add(documento.toJson());
      }

      if(await saveSqfliteSolcitud(documentos)){
        
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "En Espera (no sincronizadas)", status: 0, colorTema: widget.colorTema,) ));
        shared.cleanSharedP();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: (){},
              child: 
              AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 100.0,),
                    Text("\nSOLICITUD GARDARDA"),
                  ],
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: const Text("CONTINUAR"),
                    onPressed: () async {
                      if(widget.datos.grupoId == null){
                        if(widget.actualizaHome != null) widget.actualizaHome();
                        Navigator.pop(context);
                        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage(colorTema: widget.colorTema, onSingIn: (){},) ));
                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomePage(onSingIn: (){}, colorTema: widget.colorTema,)), (Route<dynamic> route) => false);
                        //Navigator.popUntil(context, ModalRoute.withName('/'));
                      }else{
                        if(widget.esRenovacion){
                          widget.actualizaHome();
                          int count = 0;
                          Navigator.of(context).popUntil((_) => count++ >= 4);
                        }else{
                          widget.actualizaHome();
                          Navigator.pop(context);
                          Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(widget.datos.grupoId); 
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ListaSolicitudesGrupo(colorTema: widget.colorTema,title: grupo.nombreGrupo, actualizaHome: widget.actualizaHome, grupo: grupo)));
                          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ListaSolicitudesGrupo(colorTema: widget.colorTema,title: widget.datos.grupoNombre, actualizaHome: widget.actualizaHome)));
                        }
                      }
                    }
                  ),
                  widget.esRenovacion == null ? null : widget.esRenovacion ? null : widget.datos.grupoId != null ? new FlatButton(
                    child: Text("AGREGAR OTRA"),
                    onPressed: (){
                        widget.actualizaHome();
                        Navigator.pop(context);
                        String title = widget.esRenovacion ? "Grupo Renovación:" : "Solicitud Grupal: ";
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PageSolicitud.Solicitud(title: title+widget.datos.grupoNombre, colorTema: widget.colorTema, grupoId: widget.datos.grupoId , grupoNombre: widget.datos.grupoNombre , actualizaHome: widget.actualizaHome, esRenovacion: widget.esRenovacion,)));
                      }
                  ) : null,
                ],
              )
            );
          },
        );

      }else{
        
        final snackBar = SnackBar(
          content: Text("Error al guardar. Revise que la toda la información este correcta.", style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.red[300],
          duration: Duration(seconds: 3),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      
      }
      _buttonStatus();
    }else{
      final snackBar = SnackBar(
        content: Text("Error al guardar. Agrega todos los documentos para poder guardar la solicitud.", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.red[300],
        duration: Duration(seconds: 3),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }

  }

  Future<bool> saveSqfliteSolcitud(listaDocs) async{
    bool result;
    try{
      final int _id = await ServiceRepositorySolicitudes.solicitudesCount();
      final pref = await SharedPreferences.getInstance();
      final String userID = pref.getString("uid");
      final Solicitud solicitud = new Solicitud(
        idSolicitud: _id + 1,
        importe: widget.datos.importe,
        nombrePrimero: widget.datos.persona['nombre'],
        nombreSegundo: widget.datos.persona['nombreSegundo'],
        apellidoPrimero: widget.datos.persona['apellido'],
        apellidoSegundo: widget.datos.persona['apellidoSegundo'],
        fechaNacimiento: widget.datos.persona['fechaNacimiento'].millisecondsSinceEpoch,
        curp: widget.datos.persona['curp'],
        rfc: widget.datos.persona['rfc'],
        telefono:  widget.datos.persona['telefono'],
        userID: userID,
        status: widget.datos.grupoId == null ? 0 : 6 ,
        tipoContrato: widget.datos.tipoContrato,
        idGrupo: widget.datos.grupoId,
        nombreGrupo: widget.datos.grupoNombre,

        direccion1: widget.datos.direccion['direccion1'],
        coloniaPoblacion: widget.datos.direccion['coloniaPoblacion'],
        delegacionMunicipio: widget.datos.direccion['delegacionMunicipio'],
        ciudad: widget.datos.direccion['ciudad'],
        estado: widget.datos.direccion['estado'],
        cp: widget.datos.direccion['cp'],
        pais: widget.datos.direccion['pais'],
        fechaCaptura: DateTime.now().millisecondsSinceEpoch
      );

      await ServiceRepositorySolicitudes.addSolicitud(solicitud).then((id) async{

        if(widget.datos.grupoId != null){
          if(!widget.esRenovacion){
            Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(widget.datos.grupoId);
            Grupo grupoAux = new Grupo(idGrupo: grupo.idGrupo, cantidad: grupo.cantidad + 1, importe: grupo.importe + widget.datos.importe);
            await ServiceRepositoryGrupos.updateGrupoImpCant(grupoAux);
          }
        }
        for(var doc in listaDocs){
          final int _idD = await ServiceRepositoryDocumentosSolicitud.documentosSolicitudCount();
          final DocumentoSolicitud documentoSolicitud = new DocumentoSolicitud(
            idDocumentoSolicitud: _idD + 1,
            idSolicitud: id,
            tipo: doc['tipo'],
            documento: docArchivos.firstWhere((archivo) => archivo.tipo == doc['tipo']).archivo.path,
            version: doc['version']
          );
          await ServiceRepositoryDocumentosSolicitud.addDocumentoSolicitud(documentoSolicitud);
        }
      });

      result = true;
    }catch(e){
      result = false;
    }
    
    return result;
  }

  Future<List<Map>> saveFireStore(listaDocs) async{
    FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
    for(var doc in listaDocs){
      StorageReference reference = _firebaseStorage.ref().child('Documentos').child(DateTime.now().toString()+"_"+doc['tipo'].toString());
      //StorageUploadTask uploadTask = reference.putFile(doc['tipo']==1?identificacionFile:doc['tipo']==2?domicilioFile:buroFile);
      StorageUploadTask uploadTask = reference.putFile(docArchivos.firstWhere((archivo) => archivo.tipo == doc['tipo']).archivo);
      StorageTaskSnapshot downloadUrl = await uploadTask.onComplete;
      doc['documento'] = await downloadUrl.ref.getDownloadURL();
    }
    return listaDocs;
  }  

  void _buttonStatus(){
    setState(() {
      buttonEnabled = buttonEnabled ? false : true;
    });
  }

}

class ImageDetail extends StatelessWidget {
  ImageDetail({this.tipo, this.image, this.titulo});
  final int tipo;
  final File image;
  final String titulo;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(titulo, style: TextStyle(color: Colors.white))
      ),
      body: Center(
        child: Hero(
          tag: "image"+tipo.toString(),
          child: Image.file(image)
        )
      ),
    );
  }
}