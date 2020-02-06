import 'package:flutter/material.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/pages/lista_solicitudes_grupo.dart';
import 'package:sgcartera_app/pages/solicitud.dart';

import 'package:sgcartera_app/sqlite_files/models/solicitud.dart' as SolicitudModel;
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_catIntegrantes.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Group extends StatefulWidget {
  Group({this.colorTema, this.actualizaHome});
  Color colorTema;
  final VoidCallback actualizaHome;
  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<Group> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String userID;
  List<Grupo> grupos = List();  
  final _formKey = new GlobalKey<FormState>();
  var _nombre = TextEditingController();
  AuthFirebase authFirebase = new AuthFirebase();
  int gruposCant = 0;

  Future<void> getListGrupos() async{
    final pref = await SharedPreferences.getInstance();
    userID = pref.getString("uid");
    grupos = await ServiceRepositoryGrupos.getAllGrupos(userID);
    gruposCant = grupos.length;    
    setState(() {});
  }

  @override
  void initState() {
    getListGrupos();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Captura de Grupos", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.group_add), onPressed: () {showFormGrupo();},)
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
                      title: Text("\nGRUPOS EN CAPTURA: "+gruposCant.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white)),
                      subtitle: Text("", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
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
                      padding: EdgeInsets.all(5.0),
                      child: grupos.length > 0 ? Padding(padding: EdgeInsets.all(5.0), child: listaGrupos()) :  Padding(padding: EdgeInsets.all(20.0),child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center ,children: <Widget>[ Text("Sin grupos en captura ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), Row(mainAxisAlignment: MainAxisAlignment.center ,children: <Widget>[ Text("Presiona ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)), Icon(Icons.group_add, size: 30.0), Text(" para agregar un nuevo grupo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))],)],)), 
                    ),
                  )
                ))),
              ]),
              grupos.length > 0 ? Container() : ListView()
            /*Column(children: <Widget>[
              ResponsiveContainer(
                heightPercent: 30.0,
                widthPercent: 100.0,
                child: Container(color: widget.colorTema, child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center ,children: <Widget>[Icon(Icons.group,color: Colors.white60, size: isLandscape ? 50.0 : 150.0), Text("GRUPOS EN CAPTURA: "+gruposCant.toString(), style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),)]),
                )),
              ),
              grupos.length > 0 ? Expanded(child:listaGrupos()) :  Padding(padding: EdgeInsets.all(20.0),child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center ,children: <Widget>[ Text("Sin grupos en captura ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)), Row(mainAxisAlignment: MainAxisAlignment.center ,children: <Widget>[ Text("Presiona ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)), Icon(Icons.group_add, size: 30.0,color: Colors.white,), Text(" para agregar un nuevo grupo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white))],)],))), 
              grupos.length > 0 ? Container() : Expanded(child:ListView())
            ])*/
          ]
        )
      ),
    );
  }

  Widget listaGrupos(){        
    return ListView.builder(
      itemCount: grupos.length,
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
                leading: Icon(Icons.group, color: widget.colorTema,size: 40.0,),
                title: Text(getNombre(grupos[index]), style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: getLeyendaGrupo(grupos[index]),//Text(getImporte(grupos[index])),
                isThreeLine: true,
                trailing: getIcono(grupos[index])
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

  String getNombre(Grupo grupo){
    String nombre = grupo.nombreGrupo;
    return nombre;
  }

  String getImporte(Grupo grupo){
    String leyenda;
    switch (grupo.status) {
      case 0:
        leyenda = "Grupo Abierto";
        break;
      case 1:
        leyenda = "Grupo Cerrado";
        break;
      case 2:
        leyenda = "Grupo Sincronizado";
        break;
      default:
        leyenda = "Error";
        break;
    }
    return leyenda;
  }

  Widget getIcono(Grupo grupo){
    return PopupMenuButton(
      itemBuilder: (_) => <PopupMenuItem<int>>[
        new PopupMenuItem<int>(
          child: Row(children: <Widget>[Icon(Icons.person_add, color: grupo.status == 0 ? Colors.green : Colors.grey,),Text(" Agregar Solicitud", style: TextStyle(color: grupo.status == 0 ? Colors.green : Colors.grey),)],), value: 1),
        new PopupMenuItem<int>(
          child: Row(children: <Widget>[Icon(Icons.edit, color: grupo.status == 0 ? Colors.purple : Colors.grey,),Text(" Cambiar Nombre", style: TextStyle(color: grupo.status == 0 ? Colors.purple : Colors.grey),)],), value: 5),
        new PopupMenuItem<int>(
          child: Row(children: <Widget>[Icon(Icons.list, color: Colors.blue),Text(" Ver Solicitudes", style: TextStyle(color: Colors.blue),)],), value: 2),
        new PopupMenuItem<int>(
          child: Row(children: <Widget>[Icon(Icons.lock, color: grupo.status == 0 ? Colors.blueGrey : Colors.grey),Text(" Cerrar Grupo", style: TextStyle(color: grupo.status == 0 ? Colors.blueGrey : Colors.grey),)],), value: 3),
        new PopupMenuItem<int>(
          child: Row(children: <Widget>[Icon(Icons.delete, color: Colors.red),Text(" Eliminar Grupo", style: TextStyle(color: Colors.red),)],), value: 4),
      ],
      onSelected: (value){
        if(value == 1){
          if(grupo.status == 0){
            Navigator.push(context, MaterialPageRoute(builder: (context) => Solicitud(title: "Solicitud Grupal: "+grupo.nombreGrupo, colorTema: widget.colorTema, grupoId: grupo.idGrupo, grupoNombre: grupo.nombreGrupo, actualizaHome: widget.actualizaHome)));
          }
        }
        else if(value == 2){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ListaSolicitudesGrupo(colorTema: widget.colorTema,title: grupo.nombreGrupo, actualizaHome: widget.actualizaHome, grupo: grupo)));
        }else if(value == 3){
          if(grupo.status == 0){
            cerrarGrupo(grupo.idGrupo, grupo.nombreGrupo);
          }
        }else if(value == 4){
          eliminarGrupo(grupo.idGrupo, grupo.nombreGrupo);
        }
        else if(value == 5){
          if(grupo.status == 0){
            showEditarGrupo(grupo);
          }
        }
      }
    );
  }

  showFormGrupo(){
    _nombre.text = "";
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0)),
        title: Center(child: Text("AGREGAR GRUPO")),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              padded(
                TextFormField(
                  controller: _nombre,
                  maxLength: 25,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: "Nombre del Grupo",
                    prefixIcon: Icon(Icons.group),
                    fillColor: Color(0xfff2f2f2),
                    filled: true,
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (_nombre.text != value.toUpperCase())
                      _nombre.value = _nombre.value.copyWith(text: value.toUpperCase());
                  },
                  validator: (value){return value.isEmpty ? "Ingresa el nombre" : null;},
                ),
              ),
              SizedBox(width: double.infinity, child:RaisedButton(
                onPressed: (){
                  crearGrupo();
                },
                color: Color(0xfff2f2f2),
                textColor: widget.colorTema,
                child: Text("CREAR GRUPO", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0))
              ))
            ],
          ),
        ),
      );
    });
  }

  showEditarGrupo(Grupo grupo){
    _nombre.text = grupo.nombreGrupo;
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0)),
        title: Center(child: Text("CAMBIAR NOMBRE DEL GRUPO")),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              padded(
                TextFormField(
                  controller: _nombre,
                  maxLength: 25,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: "Nombre del Grupo",
                    prefixIcon: Icon(Icons.group),
                    fillColor: Color(0xfff2f2f2),
                    filled: true,
                    border: new OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (_nombre.text != value.toUpperCase())
                      _nombre.value = _nombre.value.copyWith(text: value.toUpperCase());
                  },
                  validator: (value){return value.isEmpty ? "Ingresa el nombre" : null;},
                ),
              ),
              SizedBox(width: double.infinity, child:RaisedButton(
                onPressed: (){
                  editarGrupo(grupo);
                },
                color: Color(0xfff2f2f2),
                textColor: widget.colorTema,
                child: Text("ACTUALIZAR NOMBRE DEL GRUPO"),
                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0))
              ))
            ],
          ),
        ),
      );
    });
  }

  Widget padded(Widget childs){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: childs,
    );
  }

  crearGrupo() async{
    FocusScope.of(context).requestFocus(FocusNode());
    if(_formKey.currentState.validate()){
      Navigator.pop(context);
      
      final int _idG = await ServiceRepositoryGrupos.gruposCount();
      final Grupo grupo = new Grupo(
        idGrupo: _idG + 1 ,
        nombreGrupo: _nombre.text,
        status: 0,
        userID: userID
      );
      _nombre.text = "";

      if(await ServiceRepositoryGrupos.validaGrupo(grupo)){
        await ServiceRepositoryGrupos.addGrupo(grupo);
        getListGrupos();
      }else{
        showSnackBar("Ya tienes un grupo con el nombre "+grupo.nombreGrupo+" en tu lista de grupos", Colors.red);
      }
      
    }
  }

  editarGrupo(Grupo grupoAux) async{
    FocusScope.of(context).requestFocus(FocusNode());
    if(_formKey.currentState.validate()){
      Navigator.pop(context);
      
      final Grupo grupo = new Grupo(
        idGrupo: grupoAux.idGrupo ,
        nombreGrupo: _nombre.text,
        status: grupoAux.status,
        userID: grupoAux.userID
      );
      _nombre.text = "";

      if(await ServiceRepositoryGrupos.validaGrupo(grupo)){
        ServiceRepositoryGrupos.updateGrupoNombre(grupo);
        ServiceRepositorySolicitudes.updateSolicitudGrupo(grupo);
        getListGrupos();
      }else{
        showSnackBar("Ya tienes un grupo con el nombre "+grupo.nombreGrupo+" en tu lista de grupos", Colors.red);
      }
    }
  }

  Widget getLeyendaGrupo(Grupo grupo){
    bool accion = grupo.status == 0;
    String texto;
    //texto = accion ? "Grupo Abierto.\nCierralo para sincronizar." : "Grupo Cerrado.\nListo para sincronizar";
    texto = "Integrantes: "+grupo.cantidad.toString()+"\nImporte: "+grupo.importe.toString();
    return Row(children: <Widget>[
      Icon(accion ? Icons.lock_open : Icons.lock, size: 20,),
      Text(texto)
    ],
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.start,);
  }

  cerrarGrupo(grupoId, grupoNombre){
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0)),
        title: Center(child: Text("CERRAR GRUPO")),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.yellow, size: 100.0,),
                Text("\nAl cerrar el grupo no podrá agregar ni eliminar solicitudes y estará listo para sincronizarse.\n\n¿Desea cerrar el grupo "+grupoNombre+"?"),
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
                  List<SolicitudModel.Solicitud> solicitudes =  List();
                  solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudesGrupo(userID, grupoNombre);
                  var result = await RepositoryServiceCatIntegrantes.getAllCatIntegrantes();
                  int cantidad = result[0].cantidad;
                  if(solicitudes.length >= cantidad){
                    await ServiceRepositoryGrupos.updateGrupoStatus(1, null, grupoId);
                    final pref = await SharedPreferences.getInstance();
                    userID = pref.getString("uid");
                    for(final solicitud in solicitudes){
                      if(solicitud.idGrupo == grupoId) ServiceRepositorySolicitudes.updateSolicitudStatus(0, solicitud.idSolicitud);
                    }
                    grupos.clear();
                    widget.actualizaHome();
                    showSnackBar("Grupo "+grupoNombre+" cerrado. Ahora esta en espera para ser Sincronizado", Colors.green);
                    getListGrupos();
                  }else{
                    showSnackBar("El grupo "+grupoNombre+" no pudo ser cerrado. Debe tener al menos "+cantidad.toString()+" integrantes", Colors.red);
                  }
                }
              )
            ],
      );
    });
  }

  eliminarGrupo(grupoId, grupoNombre) async{
    showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0)),
        title: Center(child: Text("ELIMINAR GRUPO")),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.yellow, size: 100.0,),
                Text("\n¿Desea elminar el grupo "+grupoNombre+" y sus solicitudes?"),
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
                  List<SolicitudModel.Solicitud> solicitudes = List();
                  final pref = await SharedPreferences.getInstance();
                  userID = pref.getString("uid");
                  solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudesGrupo(userID, grupoNombre);   
                  for(final solicitud in solicitudes){
                    await ServiceRepositorySolicitudes.deleteSolicitudCompleta(solicitud);
                  }
                  await ServiceRepositoryGrupos.deleteGrupo(grupoId);
                  grupos.clear();
                  widget.actualizaHome();
                  getListGrupos();
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
}