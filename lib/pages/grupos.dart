import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/pages/lista_solicitudes_grupo.dart';
import 'package:sgcartera_app/pages/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart';

class Group extends StatefulWidget {
  Group({this.colorTema});
  MaterialColor colorTema;
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
    userID = await authFirebase.currrentUser();
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
        title: Text("Mis Grupos"),
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
            grupos.length > 0 ? listaGrupos() : Center(child: Text("Sin Información"),) 
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
                subtitle: Text(getImporte(grupos[index])),
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
          child: Row(children: <Widget>[Icon(Icons.person_add, color: Colors.green,),Text(" Agregar Solicitud")],), value: 1),
        new PopupMenuItem<int>(
          child: Row(children: <Widget>[Icon(Icons.list, color: Colors.blue),Text(" Ver Solicitudes")],), value: 2),
        new PopupMenuItem<int>(
          child: Row(children: <Widget>[Icon(Icons.lock, color: Colors.grey),Text(" Cerrar Grupo")],), value: 3),
        new PopupMenuItem<int>(
          child: Row(children: <Widget>[Icon(Icons.delete, color: Colors.red),Text(" Eliminar Grupo")],), value: 4),
      ],
      onSelected: (value){
        if(value == 1){
          Navigator.push(context, MaterialPageRoute(builder: (context) => Solicitud(title: "Solicitud Grupal: "+grupo.nombreGrupo, colorTema: widget.colorTema, grupoId: grupo.idGrupo, grupoNombre: grupo.nombreGrupo,)));
        }
        else if(value == 2){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ListaSolicitudesGrupo(colorTema: widget.colorTema,title: grupo.nombreGrupo,)));
        }
      }
    );
  }

  showFormGrupo(){
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
}