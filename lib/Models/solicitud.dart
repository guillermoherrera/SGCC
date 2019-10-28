class SolicitudObj{
  Map persona;
  double importe;
  DateTime fechaCaputra;
  int tipoContrato; 
  String userID;
  List<Map> documentos;
  int status;

  String grupoNombre;
  int grupoId;
  String grupoID;

  SolicitudObj({
    this.persona,
    this.importe,
    this.fechaCaputra,
    this.tipoContrato,
    this.userID,
    this.documentos,
    this.status,
    this.grupoId,
    this.grupoNombre,
    this.grupoID
  });

  Map<String, dynamic> toJson()=>{
    'persona': persona,
    'importe': importe,
    'fechaCaputra': fechaCaputra,
    'tipoContrato': tipoContrato,
    'userID': userID,
    'documentos': documentos,
    'status': status,
    //'grupoId': grupoId,
    'grupoNombre': grupoNombre,
    'grupoID': grupoID
  };
}