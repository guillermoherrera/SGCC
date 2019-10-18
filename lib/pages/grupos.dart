import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/pages/lista_solicitudes_grupo.dart';
import 'package:sgcartera_app/pages/solicitud.dart';

import 'package:sgcartera_app/sqlite_files/models/solicitud.dart' as SolicitudModel;
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Group extends StatefulWidget {
  Group({this.colorTema, this.actualizaHome});
  MaterialColor colorTema;
  final VoidCallback actualizaHome;
  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<Group> {
  String userID;
  List<Grupo> grupos = List();  
  final _formKey = new GlobalKey<FormState>();
  var _nombre = TextEditingController();
  AuthFirebase authFirebase = new AuthFirebase();

  Future<void> getListGrupos() async{
    final pref = await SharedPreferences.getInstance();
    userID = pref.getString("uid");
    grupos = await ServiceRepositoryGrupos.getAllGrupos(userID);    
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Grupos"),
        centerTitle: true,
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
                colors: [widget.colorTema[100], Colors.white])
              ),
            ),
            grupos.length > 0 ? listaGrupos() : Center(child: Text("Sin grupos"),) 
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
                colors: [widget.colorTema[400], Colors.white])
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
          Navigator.push(context, MaterialPageRoute(builder: (context) => ListaSolicitudesGrupo(colorTema: widget.colorTema,title: grupo.nombreGrupo, actualizaHome: widget.actualizaHome)));
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
        title: Center(child: Text("Agregar Grupo")),
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
                    prefixIcon: Icon(Icons.group)
                  ),
                  onChanged: (value) {
                    if (_nombre.text != value.toUpperCase())
                      _nombre.value = _nombre.value.copyWith(text: value.toUpperCase());
                  },
                  validator: (value){return value.isEmpty ? "Ingresa el nombre" : null;},
                ),
              ),
              RaisedButton(
                onPressed: (){
                  crearGrupo();
                },
                color: widget.colorTema,
                textColor: Colors.white,
                child: Text("Crear Grupo"),
              )
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
        title: Center(child: Text("Cambiar Nombre del Grupo")),
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
                    prefixIcon: Icon(Icons.group)
                  ),
                  onChanged: (value) {
                    if (_nombre.text != value.toUpperCase())
                      _nombre.value = _nombre.value.copyWith(text: value.toUpperCase());
                  },
                  validator: (value){return value.isEmpty ? "Ingresa el nombre" : null;},
                ),
              ),
              RaisedButton(
                onPressed: (){
                  editarGrupo(grupo);
                },
                color: widget.colorTema,
                textColor: Colors.white,
                child: Text("Actualizar Grupo"),
              )
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

      ServiceRepositoryGrupos.addGrupo(grupo);
      getListGrupos();
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

      ServiceRepositoryGrupos.updateGrupoNombre(grupo);
      ServiceRepositorySolicitudes.updateSolicitudGrupo(grupo);
      getListGrupos();
    }
  }

  Widget getLeyendaGrupo(Grupo grupo){
    bool accion = grupo.status == 0;
    String texto;
    texto = accion ? "Grupo Abierto.\nCierralo para sincronizar." : "Grupo Cerrado.\nListo para sincronizar.";
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
        title: Center(child: Text("Cerrar Grupo")),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.yellow, size: 100.0,),
                Text("\nAl cerrar el grupo no podrá agregarle mas solicitudes y estara listo para sincronizarse.\n\n¿Desea cerrar el grupo "+grupoNombre+"?"),
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
                  await ServiceRepositoryGrupos.updateGrupoStatus(1, grupoId);
                  grupos.clear();
                  getListGrupos();
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
        title: Center(child: Text("Elminar Solicitud")),
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
}