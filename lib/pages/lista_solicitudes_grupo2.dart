import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';

class ListaSolicitudesGrupoSinc extends StatefulWidget {
  ListaSolicitudesGrupoSinc({this.title, this.colorTema, this.actualizaHome, this.solicitudes});
  final Color colorTema;
  final String title;
  final VoidCallback actualizaHome;
  final List<Solicitud> solicitudes;
  @override
  _SolicitudesGrupoState createState() => _SolicitudesGrupoState();
}

class _SolicitudesGrupoState extends State<ListaSolicitudesGrupoSinc> {
  List<Solicitud> solicitudes = List();
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  String mensaje;
  Firestore _firestore = Firestore.instance;

  Future<void> getListDocumentos() async{
    mensaje = "Cargando ...🕔";
    //solicitudes = widget.solicitudes;
    await Future.delayed(Duration(seconds:1));
    try{
      Query q = _firestore.collection("Solicitudes").where('grupoID', isEqualTo: widget.solicitudes[0].grupoID);
      
      QuerySnapshot querySnapshot = await q.getDocuments().timeout(Duration(seconds: 10));
      
      if(querySnapshot.documents.length == 0){
        q = _firestore.collection("Renovaciones").where('grupoID', isEqualTo: widget.solicitudes[0].grupoID);
        querySnapshot = await q.getDocuments().timeout(Duration(seconds: 10));
      }
      if(querySnapshot.documents.length == 0){mensaje = "Sin solicitudes por mostrar";}
      for(DocumentSnapshot dato in querySnapshot.documents){
        if(dato.data['clienteID'] == null){
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
        }else{
          Solicitud solicitud = new Solicitud(
            apellidoPrimero: dato.data['nombre'],
            apellidoSegundo: "",
            curp: dato.data['clienteID'].toString(),//Auxiliar de clienteID
            fechaNacimiento: DateTime.now().millisecondsSinceEpoch,
            //idGrupo: dato.data['grupoId'],
            grupoID: dato.data['grupoID'],
            idSolicitud: null,
            importe: dato.data['importe'],
            nombrePrimero: "",
            nombreSegundo: "",
            rfc: "",
            telefono: "",
            nombreGrupo: dato.data['grupoNombre'],
            userID: dato.data['userID'],
            status: dato.data['status'],
            tipoContrato: dato.data['tipoContrato'],
            documentID: dato.documentID
          );
          solicitudes.add(solicitud);
        }
      }
      setState(() {});
    }catch(e){
      solicitudes.clear();
      mensaje = "Error interno. Revisa tu conexión a internet";
      setState(() {});
    }
  }

  @override
  void initState() {
    getListDocumentos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(Icons.help),
            itemBuilder: (_) => <PopupMenuItem<int>>[
              PopupMenuItem<int>(
                child: Row(children: <Widget>[Text("Mantén presionado "), Icon(Icons.done_all, color: Colors.grey),Text(" en la lista.")]),
              )
            ]
          )
          //widget.status == 0 ? IconButton(icon: Icon(Icons.cached), color: Colors.white, onPressed: () {showDialogo();},) : Text("")
        ],
      ),
      body:RefreshIndicator(
        key: refreshKey,
        onRefresh: ()async{
          await Future.delayed(Duration(seconds:1));
          solicitudes.clear();
          await getListDocumentos();
        },
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
            Column(children: <Widget>[
              InkWell(
                child: Card(
                  elevation: 0.0,
                  child: Container(
                    child: ListTile(
                    //leading: Icon(Icons.assignment,color: Colors.white, size: 40.0,),
                    title: Text("", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white)),
                    subtitle: Center(child: Icon(Icons.group,color: Colors.white, size: 40.0,)),
                    //trailing: Text(""),
                    isThreeLine: true,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [widget.colorTema, widget.colorTema])
                    ),
                  )
                ),
                onTap: (){},
              ),
              Expanded(child: Container(
                height: double.infinity,
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
                  ),
                  child:  Padding(
                    padding: EdgeInsets.fromLTRB(13, 16, 13, 3),
                    child: solicitudes.length > 0 ?listaSolicitudes() : Center(child: ListView.builder(shrinkWrap: true,itemCount: 1,itemBuilder:(context, index){ return Column(mainAxisAlignment: MainAxisAlignment.center, children:[mensaje == "Cargando ...🕔" ? Padding(padding: EdgeInsets.only(top:5), child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(widget.colorTema))) : Image.asset("images/empty.png"), Padding(padding: EdgeInsets.all(50), child:Text(mensaje, style: TextStyle( fontSize: 15)))]);}),),
                  ),
                ))
              )
            ])
            /*solicitudes.length > 0 ? listaSolicitudes() : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema)))),
            solicitudes.length > 0 ? Container() : ListView()*/
          ]
        )
      ),
      
    );
  }

  Widget listaSolicitudes(){     
    return ListView.builder(
      itemCount: solicitudes.length,
      itemBuilder: (context, index){     
        return InkWell(
          child: Card(
            /*shape: RoundedRectangleBorder(
              side: BorderSide(color:widget.colorTema, width:3.0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0),
                topRight: Radius.circular(50.0),
                bottomLeft: Radius.circular(50.0),
                bottomRight: Radius.circular(50.0)
              ),
            ),*/
            child: Container(
              child: InkWell(
                child:  ListTile(
                  leading: Icon(Icons.person, color: widget.colorTema,size: 40.0,),
                  title: Text(getNombre(solicitudes[index]), style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(getImporte(solicitudes[index])),
                  isThreeLine: true,
                  trailing: getIconoMenu(solicitudes[index]),//Icon(Icons.done_all),//getIconoRecuperar(solicitudes[index]),
                ),
                onTap: (){
                  //solicitudes[index].status == 99 ? Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CambioDocumento(title: getNombre(solicitudes[index]), colorTema: widget.colorTema, idSolicitud: solicitudes[index].idSolicitud ))) : null;
                },
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, Colors.white])
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
    if(solicitud.telefono.isEmpty){
      return "CLIENTE ID: "+solicitud.curp+"\nIMPORTE: "+importe.toStringAsFixed(2);
    }else{
      return "TELÉFONO: "+solicitud.telefono+"\nIMPORTE: "+importe.toStringAsFixed(2);
    }
  }

  Widget getIconoMenu(Solicitud solicitud){
    Widget icono;
    switch (solicitud.status) {
      case 1:
        icono = Tooltip(message: "Por autorizar consulta de Buró", child: Container(child: Icon(Icons.done, color: Colors.white), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.grey ,borderRadius: BorderRadius.all(Radius.circular(25)))));
        break;
      case 2:
        icono = Tooltip(message: "Dictaminado", child: Container(child: Icon(Icons.done, color: Colors.white), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: widget.colorTema ,borderRadius: BorderRadius.all(Radius.circular(25)))));
        break;
      case 3:
        icono = Tooltip(message: "Rechazado", child: Container(child: Icon(Icons.close, color: Colors.white), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.red ,borderRadius: BorderRadius.all(Radius.circular(25)))));
        break;
      case 6:
        icono = Tooltip(message: "En revisión por cambio de documentos", child: Container(child: Icon(Icons.done, color: Colors.white), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.yellow[700] ,borderRadius: BorderRadius.all(Radius.circular(25)))));
        break;
      case 7:
        icono = Tooltip(message: "En espera de consulta de Buró", child: Container(child: Icon(Icons.done, color: Colors.blue[200]), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.grey ,borderRadius: BorderRadius.all(Radius.circular(25)))));
        break;
      case 8:
        icono = Tooltip(message: "En proceso de consulta de Buró", child: Container(child: Icon(Icons.done, color: Colors.blue[200]), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.grey ,borderRadius: BorderRadius.all(Radius.circular(25)))));
        break;
      case 9:
        icono = Tooltip(message: "Por dictaminar", child: Container(child: Icon(Icons.done, color: Colors.white), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.blue ,borderRadius: BorderRadius.all(Radius.circular(25)))));
        break;
      case 10:
        icono = Tooltip(message: "Error en consulta de Buró", child: Container(child: Icon(Icons.done, color: Colors.white), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.red ,borderRadius: BorderRadius.all(Radius.circular(25)))));
        break;
      default:
        icono = Tooltip(message: "Sin estatus, contactar a soporte", child: Container(child: Icon(Icons.error, color: Colors.white), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.red ,borderRadius: BorderRadius.all(Radius.circular(25)))));
        break;
    }
    return Column(children: <Widget>[icono], mainAxisAlignment: MainAxisAlignment.center);
  }

}