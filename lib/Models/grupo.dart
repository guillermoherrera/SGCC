class GrupoObj {
  String nombre;
  int status;
  String userID;
  double importe;
  int integrantes;
  String grupoID;
  int grupo_id;

  GrupoObj({
    this.nombre,
    this.status,
    this.userID,
    this.importe,
    this.integrantes,
    this.grupoID,
    this.grupo_id
  });

  Map<String, dynamic> toJson()=>{
    'nombre': nombre,
    'status': status,
    'userID': userID,
    'importe': importe,
    'integrantes': integrantes,
    'grupo_id': grupo_id
  };
}