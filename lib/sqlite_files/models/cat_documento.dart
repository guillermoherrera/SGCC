import 'package:sgcartera_app/sqlite_files/database_creator.dart';

class CatDocumento{
  int tipo;
  String descDocumento;

  CatDocumento({
    this.tipo,
    this.descDocumento
  });

  CatDocumento.fromJson(Map<String, dynamic> json){
    this.tipo = json[DataBaseCreator.tipo];
    this.descDocumento = json[DataBaseCreator.descDocumento];
  }
}