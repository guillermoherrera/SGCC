import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:mime_type/mime_type.dart';
import 'package:sgcartera_app/models/direccion.dart';
import 'package:sgcartera_app/models/documento.dart';
import 'package:sgcartera_app/models/grupo.dart';
import 'package:sgcartera_app/models/persona.dart';
import 'package:sgcartera_app/models/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/documentoSolicitud.dart';
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_documentoSolicitud.dart';
import 'package:path/path.dart' as path;
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sincroniza{
  List<Solicitud> solicitudes = List();
  Firestore _firestore = Firestore.instance;

  sincronizaDatos()async{
    
    try{
      final result = await InternetAddress.lookup('google.com');
    
      if (!result.isNotEmpty || !result[0].rawAddress.isNotEmpty) return null; 
    }catch(e){
      return null;
    }
    final pref = await SharedPreferences.getInstance();
    String userID = pref.getString("uid");
    
    await getSolcitudesespera(userID);
    
    List<String> gruposSinc = List();
    List<GrupoObj> gruposGuardados = List();
    List<Map> documentos;
    Persona persona;
    Direccion direccion;
    
    for(final solicitud in solicitudes){
      persona = new Persona(
        nombre: solicitud.nombrePrimero,
        nombreSegundo: solicitud.nombreSegundo,
        apellido: solicitud.apellidoPrimero,
        apellidoSegundo: solicitud.apellidoSegundo,
        curp: solicitud.curp,
        rfc: solicitud.rfc,
        fechaNacimiento: DateTime.fromMillisecondsSinceEpoch(solicitud.fechaNacimiento),
        telefono: solicitud.telefono
      );
    
      direccion = new Direccion(
        ciudad: solicitud.ciudad,
        coloniaPoblacion: solicitud.coloniaPoblacion,
        cp: solicitud.cp,
        delegacionMunicipio: solicitud.delegacionMunicipio,
        direccion1: solicitud.direccion1,
        estado: solicitud.estado,
        pais: solicitud.pais
      );

      documentos = [];
      await ServiceRepositoryDocumentosSolicitud.getAllDocumentosSolcitud(solicitud.idSolicitud).then((listaDocs){
        for(final doc in listaDocs){
          Documento documento = new Documento(tipo: doc.tipo, documento: doc.documento, version: doc.version);
          documentos.add(documento.toJson());
        }
      });

      await saveFireStore(documentos).then((lista) async{
        if(lista.length > 0){

          GrupoObj grupoObj = new GrupoObj();
          if(solicitud.idGrupo != null && !gruposSinc.contains(solicitud.nombreGrupo)){
            Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(solicitud.idGrupo);
            grupoObj = new GrupoObj(nombre: solicitud.nombreGrupo, status: 2, userID: solicitud.userID, importe: grupo.importe, integrantes: grupo.cantidad);
            if(grupo.grupoID == null){
              var result = await _firestore.collection("Grupos").add(grupoObj.toJson());
              await ServiceRepositoryGrupos.updateGrupoStatus(2, result.documentID, solicitud.idGrupo);
              grupoObj.grupoID = result.documentID;
            }else{
              grupoObj.grupoID = grupo.grupoID;
            }
            gruposSinc.add(grupoObj.nombre);
            gruposGuardados.add(grupoObj);
          }else if(solicitud.idGrupo != null && gruposSinc.contains(solicitud.nombreGrupo)){
            grupoObj.grupoID = gruposGuardados.firstWhere((grupo)=> grupo.nombre == solicitud.nombreGrupo).grupoID;
          }

          SolicitudObj solicitudObj = new SolicitudObj(
            persona: persona.toJson(),
            direccion: direccion.toJson(),
            importe: solicitud.importe,
            tipoContrato: solicitud.tipoContrato,
            userID: solicitud.userID,
            status: 1,
            grupoID: solicitud.idGrupo == null ? null : grupoObj.grupoID,
            grupoNombre: solicitud.idGrupo == null ? null : solicitud.nombreGrupo
          );

          solicitudObj.documentos = lista;   
          solicitudObj.fechaCaputra = DateTime.now();
          var result = await _firestore.collection("Solicitudes").add(solicitudObj.toJson());
          await ServiceRepositorySolicitudes.updateSolicitudStatus(1, solicitud.idSolicitud);
          //if(solicitudObj.grupoId != null) ServiceRepositoryGrupos.updateGrupoStatus(2, grupoObj.grupoID, solicitudObj.grupoId);
          print(result);

        }else{
          print("Class Sincroniza sincronizaDatos: Sin internet");
        }
      });
    
    }
    ///Consulta Cambios
    await getCambios(userID);
  }

  Future<List<Map>> saveFireStore(List<Map> listaDocs) async{
    FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
    try{
      for(var doc in listaDocs){
        String mimeType = mime(path.basename(doc['documento']));
        String ext = "."+mimeType.split("/")[1];
        StorageReference reference = _firebaseStorage.ref().child('Documentos').child(DateTime.now().millisecondsSinceEpoch.toString()+"_"+doc['tipo'].toString()+ext);
        StorageUploadTask uploadTask = reference.putFile(File(doc['documento']));
        StorageTaskSnapshot downloadUrl = await uploadTask.onComplete.timeout(Duration(seconds: 10));
        doc['documento'] = await downloadUrl.ref.getDownloadURL();
      }
    }catch(e){
      listaDocs = [];
    }
    return listaDocs;
  }

  getSolcitudesespera(userID) async{
    solicitudes = await ServiceRepositorySolicitudes.getAllSolicitudes(userID);
  }

  getCambios(userID) async{
    Query q = _firestore.collection("Solicitudes").where('status', isEqualTo: 6).where('userID', isEqualTo:userID);
    QuerySnapshot querySnapshot = await q.getDocuments().timeout(Duration(seconds: 10));
    
    for(DocumentSnapshot document in querySnapshot.documents){//querySnapshot.documents[0].documentID
      Solicitud solicitudAux = await ServiceRepositorySolicitudes.getOneSolicitudByDocumentID(document.documentID);
      if(solicitudAux == null){
        final int _id = await ServiceRepositorySolicitudes.solicitudesCount();
        final Solicitud solicitud = new Solicitud(
          idSolicitud: _id + 1,
          importe: document.data['importe'],
          nombrePrimero: document.data['persona']['nombre'],
          nombreSegundo: document.data['persona']['nombreSegundo'],
          apellidoPrimero: document.data['persona']['apellido'],
          apellidoSegundo: document.data['persona']['apellidoSegundo'],
          fechaNacimiento: document.data['persona']['fechaNacimiento'].millisecondsSinceEpoch,
          curp: document.data['persona']['curp'],
          rfc: document.data['persona']['rfc'],
          telefono:  document.data['persona']['telefono'],
          userID: userID,
          status: 6,
          tipoContrato: document.data['tipoContrato'],
          idGrupo: null,
          nombreGrupo: null,

          direccion1: document.data['direccion']['direccion1'],
          coloniaPoblacion: document.data['direccion']['coloniaPoblacion'],
          delegacionMunicipio: document.data['direccion']['delegacionMunicipio'],
          ciudad: document.data['direccion']['ciudad'],
          estado: document.data['direccion']['estado'],
          cp: document.data['direccion']['cp'],
          pais: document.data['direccion']['pais'],

          documentID: document.documentID
        );

        List<Map> listaDocs = List();
        for(final documento in document.data['documentos']){
          if(documento['solicitudCambio'] != null && documento['solicitudCambio'] == true){
            Documento docu = new Documento(tipo:documento['tipo'], documento: null, version: documento['version']);//creo falta la version
            listaDocs.add(docu.toJson());
          }
        }
        
        await ServiceRepositorySolicitudes.addSolicitudCambio(solicitud).then((_) async{
          for(var doc in listaDocs){
            final int _idD = await ServiceRepositoryDocumentosSolicitud.documentosSolicitudCount();
            final DocumentoSolicitud documentoSolicitud = new DocumentoSolicitud(
              idDocumentoSolicitud: _idD + 1,
              idSolicitud: solicitud.idSolicitud,
              tipo: doc['tipo'],
              documento: doc['documento'],
              version: doc['version'] 
            );//creo que falta version
            await ServiceRepositoryDocumentosSolicitud.addDocumentoSolicitud(documentoSolicitud);
          }
        });
      }
    }
  }
}