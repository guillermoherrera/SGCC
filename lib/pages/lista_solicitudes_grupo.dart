import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/components/fancy_fab.dart';
import 'package:sgcartera_app/pages/home.dart';
import 'package:sgcartera_app/pages/solicitud.dart' as SolicitudPage;
import 'package:sgcartera_app/pages/root_page.dart';
import 'package:sgcartera_app/pages/solicitud_editar.dart';
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/models/renovaciones.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_catIntegrantes.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_renovacion.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListaSolicitudesGrupo extends StatefulWidget {
  ListaSolicitudesGrupo({this.title, this.colorTema, this.actualizaHome, this.grupo});
  final Color colorTema;
  final String title;
  final VoidCallback actualizaHome;
  final Grupo grupo;
  
  @override
  _ListaSolicitudesGrupoState createState() => _ListaSolicitudesGrupoState();
}

class _ListaSolicitudesGrupoState extends State<ListaSolicitudesGrupo>  with SingleTickerProviderStateMixin  {
  List<Solicitud> solicitudes = List(); 
  List<Renovacion> solicitudesR = List();  
  AuthFirebase authFirebase = new AuthFirebase();
  bool status;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Grupo> gruposAbiertos = List();  
  int userType;

  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _animateColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  Future<void> getListDocumentos() async{
    status = widget.grupo.status == 0 ? true : false;
    final pref = await SharedPreferences.getInstance();
    String userID = pref.getString("uid");
    userType = pref.getInt('tipoUsuario');
    gruposAbiertos = await ServiceRepositoryGrupos.getAllGrupos(userID);
    solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudesGrupo(userID, widget.title);
    
    solicitudesR = await ServiceRepositoryRenovaciones.getRenovacionesFromGrupo(widget.grupo.idGrupo);
    for(Renovacion ren in solicitudesR){
      solicitudes.add(Solicitud(
        nombrePrimero: ren.nombreCompleto,
        nombreSegundo: "",
        apellidoPrimero: "",
        apellidoSegundo: "",
        importe: ren.nuevoImporte,
        telefono: "",
        status: 0));
    } 
    
    setState(() {});
  }

  @override
  void initState() {
    getListDocumentos();
    
     _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500))..addListener((){ setState(() {}); });
    _animateIcon = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _animateColor = ColorTween(begin: Color(0xff76BD21), end: Color(0xff76BD21)).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.00, 1.00, curve: Curves.linear)));
    _translateButton = Tween<double>(begin: _fabHeight, end: -14.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.0, 0.75, curve: _curve)));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate(){
    if(!isOpened){
      _animationController.forward();
    }else{
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget add(){
    return new Container(
      child: FloatingActionButton(
        heroTag: "btn3",
        onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => SolicitudPage.Solicitud(title: "Solicitud Grupal: "+widget.grupo.nombreGrupo, colorTema: widget.colorTema, grupoId: widget.grupo.idGrupo, grupoNombre: widget.grupo.nombreGrupo, actualizaHome: widget.actualizaHome)));},
        tooltip: 'Agregar Integrante',
        child: Icon(Icons.person_add),
        backgroundColor: Color(0xff76BD21),
      )
    );
  }

  Widget image(){
    return Container(
      child: FloatingActionButton(
        heroTag: "btn2",
        onPressed: (){cerrarGrupo(widget.grupo);},
        tooltip: 'Cerrar Grupo',
        child: Icon(Icons.lock),
        backgroundColor: Color(0xff76BD21),
      ),
    );
  }

  Widget toggle(){
    return Container(child: FloatingActionButton(
      heroTag: "btn1",
      backgroundColor: _animateColor.value,
      onPressed: animate,
      tooltip: 'Toggle',
      child: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _animateIcon),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //onWillPop: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootPage(authFirebase: authFirebase, colorTema: widget.colorTema,))),
      onWillPop: ()=> Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomePage(onSingIn: (){}, colorTema: widget.colorTema,)), (Route<dynamic> route) => false),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title, style: TextStyle(color: Colors.white)),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0.0,
          actions: <Widget>[]
          /*status ? <Widget>[
            IconButton(icon: Icon(Icons.lock), onPressed: () {
              cerrarGrupo(widget.grupo);
            },),
            IconButton(icon: Icon(Icons.person_add), onPressed: () {
              //cerrarGrupo(widget.grupo);
              Navigator.push(context, MaterialPageRoute(builder: (context) => SolicitudPage.Solicitud(title: "Solicitud Grupal: "+widget.grupo.nombreGrupo, colorTema: widget.colorTema, grupoId: widget.grupo.idGrupo, grupoNombre: widget.grupo.nombreGrupo, actualizaHome: widget.actualizaHome)));
            },)
          ] : null,*/
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
              Column(children:<Widget>[
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
                      child: solicitudes.length > 0 ? listaSolicitudes() : Center(child: ListView.builder(shrinkWrap: true,itemCount: 1,itemBuilder:(context, index){ return Column(mainAxisAlignment: MainAxisAlignment.center, children:[Image.asset("images/empty.png"), Padding(padding: EdgeInsets.all(50), child:Text("Grupo sin solicitudes para mostrar ", style: TextStyle( fontSize: 15)))]);}),)//Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text("Grupo sin solicitudes para mostrar ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))))//Center(child: Text("Sin solicitudes para este Grupo"),) 
                    ),
                  ))
                )
              ])
              //solicitudes.length > 0 ? listaSolicitudes() : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text("Grupo sin solicitudes para mostrar 📦☹️", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema))))//Center(child: Text("Sin solicitudes para este Grupo"),) 
            ]
          )
        ),
        floatingActionButton: status ? Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Transform(
              transform: Matrix4.translationValues(0.0, _translateButton.value * 2.0, 0.0),
              child: add(),
            ),
            Transform(
              transform: Matrix4.translationValues(0.0, _translateButton.value * 1.0, 0.0),
              child: image(),
            ),
            toggle()
          ]
        ) : Container(),
        bottomNavigationBar: InkWell(
          child:  Container(
              child: ListTile(
                leading: Icon(Icons.group, color: Colors.white,size: 40.0,),
                title: Row(children: <Widget>[Icon(Icons.error, color: status ? Colors.yellow : Colors.white,),Text(" Este grupo esta en status "+(status ? "Abierto" : "Cerrado"), style: TextStyle(color: Colors.white))],),
                subtitle: status ? Row(children: <Widget>[Text("En ", style: TextStyle(color: Colors.white)), Icon(Icons.menu, color: Colors.white,),Text(" da click en ", style: TextStyle(color: Colors.white)), Icon(Icons.lock, color: Colors.white,), Text(" para cerrar el grupo", style: TextStyle(color: Colors.white))],) : Text(""),
              ),
              color: widget.colorTema
            ),
          
        ),
      )
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
              child: ListTile(
                leading: Icon(Icons.person, color: widget.colorTema,size: 40.0,),
                title: Text(getNombre(solicitudes[index]), style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(getImporte(solicitudes[index])),
                isThreeLine: true,
                trailing: solicitudes[index].status != 0 && solicitudes[index].status != 6 ? Tooltip(message: "Integrante sincronizado.", child: Icon(Icons.done_all)) : getIcono(solicitudes[index]),
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
    return "TELÉFONO: "+solicitud.telefono+"\nIMPORTE: "+importe.toStringAsFixed(2);
  }

  Widget getIcono(Solicitud solicitud){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: 
      <Widget>[
        Container(child: Icon(Icons.access_time, color: Colors.white), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.yellow[700] ,borderRadius: BorderRadius.all(Radius.circular(25)))),
        PopupMenuButton(
          itemBuilder: (_) => <PopupMenuItem<int>>[
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.mode_edit, color: status ? Colors.green : Colors.grey,),Text(" Ver/Editar Solicitud")],), value: 1),
            //new PopupMenuItem<int>(
            //  child: Row(children: <Widget>[Icon(Icons.person_pin, color: status ? Colors.blue : Colors.grey),Text(" Mover a Individual")],), value: 3),
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.group_work, color: status ? Colors.blue : Colors.grey),Text(" Mover a otro Grupo")],), value: 4),
            new PopupMenuItem<int>(
              child: Row(children: <Widget>[Icon(Icons.delete, color: status ? Colors.red : Colors.grey),Text(" Eliminar Solicitud")],), value: 2),
                      ],
          onSelected: (value){
            if(value == 1){
              if(status) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SolicitudEditar(title: "Solicitud Editar:", colorTema: widget.colorTema, idSolicitud: solicitud.idSolicitud )));
            }
            else if(value == 2){
              if(status) eliminarSolicitud(solicitud);
              //Navigator.push(context, MaterialPageRoute(builder: (context) => ListaSolicitudesGrupo(colorTema: widget.colorTema,title: grupo.nombreGrupo,)));
            }else if(value == 3){
              if(userType == 2){
                showSnackBar("Acción no valida. No puedes mover esta solicitud a Individual.", Colors.red);
              }else{
                if(status) moverAIndividual(solicitud);
              } 
            }else if(value == 4){
              if(status) mostrarActionSheet(context, solicitud);
            }
          }
        )
      ],
    );
  }

  eliminarSolicitud(Solicitud solicitud) async{
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0)),
        title: Center(child: Text("Elminar Solicitud")),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.yellow, size: 100.0,),
                Text("\n¿Desea elminar la solicitud a nombre de "+getNombre(solicitud)+"?"),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("No"),
                onPressed: (){Navigator.pop(context);}
              ),
              new FlatButton(
                child: const Text("Sí, eliminar."),
                onPressed: ()async{
                  Navigator.pop(context);
                  await ServiceRepositorySolicitudes.deleteSolicitudCompleta(solicitud);
                  Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(solicitud.idGrupo);
                  Grupo grupoAux = new Grupo(idGrupo: grupo.idGrupo, cantidad: grupo.cantidad - 1, importe: grupo.importe - solicitud.importe);
                  await ServiceRepositoryGrupos.updateGrupoImpCant(grupoAux);
                  solicitudes.clear();
                  widget.actualizaHome();
                  getListDocumentos();
                }
              )
            ],
      );
    });
  }

  cerrarGrupo(Grupo grupo){
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0)),
        title: Center(child: Text("Cerrar Grupo")),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.yellow, size: 100.0,),
                Text("\nAl cerrar el grupo no podrá agregar ni eliminar solicitudes y estará listo para sincronizarse.\n\n¿Desea cerrar el grupo "+grupo.nombreGrupo+"?"),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("No"),
                onPressed: (){Navigator.pop(context);}
              ),
              new FlatButton(
                child: const Text("Sí, cerrar."),
                onPressed: ()async{
                  Navigator.pop(context);
                  var result = await RepositoryServiceCatIntegrantes.getAllCatIntegrantes();
                  int cantidad = result[0].cantidad;
                  if(solicitudes.length >= cantidad){
                    await ServiceRepositoryGrupos.updateGrupoStatus(1, null, grupo.idGrupo);
                    for(final solicitud in solicitudes){
                      if(solicitud.idGrupo == grupo.idGrupo) await ServiceRepositorySolicitudes.updateSolicitudStatus(0, solicitud.idSolicitud);
                    }
                    widget.actualizaHome();
                    setState(() {
                    status = false; 
                    });
                  }else{
                    showSnackBar("El grupo no pudo ser cerrado. Debe tener al menos "+cantidad.toString()+" integrantes", Colors.red);
                  }
                }
              )
            ],
      );
    });
  }

  moverAIndividual(Solicitud solicitudAux)async{
    
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0)),
        title: Center(child: Text("Mover a individual")),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.yellow, size: 100.0,),
                Text("\n¿Desea mover esta solicitud a Individual?"),
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                child: const Text("No"),
                onPressed: (){Navigator.pop(context);}
              ),
              new FlatButton(
                child: const Text("Sí, mover."),
                onPressed: ()async{
                  Navigator.pop(context);
                  Solicitud solicitud = new Solicitud(idSolicitud: solicitudAux.idSolicitud, idGrupo: null, nombreGrupo: null, status: 0, tipoContrato: 1
                  );
                  await ServiceRepositorySolicitudes.updateMoverSolicitud(solicitud);
                  Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(solicitudAux.idGrupo);
                  Grupo grupoAux = new Grupo(idGrupo: grupo.idGrupo, cantidad: grupo.cantidad - 1, importe: grupo.importe - solicitudAux.importe);
                  await ServiceRepositoryGrupos.updateGrupoImpCant(grupoAux);
                  widget.actualizaHome();
                  getListDocumentos();
                }
              )
            ],
      );
    });
  }

  showSnackBar(String texto, MaterialColor color){
    final snackBar = SnackBar(
      content: Text(texto, style: TextStyle(fontWeight: FontWeight.bold),),
      backgroundColor: color[300],
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  mostrarActionSheet(BuildContext context, Solicitud solicitud){
    showCupertinoModalPopup(
      context: context,
      builder: (context){
        return CupertinoActionSheet(
          title: Text("Confirma el grupo"),
          message: Text(gruposAbiertos.length > 0 ? "Selecciona el grupo al que se agregará la solicitud" : "No tienes grupos abiertos"),
          cancelButton: CupertinoActionSheetAction(
            child: Text("Cancelar"),
            onPressed: (){Navigator.of(context).pop();},
          ),
          actions: getGrupos(solicitud),
        );
      }
    );
  }

 List<Widget> getGrupos(Solicitud solicitud){
   List<Widget> listaGrupos = List();
   for(Grupo grupo in gruposAbiertos){
     listaGrupos.add(
       CupertinoActionSheetAction(
        child: Text(grupo.nombreGrupo),
        onPressed: () => moverGrupo(solicitud, grupo),
       )
     );
   }
   return listaGrupos;
 }

  moverGrupo(Solicitud solicitudAux, Grupo group)async{
    if(solicitudAux.idGrupo != group.idGrupo){
      Solicitud solicitud = new Solicitud(idSolicitud: solicitudAux.idSolicitud, idGrupo: group.idGrupo, nombreGrupo: group.nombreGrupo, status: 6, tipoContrato: 2);
      await ServiceRepositorySolicitudes.updateMoverSolicitud(solicitud);
      Grupo grupoAux = new Grupo(idGrupo: group.idGrupo, cantidad: group.cantidad + 1, importe: group.importe + solicitudAux.importe);
      await ServiceRepositoryGrupos.updateGrupoImpCant(grupoAux);
      Grupo grupoviejo = await ServiceRepositoryGrupos.getOneGrupo(solicitudAux.idGrupo);
      Grupo grupoAux2 = new Grupo(idGrupo: solicitudAux.idGrupo, cantidad: grupoviejo.cantidad - 1, importe: grupoviejo.importe - solicitudAux.importe);
      await ServiceRepositoryGrupos.updateGrupoImpCant(grupoAux2);
      widget.actualizaHome();
      getListDocumentos();
    }
    Navigator.of(context).pop();
 }
}