import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

Database db;

class DataBaseCreator{
  static const catDocumentosTable = 'catDocumentos';
  static const tipo = 'tipo';
  static const descDocumento = 'descDocumento';
  static const version = 'version';
  static const cambioDoc = 'cambioDoc';
  static const observacionCambio = 'observacionCambio';

  static const catIntegrantesTable = 'catIntegrantes';
  static const cantidadIntegrantes = 'cantidad';

  static const solicitudesTable = 'solicitudes';
  static const idSolicitud = 'idSolicitud';
  static const id_grupo = 'idGrupo';
  static const nombre_Grupo = 'nombreGrupo';
  static const importe = 'importe';
  static const nombrePrimero = 'nombrePrimero';
  static const nombreSegundo = 'nombreSegundo';
  static const apellidoPrimero = 'apellidoPrimero';
  static const apellidoSegundo = 'apellidoSegundo';
  static const fechaNacimiento = 'fechaNacimiento';
  static const fechaCaptura = 'fechaCaptura';
  static const curp = 'curp';
  static const rfc = 'rfc';
  static const telefono = 'telefono';
  static const tipoContrato = 'tipoContrato';

  static const direccion1 = 'direccion1';
  static const coloniaPoblacion = 'coloniaPoblacion';
  static const delegacionMunicipio = 'delegacionMunicipio';
  static const ciudad = 'ciudad';
  static const estado = 'estado';
  static const cp = 'cp';
  static const pais = 'pais';

  static const documentoSolicitudesTable = 'documentosSolicitudes';
  static const idDocumentoSolicitudes = 'idDocumentoSolicitud';
  static const id_Solicitud = 'idSolicitud';
  static const tipoDocumento = 'documentoSolicitudTipo';
  static const documento = 'documentoSolicitud';

  static const gruposTable = 'grupos';
  static const idGrupo = 'idGrupo';
  static const nombreGrupo = 'nombreGrupo';
  static const importe_grupo = 'importeTotal';
  static const cantidad = 'cantidadSolicitudes';

  static const catEstadosTable = 'catEstados';
  static const codigo = 'codigo';
  
  static const userID = 'userID';
  static const grupoID = 'grupoID';
  static const status = 'status';
  static const documentID = 'documentID';

  static const renovacionesTable = "renovaciones";
  static const idRenovacion = "idRenovacion";
  static const creditoID = "creditoID";
  static const clienteID = "clienteID";
  static const nombreCompleto = "nombreCompleto";
  static const capital = "capital";
  static const diasAtraso = "diasAtraso";
  static const beneficio = "beneficio";
  static const ticket = "ticket";
  static const nuevoImporte = "nuevoImporte";

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

  Future<void> createCatIntegrantesTable(Database db) async{
    final catIntegrantes = '''CREATE TABLE $catIntegrantesTable(
      $cantidadIntegrantes INTEGER
    )''';

    await db.execute(catIntegrantes);
  }

  Future<void> createCatEstadosTable(Database db) async{
    final catEstados = '''CREATE TABLE $catEstadosTable(
      $estado TEXT,
      $codigo TEXT
    )''';

    await db.execute(catEstados);
  }

  Future<void> createSolicitudesTable(Database db)async{
    final solicitudesSql = '''CREATE TABLE $solicitudesTable (
      $idSolicitud INTEGER PRIMARY KEY,
      $idGrupo INTEGER,
      $nombre_Grupo TEXT,
      $importe DOUBLE,
      $nombrePrimero TEXT,
      $nombreSegundo TEXT,
      $apellidoPrimero TEXT,
      $apellidoSegundo TEXT,
      $fechaNacimiento INTEGER,
      $curp TEXT,
      $rfc TEXT,
      $telefono TEXT,
      $status INTEGER,
      $tipoContrato INTEGER,
      $userID TEXT,
      $documentID TEXT,
      
      $direccion1 TEXT,
      $coloniaPoblacion TEXT,
      $delegacionMunicipio TEXT,
      $ciudad TEXT,
      $estado TEXT,
      $cp INTEGER,
      $pais TEXT,
      $fechaCaptura INTEGER
    )''';
    
    await db.execute(solicitudesSql);
  }

  Future<void> createDocumentosSolicitudTable(Database db)async{
    final solicitudesSql = '''CREATE TABLE $documentoSolicitudesTable (
      $idDocumentoSolicitudes INTEGER PRIMARY KEY,
      $id_Solicitud INTEGER,
      $tipoDocumento INTEGER,
      $documento TEXT,
      $version INT,
      $cambioDoc INT,
      $observacionCambio TEXT
    )''';
    
    await db.execute(solicitudesSql);
  }

  Future<void> createGruposTable(Database db)async{
    final solicitudesSql = '''CREATE TABLE $gruposTable (
      $idGrupo INTEGER PRIMARY KEY,
      $nombreGrupo TEXT,
      $status INTEGER,
      $userID TEXT,
      $grupoID TEXT,
      $importe_grupo DOUBLE,
      $cantidad INTEGER
    )''';
    
    await db.execute(solicitudesSql);
  }

  Future<void> createRenovacionesTable(Database db) async{
    final solicitudesSql = '''CREATE TABLE $renovacionesTable(
      $idRenovacion INTEGER PRIMARY KEY,
      $idGrupo INTEGER,
      $nombre_Grupo TEXT,
      $importe DOUBLE,
      $nombreCompleto TEXT,
      $creditoID INT,
      $clienteID TEXT,
      $capital DOUBLE,
      $diasAtraso INT,
      $beneficio TEXT,
      $ticket TEXT,
      $status INT,
      $userID TEXT,
      $tipoContrato INT,
      $nuevoImporte DOUBLE
    )''';

    await db.execute(solicitudesSql);
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
    await createSolicitudesTable(db);
    await createDocumentosSolicitudTable(db);
    await createGruposTable(db);
    await createCatIntegrantesTable(db);
    await createCatEstadosTable(db);
    await createRenovacionesTable(db);
  }

}