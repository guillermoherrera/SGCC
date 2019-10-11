import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

Database db;

class DataBaseCreator{
  static const catDocumentosTable = 'catDocumentos';
  static const tipo = 'tipo';
  static const descDocumento = 'descDocumento';

  static void dataBaseLog(String functionName, String sql, [List<Map<String, dynamic>> selectedQueryResult, int insertAndUpdateQueryResult]){
    print(functionName);
    print(sql);
    if(selectedQueryResult != null){
      print(selectedQueryResult);
    }else if(insertAndUpdateQueryResult != null){
      print(insertAndUpdateQueryResult);
    }
  }

  Future<void> createCatDocumentosTable(Database db)async{
    final catDocumentoSql = '''CREATE TABLE $catDocumentosTable (
      $tipo INTEGER PRIMARY KEY,
      $descDocumento TEXT
    )''';

    await db.execute(catDocumentoSql);
  }

  Future<String> getDataBasePath(String dbName)async{
    final dataBasePath = await getDatabasesPath();
    final path = join(dataBasePath, dbName);

    if(await Directory(dirname(path)).exists()){
      //await deleteDatabase(path);
    }else{
      await Directory(dirname(path)).create(recursive: true);
    }
    return path;
  }

  Future<void> initDataBase() async{
    final path = await getDataBasePath('PCOriginacion');
    db = await openDatabase(path, version:1, onCreate: onCreate);
    print(db);
  }

  Future<void> onCreate(Database db, int version) async{
    await createCatDocumentosTable(db);
  }

}