import 'package:sgcartera_app/sqlite_files/database_creator.dart';

class Solicitud{
  int  idSolicitud;
  int idGrupo;
  double importe;
  String nombrePrimero;
  String nombreSegundo;
  String apellidoPrimero;
  String apellidoSegundo;
  int fechaNacimiento;
  String curp;
  String rfc;
  String telefono;
  String nombreGrupo;
  String userID;
  int status;

  Solicitud({
    this.apellidoPrimero,
    this.apellidoSegundo,
    this.curp,
    this.fechaNacimiento,
    this.idGrupo,
    this.idSolicitud,
    this.importe,
    this.nombrePrimero,
    this.nombreSegundo,
    this.rfc,
    this.telefono,
    this.nombreGrupo,
    this.userID,
    this.status
  });

  Solicitud.fromJson(Map<String, dynamic>json){
    this.apellidoPrimero = json[DataBaseCreator.apellidoPrimero];
    this.apellidoSegundo = json[DataBaseCreator.apellidoSegundo];
    this.curp = json[DataBaseCreator.curp];
    this.fechaNacimiento = json[DataBaseCreator.fechaNacimiento];
    this.idGrupo = json[DataBaseCreator.id_grupo];
    this.idSolicitud = json[DataBaseCreator.idSolicitud];
    this.importe = json[DataBaseCreator.importe];
    this.nombrePrimero = json[DataBaseCreator.nombrePrimero];
    this.nombreSegundo = json[DataBaseCreator.nombreSegundo];
    this.rfc = json[DataBaseCreator.rfc];
    this.telefono = json[DataBaseCreator.telefono];
    this.nombreGrupo = json[DataBaseCreator.nombre_Grupo];
    this.userID = json[DataBaseCreator.userID];
    this.status = json[DataBaseCreator.status];
  }
}