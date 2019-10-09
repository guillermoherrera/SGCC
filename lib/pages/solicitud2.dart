import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgcartera_app/classes/backblaze.dart';
import 'package:sgcartera_app/models/backBlaze_request.dart';
import 'package:sgcartera_app/models/documento.dart';
import 'package:sgcartera_app/models/solicitud.dart';

class SolicitudDocumentos extends StatefulWidget {
  SolicitudDocumentos({this.title, this.datos, this.colorTema});
  final String title;
  final SolicitudObj datos;
  final MaterialColor colorTema;
  @override
  _SolicitudDocumentosState createState() => _SolicitudDocumentosState();
}

class _SolicitudDocumentosState extends State<SolicitudDocumentos> {
  File identificacionFile;
  File domicilioFile;
  File buroFile;
  bool buttonEnabled = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Firestore _firestore = Firestore.instance;
  var SolicitudID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
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
            SingleChildScrollView(
              child: Container(
                child: Card(
                  color: Colors.white70,
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 8.0,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: formSolicitud(),
                    ),
                  ),
                ),
              ),
            )
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
      datosPrevios(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttonWidget(),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text("Paso 2 de 2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      )
    ];
  }

  Widget adjuntarId(){
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      //border: TableBorder.all(color: Colors.white70),
      children: [
        itemsFiles("IDENTIFICACIÓN", 1),
        TableRow(children: [Divider(),Divider(),Divider()]),
        itemsFiles("COMPROBANTE DE DOMICILIO", 2),
        TableRow(children: [Divider(),Divider(),Divider()]),
        itemsFiles("AUTORIZACIÓN DE BURÓ", 3),
      ],
    );
  }

  TableRow itemsFiles(titulo, tipo){
    return TableRow(
      children: [
        Container(child:  Text(titulo), padding: EdgeInsets.all(5),),
        Column(children: <Widget>[
          ButtonTheme(
            minWidth: 50.0,
            height: 30.0,
            child:RaisedButton(onPressed: ()=> imageSelectorGallery(1,tipo), child: Icon(Icons.add_photo_alternate),color: widget.colorTema,textColor: Colors.white,)
          ),
          ButtonTheme(
            minWidth: 50.0,
            height: 30.0,
            child:RaisedButton(onPressed: ()=> imageSelectorGallery(2,tipo), child: Icon(Icons.add_a_photo),color: widget.colorTema,textColor: Colors.white)
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
    }catch(e){

    }
    switch (tipo){
      case 1:
        identificacionFile = auxFile;
        break;
      case 2:
        domicilioFile = auxFile;
        break;
      case 3:
        buroFile = auxFile;
        break;
    }
    setState(() {});
  }

  showImage(tipo){
    File auxFile;
    switch (tipo){
      case 1:
        auxFile = identificacionFile;
        break;
      case 2:
        auxFile = domicilioFile;
        break;
      case 3:
        auxFile = buroFile;
        break;
    }
    if(auxFile != null)
      //return Image.file(auxFile);
      return Hero(
        tag: "image"+tipo.toString(),
        child: GestureDetector(
          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> ImageDetail(tipo: tipo,image: auxFile))),
          child: Image.file(auxFile)
        ),
      );
    else
      return Image.asset("images/noImage.png");
  }

  Widget datosPrevios(){
    return Column(
      children: <Widget>[
        Container(child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("DATOS DEL CLIENTE", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ), margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0)),
        Table(
          columnWidths: {0: FractionColumnWidth(.1)},
          children: [
            TableRow(
              children: [
                Icon(Icons.attach_money, size: 15.0, color: widget.colorTema,),
                Text("IMPORTE CAPITAL: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.datos.importe.toStringAsFixed(2)),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.person, size: 15.0, color: widget.colorTema,),
                Text("NOMBRE: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.datos.persona['nombre'] +" "+ widget.datos.persona['nombreSegundo'] +" "+ widget.datos.persona['apellido'] +" "+ widget.datos.persona['apellidoSegundo']),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.calendar_today, size: 15.0, color: widget.colorTema,),
                Text("FECHA DE NACIMIENTO: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(formatDate(widget.datos.persona['fechaNacimiento'], [dd, '/', mm, '/', yyyy])),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.assignment_ind, size: 15.0, color: widget.colorTema,),
                Text("CURP: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.datos.persona['curp']),
              ],
            ),
            TableRow(
              children: [
                Icon(Icons.assignment_ind, size: 15.0, color: widget.colorTema,),
                Text("RFC: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.datos.persona['rfc']),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.phone, size: 15.0, color: widget.colorTema,),
                Text("TELÉFONO: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(widget.datos.persona['telefono']),
              ]
            )
          ],
        )
      ],
    );
  }

  List<Widget> buttonWidget(){
    return [
      styleButton(validaSubmit, buttonEnabled ? "GUARDAR Fbase" : "GUARDANDO ..."),
      /*Text(" "),
      styleButton(validaSubmit2, buttonEnabled ? "GUARDAR Bblaze" : "GUARDANDO ...")*/
    ];
  }

  Widget styleButton(VoidCallback onPressed, String text){
    return RaisedButton(
      onPressed: buttonEnabled ? onPressed : (){},
      color: widget.colorTema,
      textColor: Colors.white,
      child: Text(text),
    );
  }

  void validaSubmit2() async{
    if(identificacionFile != null && domicilioFile != null && buroFile != null){
      _buttonStatus();
      
      List<Map> documentos = [];
      Documento documento1 = new Documento(tipo:1, documento: "Id1");
      documentos.add(documento1.toJson());
      Documento documento2 = new Documento(tipo:2, documento: "Id2");
      documentos.add(documento2.toJson());
      Documento documento3 = new Documento(tipo:3, documento: "Id3");
      documentos.add(documento3.toJson());
      //widget.datos.documentos = documentos;

      await saveBackBlaze(documentos).then((lista) async{
        widget.datos.documentos = lista;   
        widget.datos.fechaCaputra = DateTime.now();
        var result = await _firestore.collection("Solicitudes").add(widget.datos.toJson());
        SolicitudID = result.documentID;
      });

      
      final snackBar = SnackBar(
        content: Text("OK.", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.green[300],
        duration: Duration(seconds: 3),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
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

  Future<List<Map>> saveBackBlaze(listaDocs) async{
    BackBlaze backBlaze = new BackBlaze(); 
    for(var doc in listaDocs){
      BackBlazeRequest backBlazeRequest = await backBlaze.b2UploadFile(doc['tipo']==1?identificacionFile:doc['tipo']==2?domicilioFile:buroFile);
      doc['documento'] = backBlazeRequest.documentId;
    }
    return listaDocs;
  }  

  void validaSubmit() async{
    if(identificacionFile != null && domicilioFile != null && buroFile != null){
      _buttonStatus();
      
      List<Map> documentos = [];
      Documento documento1 = new Documento(tipo:1, documento: "ruta1");
      documentos.add(documento1.toJson());
      Documento documento2 = new Documento(tipo:2, documento: "ruta2");
      documentos.add(documento2.toJson());
      Documento documento3 = new Documento(tipo:3, documento: "ruta3");
      documentos.add(documento3.toJson());
      //widget.datos.documentos = documentos;

      await saveFireStore(documentos).then((lista) async{
        widget.datos.documentos = lista;   
        widget.datos.fechaCaputra = DateTime.now();
        var result = await _firestore.collection("Solicitudes").add(widget.datos.toJson());
        SolicitudID = result.documentID;
      });

      
      final snackBar = SnackBar(
        content: Text("OK.", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.green[300],
        duration: Duration(seconds: 3),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
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

  Future<List<Map>> saveFireStore(listaDocs) async{
    FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
    for(var doc in listaDocs){
      StorageReference reference = _firebaseStorage.ref().child('Documentos').child(DateTime.now().toString()+"_"+doc['tipo'].toString());
      StorageUploadTask uploadTask = reference.putFile(doc['tipo']==1?identificacionFile:doc['tipo']==2?domicilioFile:buroFile);
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
  ImageDetail({this.tipo, this.image});
  final int tipo;
  final File image;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(tipo == 1 ? "IDENTIFICACÓN" : tipo == 2 ? "COMPROBANTE DE DOMICILIO" : "AUTORIZACIÓN DE BURO")
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