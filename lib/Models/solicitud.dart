class SolicitudObj{
  Map persona;
  Map direccion;
  double importe;
  DateTime fechaCaputra;
  int tipoContrato; 
  String userID;
  List<Map> documentos;
  int status;

  String grupoNombre;
  int grupoId;
  String grupoID;
  
  int grupo_Id;

  SolicitudObj({
    this.persona,
    this.direccion,
    this.importe,
    this.fechaCaputra,
    this.tipoContrato,
    this.userID,
    this.documentos,
    this.status,
    this.grupoId,
    this.grupoNombre,
    this.grupoID,
    this.grupo_Id
  });

  Map<String, dynamic> toJson()=>{
    'persona': persona,
    'direccion': direccion,
    'importe': importe,
    'fechaCaputra': fechaCaputra,
    'tipoContrato': tipoContrato,
    'userID': userID,
    'documentos': documentos,
    'status': status,
    //'grupoId': grupoId,
    'grupoNombre': grupoNombre,
    'grupoID': grupoID,
    'grupo_Id': grupo_Id
  };
}