import 'package:sgcartera_app/sqlite_files/models/cat_integrantes.dart';

import '../database_creator.dart';

class RepositoryServiceCatIntegrantes{

  static Future<List<CatIntegrante>> getAllCatIntegrantes() async{
    final sql = '''SELECT * FROM ${DataBaseCreator.catIntegrantesTable}''';

    final data = await db.rawQuery(sql);
    List<CatIntegrante> catIntegrantes = List();
    for(final json in data){
      final catIntegrante = CatIntegrante.fromJson(json);
      catIntegrantes.add(catIntegrante);
    }
    return catIntegrantes;
  }

  static Future<void> addCatIntegrante(CatIntegrante catIntegrante) async{
    final sql = '''INSERT INTO ${DataBaseCreator.catIntegrantesTable}(
      ${DataBaseCreator.cantidadIntegrantes}
    )VALUES(
      ${catIntegrante.cantidad}
    )''';

    final result = await db.rawInsert(sql);
    DataBaseCreator.dataBaseLog("agregar Integrantes", sql, null, result);
  }
  
  static Future<void> deleteAll() async{
    final sql = '''DELETE FROM ${DataBaseCreator.catIntegrantesTable}''';
    final result = await db.rawDelete(sql);
    DataBaseCreator.dataBaseLog("eliminar CatIntegrantes", sql, null , result);
  }
}