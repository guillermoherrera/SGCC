import 'package:sgcartera_app/sqlite_files/models/renovaciones.dart';

import '../database_creator.dart';

class ServiceRepositoryRenovaciones{
  
  static Future<List<Renovacion>> getRenovacionesFromGrupo(int idGrupo)async{
    final sql = '''SELECT * FROM ${DataBaseCreator.renovacionesTable}
      where ${DataBaseCreator.idGrupo} = $idGrupo''';

    final data = await db.rawQuery(sql);
    List<Renovacion> renovaciones = List();

    for(final node in data){
      final renovacion = Renovacion.fromjson(node);
      renovaciones.add(renovacion); 
    }

    return renovaciones;
  }

  static Future<void> addRenovacion(Renovacion renovacion)async{
    final sql = '''INSERT INTO ${DataBaseCreator.renovacionesTable}(
        ${DataBaseCreator.idRenovacion},
        ${DataBaseCreator.idGrupo},
        ${DataBaseCreator.nombre_Grupo},
        ${DataBaseCreator.importe},
        ${DataBaseCreator.nombreCompleto},
        ${DataBaseCreator.creditoID},
        ${DataBaseCreator.clienteID},
        ${DataBaseCreator.capital},
        ${DataBaseCreator.diasAtraso},
        ${DataBaseCreator.beneficio},
        ${DataBaseCreator.ticket}
      )values(
        ${renovacion.idRenovacion},
        ${renovacion.idGrupo},
        "${renovacion.nombreGrupo}",
        ${renovacion.importe},
        "${renovacion.nombreCompleto}",
        ${renovacion.creditoID},
        ${renovacion.clienteID},
        ${renovacion.capital},
        ${renovacion.diasAtraso},
        "${renovacion.beneficio}",
        "${renovacion.ticket}"
      )''';

    final result = await db.rawInsert(sql);
    DataBaseCreator.dataBaseLog("agregar Renovación", sql, null, result);
  }

  static Future<int> renovacionesCount()async{
    final data = await db.rawQuery('''SELECT COUNT(*) FROM ${DataBaseCreator.renovacionesTable}''');
    int count = data[0].values.elementAt(0);
    return count;
  }
  
}