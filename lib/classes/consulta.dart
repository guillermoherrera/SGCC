import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:sgcartera_app/models/curp_request.dart';
import 'package:sgcartera_app/models/persona.dart';
import 'package:sgcartera_app/models/responses.dart';
import 'package:sgcartera_app/models/solicitud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Consulta{

  Firestore _firestore = Firestore.instance;
  DocumentSnapshot _datosApi;
  //final String baseURL= "http://192.168.70.94:82/v1.0/";
  final String baseURL= "http://192.168.70.94:3000/consulta/";

  Future<ConsultaToken> getTokenConsulta() async{
    ConsultaToken result = new ConsultaToken();
    
    final pref = await SharedPreferences.getInstance();
    final String action = "login";
    final String apiKeyName = "API_CONSULTA";
    String user, keys;

    var map = new Map<String, dynamic>();
    
    try{
      Query q = _firestore.collection("apiConsultaKeys").where("apiKeyName", isEqualTo: apiKeyName);
      QuerySnapshot querySnapshot = await q.getDocuments().timeout(Duration(seconds: 10));

      if(querySnapshot.documents.length != 0){
        _datosApi = querySnapshot.documents[0];
        user = _datosApi.data['user'];
        keys = _datosApi.data['key'];
      }
      map['usuario'] = user;
      map['password'] = keys;

      http.Response response = await http.post(baseURL+action,
        body: map
      ).timeout(Duration(seconds: 10));
      print(json.decode(response.body));
      if(json.decode(response.body)['resultCode'] == 0){
        result.result = true;
        result.mensaje = json.decode(response.body)['resultDesc'];
        result.token = json.decode(response.body)['token'];
        await pref.setString('tokenConsultaCurp', result.token);
      }else{
        result.result = false;
        result.mensaje = "\nAPI ERROR.\n"+json.decode(response.body)['resultDesc'];
      }
    }catch(e){
      print("Error:");
      result.result = false;
      result.mensaje = "\nERROR AL CONECTAR CON LA APLICACIÓN DE CONSULTA.\n\nPOR FAVOR REVISA TU CONEXIÓN A INTERNET";
    }
    
    return result;
  }

  Future<CurpRequest> consultaCurp2(curp) async{
    CurpRequest result = new CurpRequest();
    final String action = "secure/consulta/curp/";
    
    ConsultaToken consultaToken;
    final pref = await SharedPreferences.getInstance();
    var token = pref.getString("tokenConsultaCurp");
    
    if(token == null){
      consultaToken = await getTokenConsulta();
      token = consultaToken.token;
    }

    if(token == null){
      result.mensaje = consultaToken.mensaje;
      result.result = false;
    }else{
      try{
        http.Response response = await http.get(baseURL+action+curp,
        headers: <String, String>{'authorization': "Bearer "+token}).timeout(Duration(seconds: 10));
        
        if(response.body.isEmpty){
          result.mensaje = "\nAPI ERROR.\nTOKEN NO AUTORIZADO. POR FAVOR VUELVA A INTENTARLO.";
          result.result = false;
          await pref.setString('tokenConsultaCurp', null);
        }else if(json.decode(response.body)['data'] != null){
          Persona persona = new Persona(
            nombre: json.decode(response.body)['data']['primerNombre'],
            nombreSegundo: json.decode(response.body)['data']['segundoNombre'],
            apellido: json.decode(response.body)['data']['apellidoPaterno'],
            apellidoSegundo: json.decode(response.body)['data']['apellidoMaterno'],
            rfc: json.decode(response.body)['data']['rfc'],
            fechaNacimiento: DateTime.parse(json.decode(response.body)['data']['fechaNacimiento'])
          );
          SolicitudObj solicitudObj = new SolicitudObj(persona: persona.toJson());
          result.datos = solicitudObj;
          result.mensaje = "\nCONSULTA EXITOSA\n\nATENCION: ESTE CLIENTE TIENE " + json.decode(response.body)['data']['creditosActivos'].toString() + " CREDITOS ACTIVOS";
          result.result = true;
        }else{
          result.mensaje = "\n"+json.decode(response.body)['resultDesc'];
          result.result = false;
        }
      }catch(e){
        result.mensaje = "\nERROR AL CONECTAR CON LA APLICACIÓN DE CONSULTA.\n\nPOR FAVOR REVISA TU CONEXIÓN A INTERNET";
        result.result = false;
      }
    }

    return result;
  }

  Future<CurpRequest> consultaCurp(curp) async{
    CurpRequest result = CurpRequest();
    final String action = "curp";

    ConsultaApiKey consultaApiKey;
    final pref = await SharedPreferences.getInstance();
    var apiKey = pref.getString("apiKeyConsulta");

    if(apiKey == null){
      consultaApiKey = await getApiKey();
      apiKey = consultaApiKey.apiKey;
    }

    if(apiKey == null){
      result.mensaje = consultaApiKey.mensaje;
      result.result = false;
    }else{
      try{
        http.Response response = await http.get(baseURL+action,
          headers: <String, String>{'x-api-key': apiKey,'curp': curp});
        
        if(response.body.isEmpty){
          result.mensaje = "\nAPI ERROR.\n POR FAVOR VUELVA A INTENTARLO.";
          result.result = false;
          await pref.setString('apiKeyConsulta', null);
        }else if(json.decode(response.body)['data'] != null){
          if(json.decode(response.body)['data']['primerNombre'] != null){
            Persona persona = new Persona(
              nombre: json.decode(response.body)['data']['primerNombre'],
              nombreSegundo: json.decode(response.body)['data']['segundoNombre'],
              apellido: json.decode(response.body)['data']['apellidoPaterno'],
              apellidoSegundo: json.decode(response.body)['data']['apellidoMaterno'],
              rfc: json.decode(response.body)['data']['rfc'],
              fechaNacimiento: DateTime.parse(json.decode(response.body)['data']['fechaNacimiento']),
              telefono: json.decode(response.body)['data']['telefono'].replaceAll(new RegExp(r'[^\w\s]+'),'')
            );
            SolicitudObj solicitudObj = new SolicitudObj(persona: persona.toJson());
            result.datos = solicitudObj;
            result.mensaje = "\nCONSULTA EXITOSA, CLIENTE EXISTENTE.\n\nATENCION: ESTE CLIENTE TIENE " + json.decode(response.body)['data']['creditosActivos'].toString() + " CREDITOS ACTIVOS";
            result.result = true;
          }else{
            result.mensaje = "\nCONSULTA EXITOSA, CLIENTE NO EXISTENTE.";
            result.result = false;
          }
        }else{
          result.mensaje = "\n"+json.decode(response.body)['resultDesc'];
          result.result = false;
        }
      }catch(e){
        result.mensaje = "\nERROR AL CONECTAR CON LA APLICACIÓN DE CONSULTA.\n\nPOR FAVOR REVISA TU CONEXIÓN A INTERNET";
        result.result = false;
      }
    }
    return result;
  }

  Future<ConsultaApiKey> getApiKey() async{
    ConsultaApiKey result = new ConsultaApiKey();

    final pref = await SharedPreferences.getInstance();
    final String apiKeyName = "API_CONSULTA";
    String apiKey;

    try{
      Query q = _firestore.collection("apiConsultaKeys").where("apiKeyName", isEqualTo: apiKeyName);
      QuerySnapshot querySnapshot = await q.getDocuments().timeout(Duration(seconds: 10));

      if(querySnapshot.documents.length != 0){
        _datosApi = querySnapshot.documents[0];
        apiKey = _datosApi.data['apiKey'];
        
        result.result = true;
        result.mensaje = "El apiKey fue Obtenida";
        result.apiKey = apiKey;
        await pref.setString('apiKeyConsulta', result.apiKey);
      }else{
        result.result = false;
        result.mensaje = "\nAPI ERROR.\n No se obtuvo el apiKey";
      }
    }catch(e){
      print("Error:");
      result.result = false;
      result.mensaje = "\nERROR AL CONECTAR CON LA APLICACIÓN DE CONSULTA.\n\nPOR FAVOR REVISA TU CONEXIÓN A INTERNET";
    }

    return result;
  }

}