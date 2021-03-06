class RenovacionObj{
  int creditoID;
  String clienteID;
  String nombre;
  double importe;
  double capital; 
  int diasAtraso;
  List<Map> beneficios;
  String grupoID;
  String grupoNombre;
  String ticket;
  int status;
  String userID;
  DateTime fechaCaptura;
  int grupo_Id;
  int tipoContrato;
  double importeHistorico;

  RenovacionObj({
    this.creditoID,
    this.clienteID,
    this.nombre,
    this.importe,
    this.capital,
    this.diasAtraso,
    this.beneficios,
    this.grupoID,
    this.grupoNombre,
    this.ticket,
    this.status,
    this.userID,
    this.fechaCaptura,
    this.grupo_Id,
    this.tipoContrato,
    this.importeHistorico
  });

  Map<String, dynamic> toJson()=>{
    'creditoID': creditoID,
    'clienteID': clienteID,
    'nombre': nombre,
    'importe': importe,
    'capital': capital,
    'diasAtraso': diasAtraso,
    'beneficios': beneficios,
    'grupoID': grupoID,
    'grupoNombre': grupoNombre,
    'ticket': ticket,
    'status': status,
    'userID': userID,
    'fechaCaptura': fechaCaptura,
    'grupo_Id': grupo_Id,
    'tipoContrato': tipoContrato,
    'importeHistorico': importeHistorico
  };
}

class BeneficioObj{
  String claveBeneficio;

  BeneficioObj({
    this.claveBeneficio
  });

  Map<String, dynamic> toJson()=>{
    'claveBeneficio' : claveBeneficio
  };
}

