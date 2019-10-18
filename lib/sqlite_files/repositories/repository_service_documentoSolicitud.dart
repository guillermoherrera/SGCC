import 'package:sgcartera_app/sqlite_files/models/documentoSolicitud.dart';

import '../database_creator.dart';

class ServiceRepositoryDocumentosSolicitud{

  static Future<List<DocumentoSolicitud>> getAllDocumentosSolcitud(int solicitudId) async{
    final sql = '''SELECT * FROM ${DataBaseCreator.documentoSolicitudesTable} 
      WHERE ${DataBaseCreator.id_Solicitud} = $solicitudId''';
    
    final data = await db.rawQuery(sql);
    List<DocumentoSolicitud> documentos = List();

    for(final node in data){
      final documentoSolicitud = DocumentoSolicitud.fromJson(node);
      documentos.add(documentoSolicitud);
    }

    return documentos;
  }

  static Future<void> updateDocumentoSolicitud(DocumentoSolicitud documentoSolicitud) async{
    final sql = '''UPDATE ${DataBaseCreator.documentoSolicitudesTable} 
      SET ${DataBaseCreator.documento} = "${documentoSolicitud.documento}"
      WHERE ${DataBaseCreator.tipoDocumento} = ${documentoSolicitud.tipo} 
      AND ${DataBaseCreator.id_Solicitud} = ${documentoSolicitud.idSolicitud} ''';
    
    final result = await db.rawUpdate(sql);
    DataBaseCreator.dataBaseLog("actualizar DocumentoSolcitud Archivo", sql, null, result);
  }

  static Future<void> addDocumentoSolicitud(DocumentoSolicitud documentoSolicitud) async{
    final sql = '''INSERT INTO ${DataBaseCreator.documentoSolicitudesTable}(
      ${DataBaseCreator.idDocumentoSolicitudes},
      ${DataBaseCreator.id_Solicitud},
      ${DataBaseCreator.tipoDocumento},
      ${DataBaseCreator.documento}
    )values(
      ${documentoSolicitud.idDocumentoSolicitud},
      ${documentoSolicitud.idSolicitud},
      ${documentoSolicitud.tipo},
      "${documentoSolicitud.documento}"
    )''';

    final result = await db.rawInsert(sql);
    DataBaseCreator.dataBaseLog("agregar documentoSolcitud", sql, null, result);
  }

  static Future<int> documentosSolicitudCount() async{
    final data = await db.rawQuery('''SELECT COUNT(*) FROM ${DataBaseCreator.documentoSolicitudesTable}''');
    int count = data[0].values.elementAt(0);
    return count;
  }

}
