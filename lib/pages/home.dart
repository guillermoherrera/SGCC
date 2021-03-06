import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mime_type/mime_type.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/classes/sincroniza.dart';
import 'package:sgcartera_app/components/custom_drawer.dart';
import 'package:sgcartera_app/components/drawer_component.dart';
import 'package:sgcartera_app/models/auth_res.dart';
import 'package:sgcartera_app/models/direccion.dart';
import 'package:sgcartera_app/models/documento.dart';
import 'package:sgcartera_app/models/grupo.dart';
import 'package:sgcartera_app/models/persona.dart';
import 'package:sgcartera_app/models/solicitud.dart';
import 'package:sgcartera_app/pages/confia_shop.dart';
import 'package:sgcartera_app/pages/grupos.dart';
import 'package:sgcartera_app/pages/lista_solicitudes.dart';
import 'package:sgcartera_app/pages/renovaciones.dart';
import 'package:sgcartera_app/pages/root_page.dart';
import 'package:sgcartera_app/pages/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/grupo.dart' as grupoModel;
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/models/renovaciones.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart' as solicitudModel;
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_renovacion.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import 'cartera.dart';
import 'mis_solicitudes.dart';
import 'nuevas_solicitudes.dart';

class HomePage extends StatefulWidget {
  HomePage({this.onSingIn, this.colorTema});
  final VoidCallback onSingIn;
  final Color colorTema;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<solicitudModel.Solicitud> solicitudes = List();
  AuthFirebase authFirebase = new AuthFirebase();
  Firestore _firestore = Firestore.instance;
  Sincroniza sincroniza = new Sincroniza();
  bool sincManual = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int userType;
  int cantSolicitudesCambios = 0;
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  bool abs = false;
  List<solicitudModel.Solicitud> ultimos = List();
  List<Renovacion> renovaciones = List();
  List<String> nombres = ["Carlos", "Pedro", "Maria"];
  List<String> apellidos = ["Herrera", "Lopez", "Morales"];
  //List<String> personas = List();
  Random rnd = new Random();
  String mensaje = "Bienvenido a Asesores App.";// \n\n * Aún No tienes registros de nuevas solicitudes de crédito en este dispositivo. \n\n * Puedes ir al apartado de 'Solicitudes' para comenzar a registrar y/o revisar nuevas solicitudes de crédito. \n\n * En el apartado de 'Cartera' puedes revisar el detalle de tu cartera. \n\n * Puedes revisar en 'Renovación' los grupos con fechas próximas a terminar para organizar tus renovaciones.";
  String mensaje2 = "Puedes comenzar a capturar nuevas solicitudes de crédito grupal o revisar la información de los grupos con los que ya estas trabajando, solo ve a la barra de navegación inferior y selecciona la opción que necesites.";
  bool changePass = false;

  Future<void> getListDocumentos() async{
    final pref = await SharedPreferences.getInstance();
    String userID = pref.getString("uid");
    userType = pref.getInt('tipoUsuario');
    userType == null ? _cerrarSesion(pref) : null;
    solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudes(userID);

    cantSolicitudesCambios = await ServiceRepositorySolicitudes.solicitudesCambioCount(userID);

    renovaciones = await ServiceRepositoryRenovaciones.getAllRenovaciones(userID);
    for(final ren in renovaciones){
      solicitudes.add(solicitudModel.Solicitud(nombreGrupo: ren.nombreGrupo, idGrupo: ren.idGrupo));
    }
    print("******** "+this.mounted.toString()+"**********");

    ultimos = await ServiceRepositorySolicitudes.getLastSolicitudes(userID);
    for(int i=0; i<ultimos.length; i++){
      Grupo grupo;
      grupo = await ServiceRepositoryGrupos.getOneGrupo(ultimos[i].idGrupo);
      if(grupo != null && grupo.status == 0){
        ultimos[i].status = 12;//en captura nueva solicitud
        ultimos[i].apellidoSegundo = ultimos[i].apellidoSegundo;
      }else if(grupo == null && ultimos[i].fechaCaptura != null){
        ultimos[i].status = 13;//en captura nueva solicitud en Renovacion
      }else if(ultimos[i].fechaCaptura == null){
        List<DocumentoSolicitud> documentosActualizados = await ServiceRepositoryDocumentosSolicitud.getAllDocumentosSolcitud(ultimos[i].idSolicitud);
        int cambio = documentosActualizados.where((f)=>f.cambioDoc == 1).length;
        if(cambio > 0){
          ultimos[i].status = 6;
          solicitudes.add(solicitudModel.Solicitud());
        }
      }
      ultimos[i].apellidoSegundo = ultimos[i].apellidoSegundo+(grupo != null ? " | "+grupo.nombreGrupo : " | "+ultimos[i].nombreGrupo);
    }

    print("ultimos "+ultimos.length.toString());
    changePass = pref.getBool("passGenerico");
    if(changePass == null){changePass = false;}
    
    try{ setState(() {}); }catch(e){ print("ERROR: linea 49 Home:"+e.toString()); }
  }

  void _moveToSignInScreen(BuildContext context) =>
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> HomePage(colorTema: widget.colorTema, onSingIn: widget.onSingIn,) ));

  @override
  void initState() {
    getListDocumentos();  
    sincronizarInfo();
    super.initState();
  }

  sincronizarInfo()async{
    /*sincManual = false;
    await sincroniza.sincronizaDatos();
    actualizaInfo();
    sincManual = true;
    print("Sincronización Realizada: "+DateTime.now().toString());*/
    const oneSec = const Duration(seconds:600);
    new Timer.periodic(oneSec, (Timer t)async{
      if(this.mounted){
        if(!abs){
          sincManual = false;
          await sincroniza.sincronizaDatos();
          actualizaInfo();
          sincManual = true;
          print("Sincronización Programada Realizada: "+DateTime.now().toString());
        }
      }else{
        t.cancel();
      }
    });
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 1:
        //if(sincManual){
          Navigator.push(context, MyCustomRoute(builder: (_) => MisSolicitudes(colorTema: widget.colorTema, actualizaHome: ()=>actualizaInfo(), cambio: cantSolicitudesCambios)));
          //Navigator.push(context, MaterialPageRoute(builder: (context)=> MisSolicitudes(colorTema: widget.colorTema, actualizaHome: ()=>actualizaInfo(), cambio: cantSolicitudesCambios)));
        //}else{
          //showSnackBar("Atención: El proceso de sincronizaición esta en curso, por favor espera un momento.", Colors.red);
        //}
      break;
      case 2:
        Navigator.push(context, MyCustomRoute(builder: (_) => Cartera(colorTema: widget.colorTema,actualizaHome: ()=>actualizaInfo(), cambio: cantSolicitudesCambios)));
        //Navigator.push(context, MaterialPageRoute(builder: (context)=> Cartera(colorTema: widget.colorTema,actualizaHome: ()=>actualizaInfo(), cambio: cantSolicitudesCambios)));
      break;
      case 3:
        Navigator.push(context, MyCustomRoute(builder: (_) => Renovaciones(colorTema: widget.colorTema,actualizaHome: ()=>actualizaInfo(), cambio: cantSolicitudesCambios)));
        //Navigator.push(context, MaterialPageRoute(builder: (context)=> Renovaciones(colorTema: widget.colorTema,actualizaHome: ()=>actualizaInfo(), cambio: cantSolicitudesCambios))); 
      break;
      default:
    }
  }

  _cerrarSesion(pref){
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
                Icon(Icons.block, color: Colors.red, size: 100.0,),
                Text("\nTU SESIÓN HA EXPIRADO"),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text("INICIAR SESIÓN"),
                onPressed: () async {
                  authFirebase.signOut();
                  pref.clear();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootPage(authFirebase: authFirebase, colorTema: widget.colorTema,)));
                }
              )
            ],
          )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){return new Future(() => false);},
      child: AbsorbPointer(absorbing: abs ,child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Image.asset('images/adminconfia.png', color: Colors.white, fit: BoxFit.cover, height: 50.0),
          centerTitle: true,
          elevation: 0.0,
          leading: Container(),/*new IconButton(/*icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState.openDrawer()),*/
                icon: changePass ? Stack(children: <Widget>[
                        Icon(Icons.menu, color: Colors.white),
                        Positioned(
                            bottom: -5.0,
                            left: 8.0,
                            child: new Center(
                              child: new Text(
                                ".",
                                style: new TextStyle(
                                    color: Colors.yellow[900],
                                    fontSize: 90.0,
                                    fontWeight: FontWeight.w500

                                ),
                              ),
                            )),
                          ],
                        ) : Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState.openDrawer()),*/
          actions: <Widget>[
            new IconButton(
                icon: changePass ? Stack(children: <Widget>[
                  Icon(Icons.account_circle, color: Colors.white, size: 30.0),
                  Positioned(
                      bottom: -17.0,
                      left: -5.0,
                      child: new Center(
                        child: new Text(
                          ".",
                          style: new TextStyle(
                              color: Colors.yellow[900],
                              fontSize: 90.0,
                              fontWeight: FontWeight.w500

                          ),
                        ),
                      )),
                    ],
                  ) : Icon(Icons.account_circle, color: Colors.white, size: 30.0),
                onPressed: () => _scaffoldKey.currentState.openDrawer())
            //IconButton(icon: Icon(Icons.person_add, color: Colors.white), onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => NuevasSolicitudes(colorTema: widget.colorTema,actualizaHome: ()=>actualizaInfo()) ));},)
          ],
        ),
        drawer: DrawerComponent(authFirebase: AuthFirebase(),onSingIn: widget.onSingIn, colorTema: widget.colorTema, actualizaHome: ()=>actualizaInfo(), changePass: changePass, sincManual: sincManual ),
        //drawer: CustomDrawer(authFirebase: AuthFirebase(),onSingIn: widget.onSingIn, colorTema: widget.colorTema, actualizaHome: ()=>actualizaInfo(), changePass: changePass, sincManual: sincManual ),
        body: userType == null ? Container() : userType == 0 ? Container(child: Center(child:SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[Image.asset("images/page_not_found.png"), Padding(padding: EdgeInsets.all(50), child:Text("Usuario no encontrado.\n\nTu usuario no esta asignado, ponte en contacto con soporte para mas información.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))]))),color: Colors.white,) : RefreshIndicator(
            key: refreshKey,
            onRefresh: ()async{
              try {
                final result = await InternetAddress.lookup('google.com');
                if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                  setState(() {abs = true;});
                  await Future.delayed(Duration(seconds:1));
                  if(sincManual){
                    //sincManual = false;
                    await sincroniza.sincronizaDatos();
                    actualizaInfo();
                    //sincManual = true;
                    print("Sincronización Manual Realizada: "+DateTime.now().toString());
                  }else{
                    showSnackBar("Atención: El proceso de sincronizaición esta en curso, por favor espera un momento.", Colors.red);
                  }
                  setState(() {abs = false;});
                }
              } on SocketException catch (_) {
                print('not connected');
                mostrarShowDialog(false);
              }
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
                Column(
                children: <Widget>[
                  InkWell(
                    child: Card(
                      elevation: 0.0,
                      child: Container(
                        child: ListTile(
                        leading: getIcono(),
                        title: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(getMensaje(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white))),
                        subtitle: SingleChildScrollView(scrollDirection: Axis.horizontal, child: getLeyenda()),
                        trailing: getAcciones(),
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
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(13, 16, 13, 3),
                        child: ultimos.length > 0 ? Stack(children:<Widget>[Center(child:Opacity(opacity: 0, child: Image.asset("images/analysis.png"))),listaOpciones()]) : Center(child: ListView.builder(shrinkWrap: true,itemCount: 1,itemBuilder:(context, index){ return Container(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[Image.asset("images/analysis.png"),Padding(padding: EdgeInsets.all(20), child:Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))),Padding(padding: EdgeInsets.all(20), child:Text(mensaje2, style: TextStyle(fontSize: 15)))])),color: Colors.white,);})),
                      ),
                    )
                  )),
                ],
              )
            ]
          )
        ),
        bottomNavigationBar: Stack(
          children: <Widget>[
            Row(
              children:<Widget>[
                Expanded(child:Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xff1a9cff),)),
                Expanded(child: Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xffffffff),)),
                Expanded(child: Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xffffffff),)),
                Expanded(child: Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xffffffff),))
              ]
            ),
            Container(margin: EdgeInsets.only(top:3),child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text('Inicio'),
                ),
                BottomNavigationBarItem(
                  icon: cantSolicitudesCambios > 0 ? Stack(children: <Widget>[
                    Icon(Icons.monetization_on),
                    Positioned(
                        bottom: -5.0,
                        left: 8.0,
                        child: new Center(
                          child: new Text(
                            ".",
                            style: new TextStyle(
                                color: Colors.red,
                                fontSize: 90.0,
                                fontWeight: FontWeight.w500

                            ),
                          ),
                        )),
                      ],
                    ) : Icon(Icons.monetization_on),
                  title: Text('Solicitudes'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet),
                  title: Text('Cartera'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.cached),
                  title: Text('Renovación'),
                ),
              ],
              currentIndex: 0,
              selectedItemColor: Color(0xff1a9cff),
              backgroundColor: Color(0xffffffff),
              unselectedItemColor: Color(0xffa9a9a9),
              onTap: _onItemTapped,
            ))
          ]
        )
      ))
    );
  }

  Widget listaOpciones(){
    int itemLoop = ultimos.length + 1;
    return ListView.builder(
      itemCount: itemLoop,
      itemBuilder: (context, index){
        return index == 0 ? Container(child:Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.watch_later, color: Colors.grey, size: 20,),
              Text(" ÚLTIMOS REGISTROS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Icon(Icons.phone_iphone, color: Colors.grey,),
            ],
          ), margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0)) : InkWell(
          onTap: (){},
          child: Opacity(opacity: 0.8, child: Card(
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
              child: ListTile(
                leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Icon(Icons.person, color: widget.colorTema, size: 40)]),
                title: Text(nombreCompleto(ultimos[index -1]), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text(resumen(ultimos[index-1])),
                isThreeLine: true,
                trailing:  Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("Estatus", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),Text(ultimos[index-1].status == 12 ? "En captura" : ultimos[index-1].status == 13 ? "En Captura\nRenovación" : ultimos[index-1].status == 0 || ultimos[index-1].status == 6 ? "En espera" : "Sincronizado", style: TextStyle(color: ultimos[index-1].status == 12 ? Colors.black : ultimos[index-1].status == 13 ? Colors.black : ultimos[index-1].status == 0 || ultimos[index-1].status == 6 ? Colors.yellow[700] : widget.colorTema, fontWeight: FontWeight.bold))])
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, Colors.white])
              ),
            ),
          ))
        );
      },
    );
  }

  String nombreCompleto(solicitudModel.Solicitud obj){
    return obj.nombrePrimero + " " + obj.nombreSegundo + " " + obj.apellidoPrimero + " " + obj.apellidoSegundo;
  }

  String resumen(solicitudModel.Solicitud obj){
    //DateTime.fromMillisecondsSinceEpoch(ultimos[index-1].fechaCaptura).toString()+"\nIMPORTE: \$"+ultimos[index-1].importe.toStringAsFixed(2)
    String fecha = obj.fechaCaptura == null ? "Cambio de Documento" : formatDate(DateTime.fromMillisecondsSinceEpoch(obj.fechaCaptura), [dd, '/', mm, '/', yyyy, ' ', HH, ':', nn]);
    return fecha+"\nIMPORTE: \$"+obj.importe.toStringAsFixed(2);
  }

  String getMensaje(){
    String mensaje = "";
    if(solicitudes.length > 0){
      List<String> solicitudesGrupos = List();
      List<String> solicitudesIndividuales = List();
      for(final solicitud in solicitudes){
        if(!solicitudesGrupos.contains(solicitud.nombreGrupo)){
          if(solicitud.idGrupo != null){
            solicitudesGrupos.add(solicitud.nombreGrupo);
          }else{
            solicitudesIndividuales.add(solicitud.nombreGrupo);
          }
        }
      }
      mensaje = "\nEN ESPERA POR SINCRONIZAR: "+(solicitudesGrupos.length+solicitudesIndividuales.length).toString();
    }else{
      mensaje = "\nSIN SOLICITUDES POR SINCRONIZAR.";
    }
    return mensaje;
  }

  Icon getIcono(){
    if(solicitudes.length > 0)
      return Icon(Icons.error_outline, color: Colors.redAccent ,size: 40.0,);
    else 
      return Icon(Icons.check_circle, color: Colors.white ,size: 40.0,);
  }

  Widget getLeyenda(){
    if(solicitudes.length > 0)
      return Row(children: <Widget>[
        Text("Desliza hacia abajo", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
        Icon(Icons.refresh, size: 15.0, color: Colors.white), 
        Text(".", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))
      ],);
    else 
      return Text("Sin solicitudes de crédito en espera.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70));
  }

  Widget getAcciones(){
    return null;/*solicitudes.length > 0 ? PopupMenuButton(
      itemBuilder: (_) => <PopupMenuItem<int>>[
        new PopupMenuItem<int>(
            child: Row(children: <Widget>[Icon(Icons.cached, color: Colors.green,),Text(" Sincronizar")],), value: 1),
        new PopupMenuItem<int>(
            child: Row(children: <Widget>[Icon(Icons.list, color: Colors.blue),Text(" Ver Solicitudes")],), value: 2),
      ],
      onSelected: (value){
        if(value == 1){
          if(sincManual){
            showDialogo();
          }else{
            showSnackBar("Atención: El proceso de sincronizaición esta en curso, por favor espera un momento.", Colors.red);
          }
        }
        else if(value == 2){
          if(sincManual){
            Navigator.push(context, MaterialPageRoute(builder: (context) => ListaSolicitudes(colorTema: widget.colorTema,title: "En Espera (no sincronizadas)",status: 0,actualizaHome: ()=>actualizaInfo() )));
          }else{
            showSnackBar("Atención: El proceso de sincronizaición esta en curso, por favor espera un momento.", Colors.red);
          }
        }
      }
    ) : null;//Icon(Icons.check_circle, color: Colors.blue ,size: 40.0,);*/
  }

  showDialogo() async{
    final pref = await SharedPreferences.getInstance();
    var _email = pref.getString("email");
    var _pass = pref.getString("pass");
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        mostrarShowDialog(true);
        var authRes = await authFirebase.signIn(_email, _pass);//poner aqui datos reales cuenta
        print('connected');
        if(authRes.result){
          await sincronizarDatos().then((_){
            Navigator.pop(context);
          });
        }else{
          Navigator.pop(context);
          mostrarShowDialog(false);
        }
      }
    } on SocketException catch (_) {
      print('not connected');
      mostrarShowDialog(false);
    }
    /*new Future.delayed(new Duration(seconds: 3), () {
      Navigator.pop(context); //pop dialog
    });*/
  }

  mostrarShowDialog(bool conectado){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: (){},
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                conectado ? CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(widget.colorTema)) : Icon(Icons.error, color: Colors.red, size: 100.0,),
                conectado ? Text("\nSINCRONIZANDO ...") : Text("\nSIN CONEXIÓN"),
              ],
            ),
            actions: <Widget>[
              !conectado ?
              new FlatButton(
                child: const Text("CERRAR"),
                onPressed: (){Navigator.pop(context);}
              ) : null
            ],
          )
        );
      },
    );
  }

  sincronizarDatos() async{
    //List<File> documentos;
    final pref = await SharedPreferences.getInstance();
    pref.setBool("Sinc", false);
    pref.setString("fechaSinc", formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy, " ", HH, ':', nn, ':', ss]));
    String userID = pref.getString("uid");
    List<String> gruposSinc = List();
    List<GrupoObj> gruposGuardados = List();
    List<Map> documentos;
    Persona persona;
    Direccion direccion;
    for(final solicitud in solicitudes){

      persona = new Persona(
        nombre: solicitud.nombrePrimero,
        nombreSegundo: solicitud.nombreSegundo,
        apellido: solicitud.apellidoPrimero,
        apellidoSegundo: solicitud.apellidoSegundo,
        curp: solicitud.curp,
        rfc: solicitud.rfc,
        fechaNacimiento: DateTime.fromMillisecondsSinceEpoch(solicitud.fechaNacimiento).toUtc(),
        telefono: solicitud.telefono
      );

      direccion = new Direccion(
        ciudad: solicitud.ciudad,
        coloniaPoblacion: solicitud.coloniaPoblacion,
        cp: solicitud.cp,
        delegacionMunicipio: solicitud.delegacionMunicipio,
        direccion1: solicitud.direccion1,
        estado: solicitud.estado,
        pais: solicitud.pais
      );
      
      documentos = [];
      await ServiceRepositoryDocumentosSolicitud.getAllDocumentosSolcitud(solicitud.idSolicitud).then((listaDocs){
        for(final doc in listaDocs){
          Documento documento = new Documento(tipo: doc.tipo, documento: doc.documento, version: doc.version);
          //documentos.add(documento.toJson());
          Map docMap = documento.toJson();
          docMap.removeWhere((key, value) => key == "idDocumentoSolicitud");
          docMap.removeWhere((key, value) => key == "observacionCambio");
          documentos.add(docMap);
        }
      });

      await saveFireStore(documentos).then((lista) async{
        if(lista.length > 0){
          
          GrupoObj grupoObj = new GrupoObj();
          if(solicitud.idGrupo != null && !gruposSinc.contains(solicitud.nombreGrupo)){
            grupoModel.Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(solicitud.idGrupo);
            grupoObj = new GrupoObj(nombre: solicitud.nombreGrupo, status: 2, userID: solicitud.userID, importe: grupo.importe, integrantes: grupo.cantidad);
            if(grupo.grupoID == null || grupo.grupoID == "null"){
              Map grupoFirebase = grupoObj.toJson();
              grupoFirebase.removeWhere((key, value)=>key=='grupo_id');
              var result = await _firestore.collection("Grupos").add(grupoFirebase);
              await ServiceRepositoryGrupos.updateGrupoStatus(2, result.documentID, solicitud.idGrupo);
              grupoObj.grupoID = result.documentID;
            }else{
              grupoObj.grupoID = grupo.grupoID;
            }
            gruposSinc.add(grupoObj.nombre);
            gruposGuardados.add(grupoObj);
          }else if(solicitud.idGrupo != null && gruposSinc.contains(solicitud.nombreGrupo)){
            grupoObj.grupoID = gruposGuardados.firstWhere((grupo)=> grupo.nombre == solicitud.nombreGrupo).grupoID;
          }

          SolicitudObj solicitudObj = new SolicitudObj(
            persona: persona.toJson(),
            direccion: direccion.toJson(),
            importe: solicitud.importe,
            tipoContrato: solicitud.tipoContrato,
            userID: solicitud.userID,
            status: 1,
            grupoID: solicitud.idGrupo == null ? null : grupoObj.grupoID,
            grupoNombre: solicitud.idGrupo == null ? null : solicitud.nombreGrupo 
          );

          solicitudObj.documentos = lista;   
          solicitudObj.fechaCaputra = DateTime.now();
          Map solicitudFirebase = solicitudObj.toJson();
          solicitudFirebase.removeWhere((key, value)=>key=='grupo_Id');
          var result = await _firestore.collection("Solicitudes").add(solicitudFirebase);
          await ServiceRepositorySolicitudes.updateSolicitudStatus(1, solicitud.idSolicitud);
          //if(solicitudObj.grupoId != null) ServiceRepositoryGrupos.updateGrupoStatus(2, grupoObj.grupoID, solicitudObj.grupoId);
          print(result);
          //getListDocumentos();
        }else{
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error, color: Colors.red, size: 100.0,),
                    Text("\nSIN CONEXIÓN"),
                  ],
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: const Text("CERRAR"),
                    onPressed: (){Navigator.pop(context);}
                  )
                ],
              );
            },
          );
        }
      });
    }
    ///Consulta Cambios de Documentos
    await  sincroniza.getCambios(userID, "Solicitudes");
    await  sincroniza.getCambios(userID, "Renovaciones");
    //Sincroniza Cambios de Documentos
    await sincroniza.sincCambios();
    pref.setBool("Sinc", true);
    pref.setString("fechaSinc", formatDate(DateTime.now(), [dd, '/', mm, '/', yyyy, " ", HH, ':', nn, ':', ss]));
    actualizaInfo();
  }

  Future<List<Map>> saveFireStore(listaDocs) async{
    FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
    try{
      for(var doc in listaDocs){
        String mimeType = mime(path.basename(doc['documento']));
        String ext = "."+mimeType.split("/")[1];
        StorageReference reference = _firebaseStorage.ref().child('Documentos').child(DateTime.now().millisecondsSinceEpoch.toString()+"_"+doc['tipo'].toString()+ext);
        StorageUploadTask uploadTask = reference.putFile(File(doc['documento']));
        StorageTaskSnapshot downloadUrl = await uploadTask.onComplete.timeout(Duration(seconds: 10));
        doc['documento'] = await downloadUrl.ref.getDownloadURL();
      }
    }catch(e){
      listaDocs = [];
    }
    
    return listaDocs;
  }

  showSnackBar(String texto, MaterialColor color){
    final snackBar = SnackBar(
      content: Text(texto, style: TextStyle(fontWeight: FontWeight.bold),),
      backgroundColor: color[300],
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void actualizaInfo(){
    getListDocumentos();
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    //if (settings.isInitialRoute)
      //return child;
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return new FadeTransition(opacity: animation, child: child);
  }
}