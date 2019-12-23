import 'package:sgcartera_app/sqlite_files/database_creator.dart';

class Grupo{
  int idGrupo;
  String nombreGrupo;
  int status;
  String userID;
  double importe;
  int cantidad;

  String grupoID;

  Grupo({
    this.idGrupo,
    this.nombreGrupo,
    this.status,
    this.userID,
    this.cantidad,
    this.importe,
    this.grupoID
  }); 

  Grupo.fromjson(Map<String, dynamic> json){
    this.idGrupo = json[DataBaseCreator.idGrupo];
    this.nombreGrupo = json[DataBaseCreator.nombreGrupo];
    this.status = json[DataBaseCreator.status];
    this.userID = json[DataBaseCreator.userID];
    this.cantidad = json[DataBaseCreator.cantidad];
    this.importe = json[DataBaseCreator.importe_grupo];

    this.grupoID = json[DataBaseCreator.grupoID];
  }
}