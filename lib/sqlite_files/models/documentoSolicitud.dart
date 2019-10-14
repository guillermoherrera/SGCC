import 'package:sgcartera_app/sqlite_files/database_creator.dart';

class DocumentoSolicitud{
  int idDocumentoSolicitud;
  int idSolicitud;
  int tipo;
  String documento;

  DocumentoSolicitud({
    this.documento,
    this.idDocumentoSolicitud,
    this.idSolicitud,
    this.tipo
  });

  DocumentoSolicitud.fromJson(Map<String, dynamic>json){
    this.documento = json[DataBaseCreator.documento];
    this.idDocumentoSolicitud = json[DataBaseCreator.idDocumentoSolicitudes];
    this.idSolicitud = json[DataBaseCreator.id_Solicitud];
    this.tipo = json[DataBaseCreator.tipoDocumento];
  }
}
