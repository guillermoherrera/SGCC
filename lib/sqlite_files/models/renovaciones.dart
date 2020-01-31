import 'package:sgcartera_app/sqlite_files/database_creator.dart';

class Renovacion{
  int idRenovacion;
  int idGrupo;
  String nombreGrupo;
  int creditoID;
  int clienteID;
  String nombreCompleto;
  double importe;
  double capital;
  int diasAtraso;
  String beneficio;
  String ticket;

  Renovacion({
    this.beneficio,
    this.capital,
    this.clienteID,
    this.creditoID,
    this.diasAtraso,
    this.idGrupo,
    this.idRenovacion,
    this.importe,
    this.nombreCompleto,
    this.nombreGrupo,
    this.ticket
  });

  Renovacion.fromjson(Map<String, dynamic> json){
    this.beneficio = json[DataBaseCreator.beneficio];
    this.capital = json[DataBaseCreator.capital];
    this.clienteID = json[DataBaseCreator.clienteID];
    this.creditoID = json[DataBaseCreator.creditoID];
    this.diasAtraso = json[DataBaseCreator.diasAtraso];
    this.idGrupo = json[DataBaseCreator.idGrupo];
    this.idRenovacion = json[DataBaseCreator.idRenovacion];
    this.importe = json[DataBaseCreator.importe];
    this.nombreCompleto = json[DataBaseCreator.nombreCompleto];
    this.nombreGrupo = json[DataBaseCreator.nombreGrupo];
    this.ticket = json[DataBaseCreator.ticket];
  }
}