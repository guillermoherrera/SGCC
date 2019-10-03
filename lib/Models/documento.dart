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