import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
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

  static Future<Solicitud> getOneSolicitud(int idSolicitud) async{
    final sql = ''' SELECT * FROM ${DataBaseCreator.solicitudesTable}
      WHERE ${DataBaseCreator.idSolicitud} = $idSolicitud''';

    final data = await db.rawQuery(sql);
    
    return Solicitud.fromJson(data[0]);
  }

  static Future<List<Solicitud>> getAllSolicitudesGrupo(String userID, String nombreGrupo) async{
    final sql = '''SELECT * FROM ${DataBaseCreator.solicitudesTable}
      WHERE ${DataBaseCreator.userID} = "$userID" AND ${DataBaseCreator.nombre_Grupo} = "$nombreGrupo"''';
    
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

  static Future<void> updateSolicitud(Solicitud solicitud) async{
    final sql = '''UPDATE ${DataBaseCreator.solicitudesTable}
      SET ${DataBaseCreator.importe} = ${solicitud.importe},
      ${DataBaseCreator.nombrePrimero} = "${solicitud.nombrePrimero}",
      ${DataBaseCreator.nombreSegundo} = "${solicitud.nombreSegundo}",
      ${DataBaseCreator.apellidoPrimero} = "${solicitud.apellidoPrimero}",
      ${DataBaseCreator.apellidoSegundo} = "${solicitud.apellidoSegundo}",
      ${DataBaseCreator.fechaNacimiento} = ${solicitud.fechaNacimiento},
      ${DataBaseCreator.curp} = "${solicitud.curp}",
      ${DataBaseCreator.rfc} = "${solicitud.rfc}",
      ${DataBaseCreator.telefono} = "${solicitud.telefono}",
      ${DataBaseCreator.id_grupo} = ${solicitud.idGrupo},
      ${DataBaseCreator.nombre_Grupo} = "${solicitud.nombreGrupo}",
      ${DataBaseCreator.userID} = "${solicitud.userID}",
      ${DataBaseCreator.status} = ${solicitud.status},
      ${DataBaseCreator.tipoContrato} = ${solicitud.tipoContrato}
      WHERE ${DataBaseCreator.idSolicitud} = ${solicitud.idSolicitud} ''';
    
    final result = await db.rawUpdate(sql);
    DataBaseCreator.dataBaseLog("actualizar Solcitud Completa", sql, null, result);
  }
  
  static Future<void> updateSolicitudStatus(int status, int solicitudID) async{
    final sql = '''UPDATE ${DataBaseCreator.solicitudesTable}
      SET ${DataBaseCreator.status} = $status
      WHERE ${DataBaseCreator.idSolicitud} = $solicitudID ''';

    final result = await db.rawUpdate(sql);
    DataBaseCreator.dataBaseLog("actualizar Solcitud Status", sql, null, result);
  }

  static Future<void> updateSolicitudGrupo(Grupo grupo)async{
    final sql = '''UPDATE ${DataBaseCreator.solicitudesTable}
      SET ${DataBaseCreator.nombre_Grupo} = "${grupo.nombreGrupo}"
      WHERE ${DataBaseCreator.id_grupo} = ${grupo.idGrupo}''';
    
    final result = await db.rawUpdate(sql);
    DataBaseCreator.dataBaseLog("actualizar Solcitud Status", sql, null, result);
  }

  static Future<void> deleteSolicitudCompleta(Solicitud solicitud) async{
    final sql = '''DELETE FROM ${DataBaseCreator.solicitudesTable}
      WHERE ${DataBaseCreator.idSolicitud} = ${solicitud.idSolicitud}''';
    final result = await db.rawDelete(sql);
    DataBaseCreator.dataBaseLog('eliminar Solicitud', sql, null, result);

    final sql2 = '''DELETE FROM ${DataBaseCreator.documentoSolicitudesTable}
      WHERE ${DataBaseCreator.id_Solicitud} = ${solicitud.idSolicitud}''';
    final result2 = await db.rawDelete(sql2);
    DataBaseCreator.dataBaseLog('eliminar SolicitudDocumento', sql2, null, result2); 
  }

  static Future<int> solicitudesCount() async{
    final data = await db.rawQuery('''SELECT COUNT(*) FROM ${DataBaseCreator.solicitudesTable}''');
    int count = data[0].values.elementAt(0);
    return count;
  }

}