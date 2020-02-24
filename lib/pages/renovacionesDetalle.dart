import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:sgcartera_app/models/grupo_renovacion.dart';
import 'package:sgcartera_app/models/renovacion.dart';
import 'package:sgcartera_app/pages/renovacionesMonto.dart';
import 'package:sgcartera_app/pages/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/renovaciones.dart' as SqliteRenovaciones;
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart' as SolicitudModel;
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_catIntegrantes.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_renovacion.dart'; 
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RenovacionesDetalle extends StatefulWidget {
  RenovacionesDetalle({this.colorTema, this.grupoInfo, this.actualizaHome});
  final Color colorTema;
  final GrupoRenovacion grupoInfo;
  final VoidCallback actualizaHome;
  @override
  _RenovacionesDetalleState createState() => _RenovacionesDetalleState();
}

class _RenovacionesDetalleState extends State<RenovacionesDetalle> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<RenovacionObj> listaRenovacion = List();
  List<RenovacionObj> listaRenEnviar = List();
  List<SqliteRenovaciones.Renovacion> listaRenEspera = List();
  List<SolicitudModel.Solicitud> solicitudes = List(); 
  String mensaje = "Cargando ...🕔";
  int integrantes = 0;
  double importe = 0.0;
  List<bool> inputs = new List<bool>();
  bool solicitable = true;
  String userID;
  Firestore _firestore = Firestore.instance;

  @override
  void initState() {
    getListDocumentos();
    super.initState();
  }

  getListDocumentos()async{
    final pref = await SharedPreferences.getInstance();
    userID = pref.getString("uid");
    await Future.delayed(Duration(seconds:1));
    listaRenEspera = await ServiceRepositoryRenovaciones.getRenovacionesFromGrupo(widget.grupoInfo.grupoID);
    if(listaRenEspera.length > 0){
      solicitable = false;
      listaRenovacion.clear();
      listaRenEnviar.clear();
      listaRenEspera.forEach((f){
        RenovacionObj renovacion = new RenovacionObj(
          creditoID: f.creditoID, 
          clienteID: f.clienteID,
          nombre: f.nombreCompleto,
          importe: f.nuevoImporte,
          capital: f.capital,
          diasAtraso: f.diasAtraso, 
          beneficios: f.beneficio == "null" ? null : [{"cveBeneficio":f.beneficio}],
          importeHistorico: f.importe
        );
        listaRenovacion.add(renovacion);
        listaRenEnviar.add(renovacion);
      });
      await getSuma();
    }else{
      Query q;
      QuerySnapshot querySnapshot;
      q = _firestore.collection("GruposRenovacion").where('grupo_id', isEqualTo: widget.grupoInfo.grupoID);
      try{
        querySnapshot = await q.getDocuments().timeout(Duration(seconds: 10));
      }catch(e){
        solicitable = false;
        mensaje = "Revisa tu conexión.";
      }
      if(querySnapshot.documents.length > 0){
        importe = querySnapshot.documents[0].data['importe'];
        integrantes = querySnapshot.documents[0].data['integrantes'];
        mensaje = "Renovacion solicitada previamente";
        solicitable = false;
      }else{
        listaRenovacion.clear();
        inputs.clear();
        for(var i = 0; i <= 5; i++){
          List<String> nombres = ["MARIA TORRES", "PATRICIA SOSA", "LUCIA MORALES", "ANA PEREZ", "LUISA ZAPATA", "MARIA PEREZ"];
          RenovacionObj renovacion = new RenovacionObj(
            creditoID: 100+i, 
            clienteID: 1000+i,
            nombre: nombres[i],
            importe: 1000.0 + (i*500),
            capital: 100.0 + (i*500),
            diasAtraso: i, 
            beneficios: i%2 == 0 ? [{"cveBeneficio":"A"}] : null,
            importeHistorico: 1000.0+(i*500)
          );
          listaRenovacion.add(renovacion);
          listaRenEnviar.add(renovacion);
          inputs.add(true);
        }
        await getListNewDocumentos();
        await getSuma();
      }
    }
    setState(() {});
  }

  Future<void> getListNewDocumentos() async{
    solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudesGrupo(userID, widget.grupoInfo.nombre);
    solicitudes.forEach((f){
      RenovacionObj renovacion = new RenovacionObj(
        creditoID: f.idSolicitud, 
        clienteID: null,
        nombre: f.nombrePrimero + " " + f.nombreSegundo + " " + f.apellidoPrimero + " " + f.apellidoSegundo ,
        importe: f.importe,
        capital: 0.0,
        diasAtraso: 0, 
        beneficios: null,
        importeHistorico: f.importe,
      );
      
      var objeto = listaRenovacion.where((r)=>r.creditoID == f.idSolicitud);
      if(objeto.isEmpty){ 
        listaRenovacion.add(renovacion);
        listaRenEnviar.add(renovacion);
        inputs.add(true);
      }
    });
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
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.grupoInfo.nombre, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        actions: listaRenovacion.length == 0 ? null : solicitable ? <Widget>[
          /*IconButton(icon: Icon(Icons.person_add), onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Solicitud(title: "Grupo Renovación: "+ widget.grupoInfo.nombre, colorTema: widget.colorTema, grupoId: widget.grupoInfo.grupoID, grupoNombre: widget.grupoInfo.nombre, actualizaHome: ()=>actualizaRenovacion(), esRenovacion: true,)));
          })*/
        ] : null,
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
                colors: [widget.colorTema, widget.colorTema])
              ),
            ),
            Column(children: <Widget>[
              InkWell(
                child: Card(
                  elevation: 0.0,
                  child: Container(
                    child: ListTile(
                    leading: Icon(Icons.group,color: Colors.white, size: 40.0,),
                    title: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text("\nINTEGRANTES: "+integrantes.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white))),
                    subtitle: Text("IMPORTE: "+importe.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
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
                    padding: EdgeInsets.fromLTRB(13, 13, 13, 3),
                    child: listaRenovacion.length > 0 ?  renovacionLista() : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)))),
                  ),
                )
              )),
              /*ResponsiveContainer(
                heightPercent: 30.0,
                widthPercent: 100.0,
                child: Container(decoration: BoxDecoration(
                    gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [widget.colorTema, widget.colorTema])
                  ), child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center ,children: <Widget>[Icon(Icons.group,color: Colors.white60, size: isLandscape ? 50.0 : 150.0), Text("INTEGRANTES: "+integrantes.toString()+"\nIMPORTE: "+importe.toStringAsFixed(2), style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),)]),
                )),
              ),
              listaRenovacion.length == 0 ? Container() :  solicitable ? Padding(padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0), child:SizedBox(width: double.infinity, child: RaisedButton(
                onPressed: ()async{
                  await solicitarRenovacion();
                },
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("SOLICITAR RENOVACIÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),]),
                color: widget.colorTema,
              ))) : Padding(padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0), child:SizedBox(width: double.infinity, child: RaisedButton(
                onPressed: ()async{},
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("RENOVACIÓN SOLICITADA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),]),
                color: Colors.blue,
              ))),
              listaRenovacion.length > 0 ? Expanded(child: renovacionLista()) : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema)))),*/
            ])
          ]
        )
      ),
      floatingActionButton: listaRenovacion.length == 0 ? null : solicitable ? FloatingActionButton(child: Icon(Icons.person_add, color: Colors.white), backgroundColor: widget.colorTema,onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Solicitud(title: "Grupo Renovación: "+ widget.grupoInfo.nombre, colorTema: widget.colorTema, grupoId: widget.grupoInfo.grupoID, grupoNombre: widget.grupoInfo.nombre, actualizaHome: ()=>actualizaRenovacion(), esRenovacion: true,)));}) : null,
      bottomNavigationBar: InkWell(
        child:  Container(
            child: listaRenovacion.length == 0 ? Padding(padding: EdgeInsets.all(0)) :  solicitable ? Padding(padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0), child:SizedBox(width: double.infinity, child: RaisedButton(
              onPressed: ()async{
                await solicitarRenovacion();
              },
              //child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("SOLICITAR RENOVACIÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),]),
              color: Color(0xff1A9CFF),
              textColor: Colors.white,
              padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
              elevation: 0.0,
              child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.arrow_forward),Text("SOLICITAR RENOVACIÓN", style: TextStyle(fontSize: 20),)]),
            ))) : Padding(padding: EdgeInsets.fromLTRB(0.0, 0, 0.0, 0), child:SizedBox(width: double.infinity, child: RaisedButton(
              onPressed: ()async{},
              //child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("RENOVACIÓN SOLICITADA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),]),
              color: widget.colorTema,
              textColor: Colors.white,
              padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
              elevation: 0.0,
              child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.check),Text("RENOVACIÓN SOLICITADA", style: TextStyle(fontSize: 20),)]),
            ))),
            //color: Color(0xff1A9CFF),
            decoration: BoxDecoration(
              border: Border(
                //top: BorderSide(width: 4.0, color: Colors.lightBlue.shade600),
                bottom: BorderSide(width: 4.0, color: widget.colorTema),
                left: BorderSide(width: 4.0, color: widget.colorTema),
                right: BorderSide(width: 4.0, color: widget.colorTema),
              ),
              color: Color(0xff1A9CFF),
            ),
          ),
        ),
    );
  }

  Widget renovacionLista(){
    return ListView.builder(
      itemCount: listaRenovacion.length,
      itemBuilder: (context, index){
        return InkWell(
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color:widget.colorTema, width:3.0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0),
                topRight: Radius.circular(50.0),
                bottomLeft: Radius.circular(50.0),
                bottomRight: Radius.circular(50.0)
              ),
            ),
            child: Container(
              child: ListTile(
                title: Text(listaRenovacion[index].nombre),
                subtitle: subtitleLista(listaRenovacion[index]),
                trailing: !solicitable ? null : listaRenovacion[index].clienteID == null ? IconButton(icon: Icon(Icons.fiber_new), onPressed: (){}) : listaRenEnviar[index] == null ? IconButton(icon: Icon(Icons.close), onPressed: (){}) : IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: ()async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) =>  RenovacionMonto(renovacion: listaRenovacion[index], colorTema: widget.colorTema, index: index, montoChange: montoChange)));
                },),
                leading: solicitable ? Checkbox(
                  //activeColor: widget.colorTema,
                  value: inputs[index],
                  onChanged: (bool val){
                    itemChange(val, index);
                  },
                ) : IconButton(icon: Icon(Icons.done), onPressed: (){}),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, Colors.white])
              ),
            )
          )
        );
      }
    );
  }

  Widget subtitleLista(RenovacionObj renovacion){
    if(renovacion.beneficios != null){
      return Row(children: <Widget>[Text("IMPORTE: "+renovacion.importe.toString()+"   ", style: TextStyle(fontWeight: FontWeight.bold)), renovacion.beneficios == null ? null : Flexible(fit: FlexFit.loose,child:Text("CONFIASHOP: "+renovacion.beneficios[0]['cveBeneficio'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),softWrap: false,overflow: TextOverflow.fade,))]) ;
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

  solicitarRenovacion()async{
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0)),
        title: Center(child: Text("Solicitar Renovación")),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.yellow, size: 100.0,),
                Text(".\n\n¿Desea solicitar la renovación del grupo "+widget.grupoInfo.nombre+"?"),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("No"),
                onPressed: (){Navigator.pop(context);}
              ),
              new FlatButton(
                child: const Text("Sí, solicitar Renovacion."),
                onPressed: ()async{
                  Navigator.pop(context);
                  var result = await RepositoryServiceCatIntegrantes.getAllCatIntegrantes();
                  int cantidad = result[0].cantidad;
                  if(integrantes >= cantidad){
                    setState(() {solicitable = false;});
                    if(await saveSqfliteRenovacion()){
                      await getListDocumentos();
                      showSnackBar("Renovación Solicitada", Colors.green);
                    }else{
                      setState(() {solicitable = true;});
                      showSnackBar("Error al guardar la renovación", Colors.red);
                    }
                  }else{
                    setState(() {solicitable = true;});
                    showSnackBar("No pudo solicitarse la renovación del grupo. Debe tener al menos "+cantidad.toString()+" integrantes", Colors.red);
                  }
                }
              )
            ],
      );
    });
  }

  Future<bool> saveSqfliteRenovacion() async{
    bool result = false;
    try{
      
      final Grupo grupo = new Grupo(
        idGrupo: widget.grupoInfo.grupoID ,
        nombreGrupo: widget.grupoInfo.nombre,
        status: 4,
        userID: userID,
        cantidad: integrantes,
        importe: importe
      );

      if(await ServiceRepositoryGrupos.validaGrupo(grupo)){
        await ServiceRepositoryGrupos.addGrupoRenovacion(grupo);
        int idRenov = await ServiceRepositoryRenovaciones.renovacionesCount();
        listaRenEnviar.forEach((f)async{
          if(f!=null){
            idRenov = idRenov + 1;
            final SqliteRenovaciones.Renovacion renovacion = new SqliteRenovaciones.Renovacion(
              idRenovacion: idRenov,
              idGrupo: widget.grupoInfo.grupoID,
              nombreGrupo: widget.grupoInfo.nombre,
              creditoID: f.creditoID,
              clienteID: f.clienteID == null ? null : f.clienteID,
              nombreCompleto: f.nombre,
              importe: f.importeHistorico,
              capital: f.capital,
              diasAtraso: f.diasAtraso,
              beneficio: f.beneficios == null ? null : f.beneficios[0]['cveBeneficio'],
              userID: userID,
              tipoContrato: 2,
              nuevoImporte: f.importe
            );

            await ServiceRepositoryRenovaciones.addRenovacion(renovacion);
          }
        });

        result = true;
      }      
    }catch(e){

    }
    return result;
  }

  showSnackBar(String texto, MaterialColor color){
    final snackBar = SnackBar(
      content: Text(texto, style: TextStyle(fontWeight: FontWeight.bold),),
      backgroundColor: color[300],
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
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