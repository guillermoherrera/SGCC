import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgcartera_app/models/documento.dart';
import 'package:sgcartera_app/sqlite_files/models/cat_documento.dart';
import 'package:sgcartera_app/sqlite_files/models/documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_catDocumento.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';

import 'home.dart';

class CambioDocumento extends StatefulWidget {
  CambioDocumento({this.title, this.idSolicitud, this.colorTema});
  final String title;
  final int idSolicitud;
  final MaterialColor colorTema;
  @override
  _CambioDocumentoState createState() => _CambioDocumentoState();
}

class _CambioDocumentoState extends State<CambioDocumento> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool withData = false;
  Solicitud solicitud;
  List<DocumentoArchivo> docArchivos = List();
  List<CatDocumento> catDocumentos = List();
  bool buttonEnabled = true;

  getSolicitudInfo() async{
    catDocumentos = await RepositoryServiceCatDocumento.getAllCatDocumentos();
    solicitud = await ServiceRepositorySolicitudes.getOneSolicitud(widget.idSolicitud);
    var documentosEditar = await ServiceRepositoryDocumentosSolicitud.getAllDocumentosSolcitud(widget.idSolicitud);
    for(final doc in documentosEditar){
      if(doc.cambioDoc == 1){
        DocumentoArchivo documentoArchivo = new DocumentoArchivo(idDocumentoSolicitud: doc.idDocumentoSolicitud,tipo: doc.tipo, archivo: null, version: doc.version);
        docArchivos.add(documentoArchivo);
      }
    }
    setState(() {
      withData = true;
    });
  }
  
  @override
  void initState() {
    //getCatDocumentos();
    getSolicitudInfo();
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
            !withData ? Text("cargando ...") : SingleChildScrollView(
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
      )
    );
  }

  List<Widget> formSolicitud(){
    return [
      Container(
        child: Center(
          child: Text("ACTUALIZAR DOCUMENTO(S)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
      ),
      tipoContrato(),
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
          Text("Paso 1 de 1", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      )
    ];
  }

  Widget adjuntarId(){
    //
    List<TableRow> tablesRows = List();
    for(CatDocumento catDoc in catDocumentos){
      if(docArchivos.singleWhere((archivo) => archivo.tipo == catDoc.tipo, orElse: () => null) != null){
        tablesRows.add(itemsFiles(catDoc.descDocumento,catDoc.tipo));
        tablesRows.add(TableRow(children: [Divider(),Divider(),Divider()]));
      }
    }
    
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: tablesRows,
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
      print(auxFile.path);
    }catch(e){

    }
    var objetoArchivo = docArchivos.firstWhere((archivo) => archivo.tipo == tipo);
    objetoArchivo.archivo = auxFile;
    
    setState(() {});
  }

  showImage(tipo){
    File auxFile;
    
    auxFile = docArchivos.singleWhere((archivo) => archivo.tipo == tipo, orElse: null).archivo;
    
    if(auxFile != null && auxFile.path != "null")
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

  Widget tipoContrato(){
    String contrato;
    if(solicitud.nombreGrupo == "null"){
      contrato = "\nINDIVIDUAL";
    }else{
      contrato = "\nGRUPAL ("+solicitud.nombreGrupo+")";
    }
    return Container(
      child: Center(
        child: Text(contrato, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
    );
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
                Text(solicitud.importe.toString()),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.person, size: 15.0, color: widget.colorTema,),
                Text("NOMBRE: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(solicitud.nombrePrimero +" "+ solicitud.nombreSegundo+" "+ solicitud.apellidoPrimero +" "+ solicitud.apellidoSegundo ),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.calendar_today, size: 15.0, color: widget.colorTema,),
                Text("FECHA DE NACIMIENTO: ", style: TextStyle(fontWeight: FontWeight.bold)),
                //Text(formatDate(widget.datos.persona['fechaNacimiento'], [dd, '/', mm, '/', yyyy])),
                Text(solicitud.fechaNacimiento.toString())
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.assignment_ind, size: 15.0, color: widget.colorTema,),
                Text("CURP: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(solicitud.curp),
              ],
            ),
            TableRow(
              children: [
                Icon(Icons.assignment_ind, size: 15.0, color: widget.colorTema,),
                Text("RFC: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(solicitud.rfc),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.phone, size: 15.0, color: widget.colorTema,),
                Text("TELÉFONO: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(solicitud.telefono),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.home, size: 15.0, color: widget.colorTema,),
                Text("DIRECCIÖN: ", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(solicitud.direccion1+" "+solicitud.coloniaPoblacion+" C.P. "+solicitud.cp.toString()+" "+solicitud.delegacionMunicipio+" "+solicitud.ciudad+", "+solicitud.estado+" "+solicitud.pais),
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
    return RaisedButton(
      onPressed: buttonEnabled ? onPressed : (){},
      color: widget.colorTema,
      textColor: Colors.white,
      child: Text(text),
    );
  }

  void validaSubmit() async{
    
    var objetosArchivos = docArchivos.where((archivo) => archivo.archivo == null);
    if(objetosArchivos.length == 0){
      _buttonStatus();
      
      List<Map> documentos = [];
      for(DocumentoArchivo docArchivo in docArchivos){
        Documento documento = new Documento(idDocumentoSolicitud: docArchivo.idDocumentoSolicitud,tipo:docArchivo.tipo, documento:docArchivo.archivo.path, version: docArchivo.version);
        documentos.add(documento.toJson());
      }

      if(await saveSqfliteSolcitud(documentos)){
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: (){},
              child: 
              AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green, size: 100.0,),
                    Text("\nDOCUMENTO ACTUALIZADO"),
                  ],
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: const Text("CONTINUAR"),
                    onPressed: () async {
                      Navigator.pop(context);
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomePage(onSingIn: (){}, colorTema: widget.colorTema,)), (Route<dynamic> route) => false);
                    }
                  ),
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
        content: Text("Error al guardar. Agrega todos los documentos para poder actualizar la solicitud.", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.red[300],
        duration: Duration(seconds: 3),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  Future<bool> saveSqfliteSolcitud(listaDocs) async{
    bool result;
    try{
      for(var doc in listaDocs){
        final DocumentoSolicitud documentoSolicitud = new DocumentoSolicitud(
          idDocumentoSolicitud: doc['idDocumentoSolicitud'],
          idSolicitud: solicitud.idSolicitud,
          tipo: doc['tipo'],
          documento: doc['documento'],
          version: doc['version'],
          cambioDoc: 1
        );
        await ServiceRepositoryDocumentosSolicitud.updateDocumentoSolicitudCambio(documentoSolicitud);
      }
      await ServiceRepositorySolicitudes.updateSolicitudStatus(1, solicitud.idSolicitud);
      result = true;
    }catch(e){
      result = false;
    }
    
    return result;
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