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
      
      for(DocumentSnapshot dato in querySnapshot.documents){
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
      }
      setState(() {});
    }catch(e){
      solicitudes.clear();
      mensaje = "Error interno. Revisa tu conexión a internet 🚫☹️";
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
        title: Text(widget.title),
        centerTitle: true,
        actions: <Widget>[
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
                colors: [widget.colorTema, Colors.white])
              ),
            ),
            solicitudes.length > 0 ? listaSolicitudes() : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema)))),
            solicitudes.length > 0 ? Container() : ListView()
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
                colors: [widget.colorTema, Colors.white])
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

  Widget getIconoMenu(Solicitud solicitud){
    Widget icono;
    switch (solicitud.status) {
      case 1:
        icono = Tooltip(message: "Por autorizar consulta de Buró", child: Icon(Icons.done_all));
        break;
      case 2:
        icono = Tooltip(message: "Dictaminado", child: Icon(Icons.done_all, color: Colors.lightGreenAccent));
        break;
      case 3:
        icono = Tooltip(message: "Rechazado", child: Icon(Icons.block, color: Colors.red));
        break;
      case 6:
        icono = Tooltip(message: "En revisión por cambio de documentos", child: Icon(Icons.done_all, color: Colors.yellow));
        break;
      case 7:
        icono = Tooltip(message: "En espera de consulta de Buró", child: Icon(Icons.done_all, color: Colors.blue));
        break;
      case 8:
        icono = Tooltip(message: "En proceso de consulta de Buró", child: Icon(Icons.done_all, color: Colors.blue));
        break;
      case 9:
        icono = Tooltip(message: "Por dictaminar (consulta de buró exitosa)", child: Icon(Icons.done_all, color: Colors.white));
        break;
      case 10:
        icono = Tooltip(message: "Error en consulta de Buró", child: Icon(Icons.done_all, color: Colors.red));
        break;
      default:
        icono = Tooltip(message: "Sin estatus, contactar a soporte", child: Icon(Icons.close, color: Colors.red));
        break;
    }
    return icono;
  }

}