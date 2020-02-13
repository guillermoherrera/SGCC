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
  int fechaCaptura;
  String curp;
  String rfc;
  String telefono;
  String nombreGrupo;
  String userID;
  int status;
  int tipoContrato;
  String documentID;
  String grupoID;

  String direccion1;
  String coloniaPoblacion;
  String delegacionMunicipio;
  String ciudad;
  String estado;
  int cp;
  String pais;

  Solicitud({
    this.apellidoPrimero,
    this.apellidoSegundo,
    this.curp,
    this.fechaNacimiento,
    this.fechaCaptura,
    this.idGrupo,
    this.idSolicitud,
    this.importe,
    this.nombrePrimero,
    this.nombreSegundo,
    this.rfc,
    this.telefono,
    this.nombreGrupo,
    this.userID,
    this.status,
    this.tipoContrato,
    this.documentID,
    this.grupoID,
    
    this.ciudad,
    this.coloniaPoblacion,
    this.cp,
    this.delegacionMunicipio,
    this.direccion1,
    this.estado,
    this.pais
  });

  Solicitud.fromJson(Map<String, dynamic>json){
    this.apellidoPrimero = json[DataBaseCreator.apellidoPrimero];
    this.apellidoSegundo = json[DataBaseCreator.apellidoSegundo];
    this.curp = json[DataBaseCreator.curp];
    this.fechaNacimiento = json[DataBaseCreator.fechaNacimiento];
    this.fechaCaptura = json[DataBaseCreator.fechaCaptura];
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
    this.tipoContrato = json[DataBaseCreator.tipoContrato];

    this.ciudad = json[DataBaseCreator.ciudad];
    this.coloniaPoblacion = json[DataBaseCreator.coloniaPoblacion];
    this.cp = json[DataBaseCreator.cp];
    this.delegacionMunicipio = json[DataBaseCreator.delegacionMunicipio];
    this.direccion1 = json[DataBaseCreator.direccion1];
    this.estado = json[DataBaseCreator.estado];
    this.pais = json[DataBaseCreator.pais];

    this.documentID = json[DataBaseCreator.documentID];
  }
}