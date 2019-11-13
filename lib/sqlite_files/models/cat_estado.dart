import 'package:sgcartera_app/sqlite_files/database_creator.dart';

class CatEstado{
  String estado;
  String codigo;

  CatEstado({
    this.estado,
    this.codigo
  });

  CatEstado.fromJson(Map<String, dynamic> json){
    this.estado = json[DataBaseCreator.estado];
    this.codigo = json[DataBaseCreator.codigo];
  }
}