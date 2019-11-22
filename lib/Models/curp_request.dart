import 'package:sgcartera_app/models/solicitud.dart';

class CurpRequest{
  SolicitudObj datos;
  bool result;
  int creditosActivos;
  String mensaje;

  CurpRequest({
    this.datos,
    this.result,
    this.creditosActivos,
    this.mensaje
  });
}

class ConsultaToken{
  String token;
  bool result;
  String mensaje;

  ConsultaToken({
    this.token,
    this.result,
    this.mensaje
  });
}