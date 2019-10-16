import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';

import '../database_creator.dart';

class ServiceRepositorySolicitudes{
  static Future<List<Solicitud>> getAllSolicitudes(String userID) async{
    final sql = ''' SELECT * FROM ${DataBaseCreator.solicitudesTable}
      WHERE ${DataBaseCreator.userID} = "$userID" AND ${DataBaseCreator.status} = 0''';

    final data = await db.rawQuery(sql);
    List<Solicitud> solicitudes = List();

    for(final node in data){
      final solicitud = Solicitud.fromJson(node);
      solicitudes.add(solicitud);
    }
    return solicitudes;
  }

  static Future<void> addSolicitud(Solicitud solicitud) async{
    final sql = '''INSERT INTO ${DataBaseCreator.solicitudesTable}(
      ${DataBaseCreator.importe},
      ${DataBaseCreator.nombrePrimero},
      ${DataBaseCreator.nombreSegundo},
      ${DataBaseCreator.apellidoPrimero},
      ${DataBaseCreator.apellidoSegundo},
      ${DataBaseCreator.fechaNacimiento},
      ${DataBaseCreator.curp},
      ${DataBaseCreator.rfc},
      ${DataBaseCreator.telefono},
      ${DataBaseCreator.id_grupo},
      ${DataBaseCreator.nombre_Grupo},
      ${DataBaseCreator.userID},
      ${DataBaseCreator.status},
      ${DataBaseCreator.tipoContrato}
    )values(
      ${solicitud.importe},
      "${solicitud.nombrePrimero}",
      "${solicitud.nombreSegundo}",
      "${solicitud.apellidoPrimero}",
      "${solicitud.apellidoSegundo}",
      ${solicitud.fechaNacimiento},
      "${solicitud.curp}",
      "${solicitud.rfc}",
      "${solicitud.telefono}",
      ${solicitud.idGrupo},
      "${solicitud.nombreGrupo}",
      "${solicitud.userID}",
      ${solicitud.status},
      ${solicitud.tipoContrato}
    )
    ''';

    final result = await db.rawInsert(sql);
    DataBaseCreator.dataBaseLog("agregar Solcitud", sql, null, result);
  }

  static Future<void> updateSolicitudStatus(int status, int solicitudID) async{
    final sql = '''UPDATE ${DataBaseCreator.solicitudesTable}
      SET ${DataBaseCreator.status} = $status
      WHERE ${DataBaseCreator.idSolicitud} = $solicitudID ''';

    final result = await db.rawUpdate(sql);
    DataBaseCreator.dataBaseLog("actualizar Solcitud", sql, null, result);
  }

  static Future<int> solicitudesCount() async{
    final data = await db.rawQuery('''SELECT COUNT(*) FROM ${DataBaseCreator.solicitudesTable}''');
    int count = data[0].values.elementAt(0);
    return count;
  }

}