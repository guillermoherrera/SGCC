import 'package:flutter/material.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:sgcartera_app/models/grupo_renovacion.dart';
import 'package:sgcartera_app/models/renovacion.dart';
import 'package:sgcartera_app/pages/renovacionesMonto.dart';
import 'package:sgcartera_app/pages/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart' as SolicitudModel; 
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RenovacionesDetalle extends StatefulWidget {
  RenovacionesDetalle({this.colorTema, this.grupoInfo, this.actualizaHome});
  final MaterialColor colorTema;
  final GrupoRenovacion grupoInfo;
  final VoidCallback actualizaHome;
  @override
  _RenovacionesDetalleState createState() => _RenovacionesDetalleState();
}

class _RenovacionesDetalleState extends State<RenovacionesDetalle> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  List<Renovacion> listaRenovacion = List();
  List<Renovacion> listaRenEnviar = List();
  List<SolicitudModel.Solicitud> solicitudes = List(); 
  String mensaje = "Cargando ...🕔";
  int integrantes = 0;
  double importe = 0.0;
  List<bool> inputs = new List<bool>();

  @override
  void initState() {
    getListDocumentos();
    super.initState();
  }

  getListDocumentos()async{
    listaRenovacion.clear();
    inputs.clear();
    for(var i = 0; i <= 5; i++){
      Renovacion renovacion = new Renovacion(
        creditoID: 100+i, 
        clienteID: 1000+i,
        nombre: "Nombre Cliente " + (i+1).toString(),
        importe: 1000.0 + i,
        capital: 100.0 + i,
        diasAtraso: i, 
        beneficios: i%2 == 0 ? [{"cveBeneficio":"A"}] : null
      );
      listaRenovacion.add(renovacion);
      listaRenEnviar.add(renovacion);
      inputs.add(true);
    }
    await getListNewDocumentos();
    await getSuma();
    setState(() {});
  }

  Future<void> getListNewDocumentos() async{
    final pref = await SharedPreferences.getInstance();
    String userID = pref.getString("uid");
    solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudesGrupo(userID, widget.grupoInfo.nombre);
    solicitudes.forEach((f){
      Renovacion renovacion = new Renovacion(
        creditoID: f.idSolicitud, 
        clienteID: null,
        nombre: f.nombrePrimero + " " + f.nombreSegundo + " " + f.apellidoPrimero + " " + f.apellidoSegundo ,
        importe: f.importe,
        capital: 0.0,
        diasAtraso: 0, 
        beneficios: null
      );
      
      var objeto = listaRenovacion.where((r)=>r.creditoID == f.idSolicitud);
      if(objeto.isEmpty){ 
        listaRenovacion.add(renovacion);
        listaRenEnviar.add(renovacion);
        inputs.add(true);
      }
    });
    print("object"); 
  }

  getSuma(){
    integrantes = 0;
    importe = 0.0;
    listaRenEnviar.forEach((f){ 
      if(f != null){
        integrantes += 1;
        importe += f.importe;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grupoInfo.nombre),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.person_add), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Solicitud(title: "Grupo Renovación: "+ widget.grupoInfo.nombre, colorTema: widget.colorTema, grupoId: widget.grupoInfo.grupoID, grupoNombre: widget.grupoInfo.nombre, actualizaHome: ()=>actualizaRenovacion(), esRenovacion: true,)));
          })
        ],
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: ()async{
          await Future.delayed(Duration(seconds:1));
        },
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.green[100], Colors.white])
              ),
            ),
            Column(children: <Widget>[
              ResponsiveContainer(
                heightPercent: 30.0,
                widthPercent: 100.0,
                child: Container(decoration: BoxDecoration(
                    gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [widget.colorTema[300], widget.colorTema[900]])
                  ), child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center ,children: <Widget>[Icon(Icons.group,color: Colors.white60, size: isLandscape ? 50.0 : 150.0), Text("INTEGRANTES: "+integrantes.toString()+"\nIMPORTE: "+importe.toStringAsFixed(2), style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),)]),
                )),
              ),
              Padding(padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0), child:SizedBox(width: double.infinity, child: RaisedButton(
                onPressed: ()async{ },
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("SOLICITAR RENOVACIÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),]),
                color: widget.colorTema,
              ))),
              listaRenovacion.length > 0 ? Expanded(child: renovacionLista()) : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema)))),
            ])
          ]
        )
      ),
    );
  }

  Widget renovacionLista(){
    return ListView.builder(
      itemCount: listaRenovacion.length,
      itemBuilder: (context, index){
        return InkWell(
          child: Card(
            child: Container(
              child: ListTile(
                title: Text(listaRenovacion[index].nombre),
                subtitle: subtitleLista(listaRenovacion[index]),
                trailing: listaRenovacion[index].clienteID == null ? IconButton(icon: Icon(Icons.fiber_new), onPressed: (){}) : listaRenEnviar[index] == null ? IconButton(icon: Icon(Icons.close), onPressed: (){}) : IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: ()async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) =>  RenovacionMonto(renovacion: listaRenovacion[index], colorTema: widget.colorTema, index: index, montoChange: montoChange)));
                },),
                leading: Checkbox(
                  value: inputs[index],
                  onChanged: (bool val){
                    itemChange(val, index);
                  },
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [widget.colorTema[400], Colors.white])
              ),
            )
          )
        );
      }
    );
  }

  Widget subtitleLista(Renovacion renovacion){
    if(renovacion.beneficios != null){
      return Row(children: <Widget>[Text("IMPORTE: "+renovacion.importe.toString(), style: TextStyle(fontWeight: FontWeight.bold)), renovacion.beneficios == null ? null : Text("   CONFIASHOP: "+renovacion.beneficios[0]['cveBeneficio'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))]) ;
    }else{
      return Text("IMPORTE: "+renovacion.importe.toString(), style: TextStyle(fontWeight: FontWeight.bold));
    }
  } 

  void itemChange(bool val,int index){
    setState(() {
      inputs[index] = val;
      if(val){
        listaRenEnviar[index] = listaRenovacion[index];
      }else{
        listaRenEnviar[index] = null;
      }
      getSuma();
    });
  }

  montoChange(int index, double monto){
    listaRenEnviar[index].importe = monto;
    getSuma();
  }

  void actualizaRenovacion()async{
    await getListNewDocumentos();
    await getSuma();
    setState(() {});
  }
}