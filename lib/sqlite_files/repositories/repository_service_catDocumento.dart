import 'package:sgcartera_app/sqlite_files/models/cat_documento.dart';

import '../database_creator.dart';

class RepositoryServiceCatDocumento{
  
  static Future<List<CatDocumento>> getAllCatDocumentos() async{
    final sql = '''SELECT * FROM ${DataBaseCreator.catDocumentosTable}''';

    final data = await db.rawQuery(sql);
    List<CatDocumento> catDocumentos = List();

    for(final node in data){
      final catDocumento = CatDocumento.fromJson(node);
      catDocumentos.add(catDocumento);
    }
    return catDocumentos;
  }

  static Future<void> addCatDocumento(CatDocumento catDocumento) async{
    final sql = '''INSERT INTO ${DataBaseCreator.catDocumentosTable}(
      ${DataBaseCreator.tipo},
      ${DataBaseCreator.descDocumento}
    )VALUES(
      ${catDocumento.tipo},
      "${catDocumento.descDocumento}"
    )''';

    final result = await db.rawInsert(sql);
    DataBaseCreator.dataBaseLog("agregar CatDocumento", sql, null, result);
  }

  static Future<int> catDocumentosCount() async{
    final data = await db.rawQuery('''SELECT COUNT(*) FROM ${DataBaseCreator.catDocumentosTable}''');
    int count = data[0].values.elementAt(0);
    return count;
  }

  static Future<void> deleteAll() async{
    final sql = '''DELETE FROM ${DataBaseCreator.catDocumentosTable}''';
    final result = await db.rawDelete(sql);
    DataBaseCreator.dataBaseLog('eliminar CatDocumentos', sql, null, result);
  }

}