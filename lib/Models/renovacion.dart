class Renovacion{
  int creditoID;
  int clienteID;
  String nombre;
  double importe;
  double capital; 
  int diasAtraso;
  List<Map> beneficios;

  Renovacion({
    this.creditoID,
    this.clienteID,
    this.nombre,
    this.importe,
    this.capital,
    this.diasAtraso,
    this.beneficios
  });
}

class Beneficio{
  String claveBeneficio;

  Beneficio({
    this.claveBeneficio
  });
}

