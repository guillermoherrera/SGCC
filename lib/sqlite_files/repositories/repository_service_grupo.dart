import 'package:sgcartera_app/sqlite_files/models/grupo.dart';

import '../database_creator.dart';

class ServiceRepositoryGrupos{
  static Future<List<Grupo>> getAllGrupos(String userID) async{
    final sql = '''SELECT * FROM ${DataBaseCreator.gruposTable}
      WHERE ${DataBaseCreator.userID} = "$userID" AND ${DataBaseCreator.status} = 0''';
    
    final data = await db.rawQuery(sql);
    List<Grupo> grupos = List();
    
    for(final node in data){
      final grupo = Grupo.fromjson(node);
      grupos.add(grupo);
    }

    return grupos;
  }

  static Future<List<Grupo>> getAllGruposEspera(String userID) async{
    final sql = '''SELECT * FROM ${DataBaseCreator.gruposTable}
      WHERE ${DataBaseCreator.userID} = "$userID" AND ${DataBaseCreator.status} = 1''';
    
    final data = await db.rawQuery(sql);
    List<Grupo> grupos = List();
    
    for(final node in data){
      final grupo = Grupo.fromjson(node);
      grupos.add(grupo);
    }

    return grupos;
  }

  static Future<List<Grupo>> getAllGruposSync(String userID) async{
    final sql = '''SELECT * FROM ${DataBaseCreator.gruposTable}
      WHERE ${DataBaseCreator.userID} = "$userID" AND ${DataBaseCreator.status} = 2''';
    
    final data = await db.rawQuery(sql);
    List<Grupo> grupos = List();
    
    for(final node in data){
      final grupo = Grupo.fromjson(node);
      grupos.add(grupo);
    }

    return grupos;
  }

  static Future<Grupo> getOneGrupo(int idGrupo) async{
    final sql = '''SELECT * FROM ${DataBaseCreator.gruposTable}
      WHERE ${DataBaseCreator.idGrupo} = $idGrupo''';
    
    final data = await db.rawQuery(sql);

    return Grupo.fromjson(data[0]);
  }

  static Future<bool> validaGrupo(Grupo grupo) async{
    final sql = '''SELECT * FROM ${DataBaseCreator.gruposTable}
      WHERE ${DataBaseCreator.nombreGrupo} = "${grupo.nombreGrupo}"
      AND ${DataBaseCreator.userID} = "${grupo.userID}"''';
    
    final data = await db.rawQuery(sql);

    bool result = data.length == 0 ? true : false;
    return result;
  }
  
  static Future<void> addGrupo(Grupo grupo) async{
    final sql = '''INSERT INTO ${DataBaseCreator.gruposTable}(
      ${DataBaseCreator.idGrupo},
      ${DataBaseCreator.nombreGrupo},
      ${DataBaseCreator.status},
      ${DataBaseCreator.userID},
      ${DataBaseCreator.importe_grupo},
      ${DataBaseCreator.cantidad}
    )values(
      ${grupo.idGrupo},
      "${grupo.nombreGrupo}",
      ${grupo.status},
      "${grupo.userID}",
      0,
      0
    )''';

    final result = await db.rawInsert(sql);
    DataBaseCreator.dataBaseLog("agregar Grupo", sql, null, result);
  }

  static Future<void> updateGrupoNombre(Grupo grupo)async{
    final sql = '''UPDATE ${DataBaseCreator.gruposTable}
      SET ${DataBaseCreator.nombreGrupo} = "${grupo.nombreGrupo}"
      WHERE ${DataBaseCreator.idGrupo} = ${grupo.idGrupo}''';
    
    final result = await db.rawUpdate(sql);
    DataBaseCreator.dataBaseLog("actualiza Grupo Nombre", sql, null, result);
  }

  static Future<void> updateGrupoImpCant(Grupo grupo) async{
    final sql = '''UPDATE ${DataBaseCreator.gruposTable}
      SET ${DataBaseCreator.importe_grupo} = ${grupo.importe}, ${DataBaseCreator.cantidad} = ${grupo.cantidad}
      WHERE ${DataBaseCreator.idGrupo} = ${grupo.idGrupo}''';
    
    final result = await db.rawUpdate(sql);
    DataBaseCreator.dataBaseLog("actualiza cantidad e importe", sql, null, result);
  }

  static Future<void> updateGrupoStatus(int status, String grupoID, int idGrupo)async{
    final sql = '''UPDATE ${DataBaseCreator.gruposTable}
      SET ${DataBaseCreator.status} = $status, ${DataBaseCreator.grupoID} = "$grupoID"
      WHERE ${DataBaseCreator.idGrupo} = $idGrupo''';
    
    final result = await db.rawUpdate(sql);
    DataBaseCreator.dataBaseLog("actualizar Grupo Status", sql, null, result);
  }

  static Future<void> deleteGrupo(idGrupo)async{
    final sql = ''' DELETE FROM ${DataBaseCreator.gruposTable}
      WHERE ${DataBaseCreator.idGrupo} = $idGrupo''';
    
    final result = await db.rawDelete(sql);
    DataBaseCreator.dataBaseLog('eliminar Grupo', sql, null, result);
  }

  static Future<int> gruposCount()async{
    final data = await db.rawQuery('''SELECT COUNT(*) FROM ${DataBaseCreator.gruposTable}''');
    int count = data[0].values.elementAt(0);
    return count;
  }
}