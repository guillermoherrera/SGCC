import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';

class ListaSolicitudes extends StatefulWidget {
  ListaSolicitudes({this.title, this.status, this.colorTema});
  final MaterialColor colorTema;
  final String title;
  final int status;
  @override
  _ListaSolicitudesState createState() => _ListaSolicitudesState();
}

class _ListaSolicitudesState extends State<ListaSolicitudes> {
  List<Solicitud> solicitudes = List();  
  AuthFirebase authFirebase = new AuthFirebase();
  
  Future<void> getListDocumentos() async{
    String userID = await authFirebase.currrentUser();
    switch (widget.status) {
      case 0:
        solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudes(userID);    
        break;
      default:
    }
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
        title: Text(widget.title),
        centerTitle: true,
        actions: <Widget>[
          widget.status == 0 ? IconButton(icon: Icon(Icons.cached), color: Colors.white, onPressed: () {},) : Text("")
        ],
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
            solicitudes.length > 0 ? listaSolicitudes() : Center(child: Text("Sin Información"),) 
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
              child: ListTile(
                leading: Icon(Icons.person, color: widget.colorTema,size: 40.0,),
                title: Text(getNombre(solicitudes[index]), style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(getImporte(solicitudes[index])),
                isThreeLine: true,
                trailing: getIcono(),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [widget.colorTema[400], Colors.white])
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

  Icon getIcono(){
    return Icon(Icons.access_time,color: Colors.yellow[700],);
  }
}