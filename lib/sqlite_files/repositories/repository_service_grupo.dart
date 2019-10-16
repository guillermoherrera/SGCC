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

  static Future<int> gruposCount()async{
    final data = await db.rawQuery('''SELECT COUNT(*) FROM ${DataBaseCreator.gruposTable}''');
    int count = data[0].values.elementAt(0);
    return count;
  }
}