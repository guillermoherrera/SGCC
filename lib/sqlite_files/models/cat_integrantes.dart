import 'package:sgcartera_app/sqlite_files/database_creator.dart';

class CatIntegrante{
  int cantidad;

  CatIntegrante({this.cantidad});

  CatIntegrante.fromJson(Map<String, dynamic> json){this.cantidad = json[DataBaseCreator.cantidadIntegrantes];}
}
