import 'dart:io';

class Documento{
  int tipo;
  String documento;

  Documento({
    this.tipo,
    this.documento
  });

  Map<String, dynamic> toJson()=>{
    'tipo': tipo,
    'documento': documento
  };
}

class DocumentoArchivo{
  int tipo;
  File archivo;

  DocumentoArchivo({
    this.tipo,
    this.archivo
  });

  Map<String, dynamic> toJson()=>{
    'tipo': tipo,
    'archivo': archivo
  };
}