import 'package:sgcartera_app/sqlite_files/models/renovaciones.dart';

import '../database_creator.dart';

class ServiceRepositoryRenovaciones{

  static Future<List<Renovacion>> getAllRenovaciones(String userID) async{
    final sql = ''' SELECT * FROM ${DataBaseCreator.renovacionesTable}
      WHERE ${DataBaseCreator.userID} = "$userID" AND ${DataBaseCreator.status} = 0''';

    final data = await db.rawQuery(sql);
    List<Renovacion> solicitudes = List();

    for(final node in data){
      final solicitud = Renovacion.fromjson(node);
      solicitudes.add(solicitud);
    }
    return solicitudes;
  }

  static Future<void> updateRenovacionStatus(int status, int renovacionID) async{
    final sql = '''UPDATE ${DataBaseCreator.renovacionesTable}
      SET ${DataBaseCreator.status} = $status
      WHERE ${DataBaseCreator.idRenovacion} = $renovacionID ''';

    final result = await db.rawUpdate(sql);
    DataBaseCreator.dataBaseLog("actualizar Renovacion Status", sql, null, result);
  }
  
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
        ${DataBaseCreator.ticket},
        ${DataBaseCreator.status},
        ${DataBaseCreator.userID},
        ${DataBaseCreator.tipoContrato},
        ${DataBaseCreator.nuevoImporte}
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
        "${renovacion.ticket}",
        0,
        "${renovacion.userID}",
        ${renovacion.tipoContrato},
        ${renovacion.nuevoImporte}
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