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
  final Color colorTema;
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
        DocumentoArchivo documentoArchivo = new DocumentoArchivo(idDocumentoSolicitud: doc.idDocumentoSolicitud,tipo: doc.tipo, archivo: null, version: doc.version, observacionCambio: doc.observacionCambio);
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
            !withData ? Text("cargando ...") : LayoutBuilder(
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
                    ))
                  ),
                ),
              );
            }) 
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
      Divider(),
      tipoContrato(),
      adjuntarId(),
      Container(
        child: datosPrevios(),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Color(0xfff2f2f2)
        ),
      ),
      /*Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttonWidget(),
      ),*/
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
        tablesRows.add(observCambio(docArchivos.singleWhere((archivo) => archivo.tipo == catDoc.tipo).observacionCambio));
        tablesRows.add(TableRow(children: [Divider(color: widget.colorTema),Divider(color: widget.colorTema),Divider(color: widget.colorTema)]));
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
        Container(child:  Text(titulo, style: TextStyle(fontWeight: FontWeight.bold)), padding: EdgeInsets.all(5),),
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

  TableRow observCambio(String observ){
    return TableRow(children: [
      Text("OBSERVACIÓN:", style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold),),
      Text(observ, style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold)),
      Icon(Icons.error, color: Colors.yellow[900], size: 40,)
    ]);
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
      return Container(color: Colors.black,child: Hero(
        tag: "image"+tipo.toString(),
        child: GestureDetector(
          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> ImageDetail(tipo: tipo,image: auxFile))),
          child: Image.file(auxFile)
        ),
      ));
    else
      return Image.asset("images/noImage.png");
  }

  Widget tipoContrato(){
    String contrato;
    if(solicitud.nombreGrupo == "null"){
      contrato = "INDIVIDUAL";
    }else{
      contrato = "GRUPO: "+solicitud.nombreGrupo+"";
    }
    return Container(
      child: Center(
        child: Text(contrato, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.grey)),
      ),
    );
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
                Text(solicitud.importe.toString()),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("NOMBRE: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(solicitud.nombrePrimero +" "+ solicitud.nombreSegundo+" "+ solicitud.apellidoPrimero +" "+ solicitud.apellidoSegundo ),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("FECHA DE NACIMIENTO: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                //Text(formatDate(widget.datos.persona['fechaNacimiento'], [dd, '/', mm, '/', yyyy])),
                Text(solicitud.fechaNacimiento.toString())
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("CURP: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(solicitud.curp),
              ],
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("RFC: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(solicitud.rfc),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("TELÉFONO: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(solicitud.telefono),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("DIRECCIÖN: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
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
      color: Color(0xff1A9CFF),
      textColor: Colors.white,
      padding: EdgeInsets.all(12),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.arrow_forward),Text(text, style: TextStyle(fontSize: 20),)]),
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
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(tipo == 1 ? "IDENTIFICACÓN" : tipo == 2 ? "COMPROBANTE DE DOMICILIO" : "AUTORIZACIÓN DE BURO", style: TextStyle(color: Colors.white))
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