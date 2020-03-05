class ConsultaApiKey{
  String apiKey;
  bool result;
  String mensaje;

  ConsultaApiKey({
    this.apiKey,
    this.result,
    this.mensaje
  });
}

class Contrato{
  int contratoId;
  String nombreGeneral;
  String fechaTermina;
  
  String fechaInicio;
  double importe;
  double saldoActual;
  double saldoAtrazado;
  int diasAtrazo;
  double pagoXPlazo;
  int ultimoPagoPlazo;
  int plazos;
  double capital;
  double interes;
  String contacto;
  String status;
  int integrantesCant;

  Contrato({
    this.contratoId,
    this.fechaTermina,
    this.nombreGeneral,

    this.capital,
    this.contacto,
    this.diasAtrazo,
    this.fechaInicio,
    this.importe,
    this.integrantesCant,
    this.interes,
    this.pagoXPlazo,
    this.plazos,
    this.saldoActual,
    this.saldoAtrazado,
    this.status,
    this.ultimoPagoPlazo
  });
}

class Integrante{
  String cveCliente;
  String nombreCompleto;
  String telefono;
  double importe;

  String fechaTermina;
  String fechaUltimoPago;
  int noCda;
  double saldoActual;
  double saldoAtrazado;
  int diasAtrazo;
  int pagos;
  int folio;
  double capital;
  double interes;

  Integrante({
    this.cveCliente,
    this.importe,
    this.nombreCompleto,
    this.telefono,

    this.capital,
    this.diasAtrazo,
    this.fechaTermina,
    this.fechaUltimoPago,
    this.folio,
    this.interes,
    this.noCda,
    this.pagos,
    this.saldoActual,
    this.saldoAtrazado
  });
}

class ContratosRequest{
  bool result;
  String mensaje;
  int contratosCant;
  List<Contrato> contratos;

  ContratosRequest({
    this.contratos,
    this.contratosCant,
    this.mensaje,
    this.result
  });
}

class ContratoDetalleRequest{
  bool result;
  String mensaje;
  Contrato contrato;
  List<Integrante> integrantes;
}

class IntegranteDetalleRequest{
  bool result;
  String mensaje;
  Integrante integrante;
}
