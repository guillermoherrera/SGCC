import 'dart:io';

class Documento{
  int idDocumentoSolicitud;
  int tipo;
  String documento;
  int version;

  String observacionCambio;

  Documento({
    this.idDocumentoSolicitud,
    this.tipo,
    this.documento,
    this.version,

    this.observacionCambio
  });

  Map<String, dynamic> toJson()=>{
    'idDocumentoSolicitud': idDocumentoSolicitud,
    'tipo': tipo,
    'documento': documento,
    'version': version,

    'observacionCambio': observacionCambio
  };
}

class DocumentoArchivo{
  int idDocumentoSolicitud;
  int tipo;
  File archivo;
  int version;
  String observacionCambio;

  DocumentoArchivo({
    this.idDocumentoSolicitud,
    this.tipo,
    this.archivo,
    this.version,
    this.observacionCambio
  });

  Map<String, dynamic> toJson()=>{
    'idDocumentoSolicitud': idDocumentoSolicitud,
    'tipo': tipo,
    'archivo': archivo,
    'version': version,
    'observacionCambio': observacionCambio
  };
}