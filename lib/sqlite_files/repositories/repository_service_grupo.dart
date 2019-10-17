import 'package:sgcartera_app/sqlite_files/models/grupo.dart';

import '../database_creator.dart';

class ServiceRepositoryGrupos{
  static Future<List<Grupo>> getAllGrupos(String userID) async{
    final sql = '''SELECT * FROM ${DataBaseCreator.gruposTable}
      WHERE ${DataBaseCreator.userID} = "$userID"''';
    
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
  
  static Future<void> addGrupo(Grupo grupo) async{
    final sql = '''INSERT INTO ${DataBaseCreator.gruposTable}(
      ${DataBaseCreator.idGrupo},
      ${DataBaseCreator.nombreGrupo},
      ${DataBaseCreator.status},
      ${DataBaseCreator.userID}
    )values(
      ${grupo.idGrupo},
      "${grupo.nombreGrupo}",
      ${grupo.status},
      "${grupo.userID}"
    )''';

    final result = await db.rawInsert(sql);
    DataBaseCreator.dataBaseLog("agregar Grupo", sql, null, result);
  }

  static Future<void> updateGrupoStatus(int status, int grupoID)async{
    final sql = '''UPDATE ${DataBaseCreator.gruposTable}
      SET ${DataBaseCreator.status} = $status
      WHERE ${DataBaseCreator.idGrupo} = $grupoID''';
    
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