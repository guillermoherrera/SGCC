class Direccion{
  String direccion1;
  String coloniaPoblacion;
  String delegacionMunicipio;
  String ciudad;
  String estado;
  int cp;
  String pais;

  Direccion({
    this.ciudad,
    this.coloniaPoblacion,
    this.cp,
    this.delegacionMunicipio,
    this.direccion1,
    this.estado,
    this.pais
  });

  Map<String, dynamic> toJson()=>{
    'ciudad': ciudad,
    'coloniaPoblacion': coloniaPoblacion,
    'cp': cp,
    'delegacionMunicipio': delegacionMunicipio,
    'direccion1': direccion1,
    'estado': estado,
    'pais': pais
  };
}