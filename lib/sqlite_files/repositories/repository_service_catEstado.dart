import 'package:sgcartera_app/sqlite_files/models/cat_estado.dart';

import '../database_creator.dart';

class RepositoryCatEstados{
  
  static Future<List<CatEstado>> getAllCatEstados() async{
    final sql = '''SELECT * FROM ${DataBaseCreator.catEstadosTable}''';

    final data = await db.rawQuery(sql);
    List<CatEstado> catEstados = List();
    for(final json in data){
      final catEstado = CatEstado.fromJson(json);
      catEstados.add(catEstado);
    }
    return catEstados;
  }

  static Future<void> addCatEstado(CatEstado catEstado) async{
    final sql = '''INSERT INTO ${DataBaseCreator.catEstadosTable}(
      ${DataBaseCreator.estado},
      ${DataBaseCreator.codigo}
    )VALUES(
      "${catEstado.estado}",
      "${catEstado.codigo}"
    )''';

    final result = await db.rawInsert(sql);
    DataBaseCreator.dataBaseLog("agregar Estado", sql, null, result);
  }

  static Future<void> deleteAll() async {
    final sql = '''DELETE FROM ${DataBaseCreator.catEstadosTable}''';
    final result = await db.rawDelete(sql);
    DataBaseCreator.dataBaseLog("eliminar CatEstados", sql, null , result);
  }
}