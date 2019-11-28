import 'dart:io';

class Documento{
  int tipo;
  String documento;
  int version;

  Documento({
    this.tipo,
    this.documento,
    this.version
  });

  Map<String, dynamic> toJson()=>{
    'tipo': tipo,
    'documento': documento,
    'version': version
  };
}

class DocumentoArchivo{
  int tipo;
  File archivo;
  int version;

  DocumentoArchivo({
    this.tipo,
    this.archivo,
    this.version
  });

  Map<String, dynamic> toJson()=>{
    'tipo': tipo,
    'archivo': archivo,
    'version': version
  };
}