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

  static Future<List<DocumentoSolicitud>> getAllDocumentosSolicitudCambio() async{
    final sql = '''SELECT * FROM ${DataBaseCreator.documentoSolicitudesTable} 
      WHERE ${DataBaseCreator.cambioDoc} = 1 AND ${DataBaseCreator.documento} != "null"''';
    
    final data = await db.rawQuery(sql);
    List<DocumentoSolicitud> documentos = List();

    for(final node in data){
      final documentoSolicitud = DocumentoSolicitud.fromJson(node);
      documentos.add(documentoSolicitud);
    }

    return documentos;
  }

  static Future<bool> getOneDocumentosSolicitudCambio(int idSolicitud, int tipo) async{
    final sql = '''SELECT * FROM ${DataBaseCreator.documentoSolicitudesTable} 
      WHERE ${DataBaseCreator.idSolicitud} = $idSolicitud AND ${DataBaseCreator.tipoDocumento} = $tipo AND ${DataBaseCreator.cambioDoc} == 1''';
    
    final data = await db.rawQuery(sql);
    
    bool res = false;
    if(data.length>0) res = true;
    return res;
  }

  static Future<void> updateDocumentoSolicitud(DocumentoSolicitud documentoSolicitud) async{
    final sql = '''UPDATE ${DataBaseCreator.documentoSolicitudesTable} 
      SET ${DataBaseCreator.documento} = "${documentoSolicitud.documento}", ${DataBaseCreator.cambioDoc} = ${documentoSolicitud.cambioDoc}
      WHERE ${DataBaseCreator.tipoDocumento} = ${documentoSolicitud.tipo} 
      AND ${DataBaseCreator.id_Solicitud} = ${documentoSolicitud.idSolicitud} ''';
    
    final result = await db.rawUpdate(sql);
    DataBaseCreator.dataBaseLog("actualizar DocumentoSolcitud Archivo", sql, null, result);
  }

  static Future<void> updateDocumentoSolicitudCambio(DocumentoSolicitud documentoSolicitud) async{
    final sql = '''UPDATE ${DataBaseCreator.documentoSolicitudesTable} 
      SET ${DataBaseCreator.cambioDoc} = ${documentoSolicitud.cambioDoc}, ${DataBaseCreator.documento} = "${documentoSolicitud.documento}"
      WHERE ${DataBaseCreator.tipoDocumento} = ${documentoSolicitud.tipo} 
      AND ${DataBaseCreator.idDocumentoSolicitudes} = ${documentoSolicitud.idDocumentoSolicitud} ''';
    
    final result = await db.rawUpdate(sql);
    DataBaseCreator.dataBaseLog("actualizar DocumentoSolcitud ArchivoCambio", sql, null, result);
  }

  static Future<void> addDocumentoSolicitud(DocumentoSolicitud documentoSolicitud) async{
    final sql = '''INSERT INTO ${DataBaseCreator.documentoSolicitudesTable}(
      
      ${DataBaseCreator.id_Solicitud},
      ${DataBaseCreator.tipoDocumento},
      ${DataBaseCreator.documento},
      ${DataBaseCreator.version},
      ${DataBaseCreator.cambioDoc},
      ${DataBaseCreator.observacionCambio}
    )values(
      
      ${documentoSolicitud.idSolicitud},
      ${documentoSolicitud.tipo},
      "${documentoSolicitud.documento}",
      ${documentoSolicitud.version},
      ${documentoSolicitud.cambioDoc},
      "${documentoSolicitud.observacionCambio}"
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
