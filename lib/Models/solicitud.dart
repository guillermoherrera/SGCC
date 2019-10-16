class SolicitudObj{
  Map persona;
  double importe;
  DateTime fechaCaputra;
  int tipoContrato; 
  String userID;
  List<Map> documentos;
  int status;

  SolicitudObj({
    this.persona,
    this.importe,
    this.fechaCaputra,
    this.tipoContrato,
    this.userID,
    this.documentos,
    this.status
  });

  Map<String, dynamic> toJson()=>{
    'persona': persona,
    'importe': importe,
    'fechaCaputra': fechaCaputra,
    'tipoContrato': tipoContrato,
    'userID': userID,
    'documentos': documentos,
    'status': status
  };
}