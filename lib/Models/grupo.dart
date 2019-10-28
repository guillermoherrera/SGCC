class GrupoObj {
  String nombre;
  int status;
  String userID;
  double importe;
  int integrantes;
  String grupoID;

  GrupoObj({
    this.nombre,
    this.status,
    this.userID,
    this.importe,
    this.integrantes,
    this.grupoID
  });

  Map<String, dynamic> toJson()=>{
    'nombre': nombre,
    'status': status,
    'userID': userID,
    'importe': importe,
    'integrantes': integrantes
  };
}