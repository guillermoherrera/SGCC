import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sgcartera_app/models/solicitud.dart';

class SolicitudArchivos extends StatefulWidget {
  SolicitudArchivos({this.title, this.datos});
  final String title;
  final SolicitudObj datos;
  @override
  _SolicitudArchivosState createState() => _SolicitudArchivosState();
}

class _SolicitudArchivosState extends State<SolicitudArchivos> {
  File identidicacionFile;
  File domicilioFile;
  File buroFile;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                colors: [Colors.blue[100], Colors.white])
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
          child: Text("ADJUNTAR ARCHIVOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
      ),
      Divider(),
      adjuntarId(),
      Divider(),
      datosPrevios(),
      Column(
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        itemsFiles("IDENTIFICACIÓN", 1),
        Divider(),
        itemsFiles("COMPROBANTE\n DE DOMICILIO", 2),
        Divider(),
        itemsFiles("AUTORIZACIÓN\n DE BURÓ", 3),
      ],
    );
  }

  Widget itemsFiles(titulo, tipo){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center ,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Text(titulo),
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(children: <Widget>[
            ButtonTheme(
              minWidth: 50.0,
              height: 30.0,
              child:RaisedButton(onPressed: ()=> imageSelectorGallery(1,tipo), child: Icon(Icons.add_photo_alternate),color: Colors.blue,textColor: Colors.white,)
            ),
            ButtonTheme(
              minWidth: 50.0,
              height: 30.0,
              child:RaisedButton(onPressed: ()=> imageSelectorGallery(2,tipo), child: Icon(Icons.add_a_photo),color: Colors.blue,textColor: Colors.white)
            ),
          ],) 
        ),
        Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: SizedBox(
            child: showImage(tipo),
            width: 100,
            height: 100,
          ),
        )
      ],
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
        identidicacionFile = auxFile;
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
        auxFile = identidicacionFile;
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
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("DATOS DEL CLIENTE:", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ), margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("NOMBRE: "),
            Text(widget.datos.nombre +" "+ widget.datos.nombreSegundo +" "+ widget.datos.apellido +" "+ widget.datos.apellidoSegundo),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("FECHA DE NACIMIENTO: "),
            Text(formatDate(widget.datos.fechaNacimiento, [dd, '/', mm, '/', yyyy])),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("CURP: "),
            Text(widget.datos.curp),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("RFC: "),
            Text(widget.datos.rfc),
          ],
        ),
      ],
    );
  }

  List<Widget> buttonWidget(){
    return [
      styleButton((){}, "GUARDAR")
    ];
  }

  Widget styleButton(VoidCallback onPressed, String text){
    return RaisedButton(
      onPressed: onPressed,
      color: Colors.blue,
      textColor: Colors.white,
      child: Text(text),
    );
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