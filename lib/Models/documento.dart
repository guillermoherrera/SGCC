import 'dart:io';

class Documento{
  int idDocumentoSolicitud;
  int tipo;
  String documento;
  int version;

  Documento({
    this.idDocumentoSolicitud,
    this.tipo,
    this.documento,
    this.version
  });

  Map<String, dynamic> toJson()=>{
    'idDocumentoSolicitud': idDocumentoSolicitud,
    'tipo': tipo,
    'documento': documento,
    'version': version
  };
}

class DocumentoArchivo{
  int idDocumentoSolicitud;
  int tipo;
  File archivo;
  int version;

  DocumentoArchivo({
    this.idDocumentoSolicitud,
    this.tipo,
    this.archivo,
    this.version
  });

  Map<String, dynamic> toJson()=>{
    'idDocumentoSolicitud': idDocumentoSolicitud,
    'tipo': tipo,
    'archivo': archivo,
    'version': version
  };
}