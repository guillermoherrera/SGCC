import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgcartera_app/models/responses.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConsultaCartera{
  Firestore _firestore = Firestore.instance;
  DocumentSnapshot _datosApi;
  final String baseURL= "http://192.168.70.94:4000/cartera/";

  Future<ConsultaApiKey> getApiKey() async{
    ConsultaApiKey result = new ConsultaApiKey();

    final pref = await SharedPreferences.getInstance();
    final String apiKeyName = "APP Originacion";
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
        await pref.setString('apiKeyCartera', result.apiKey);
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

  Future<ContratosRequest> consultaContratos() async{
    ContratosRequest result = new ContratosRequest();
    final String action = "contratosAsesor";
    ConsultaApiKey consultaApiKey;
    final pref = await SharedPreferences.getInstance();
    var apiKey = pref.getString("apiKeyCartera");

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
        headers: <String, String>{'x-api-key': apiKey,'userID': 'kQu3MBgQbfUCNZovwCjmDJF27E53'}).timeout(Duration(seconds: 10));

        if(response.body.isEmpty){
          result.mensaje = "\nAPI ERROR.\nTOKEN NO AUTORIZADO. POR FAVOR VUELVA A INTENTARLO.";
          result.result = false;
          await pref.setString('tokenConsultaCurp', null);
        }else if(json.decode(response.body)['data'] != null){
          result.mensaje = "OK";
          result.result = true;
          result.contratos = List();
          for(Map contratoMap in json.decode(response.body)['data']){
            Contrato contrato = new Contrato(contratoId: int.parse(contratoMap['contratoId'].toString()), fechaTermina: contratoMap['fechaTermina'].toString(), nombreGeneral: contratoMap['nombreGeneral'].toString());
            result.contratos.add(contrato);
          }
          result.contratosCant = result.contratos.length; 
        }else{
          result.mensaje = "\n"+json.decode(response.body)['resultDesc'];
          result.result = false;
        }

      }catch(e){
        result.mensaje = "\nERROR AL CONSULTAR CON LA APLICACIÓN DE CONSULTA.\n\nPOR FAVOR REVISA TU CONEXIÓN A INTERNET O VUELVALO A INTENTAR MAS TARDE";
        result.result = false;
      }
    }

    return result;
  }

  Future<ContratoDetalleRequest> consultaContratoDetalle(contrato)async{
    ContratoDetalleRequest result = new ContratoDetalleRequest();
    final String action = "contratoDetalle";
    ConsultaApiKey consultaApiKey;
    final pref = await SharedPreferences.getInstance();
    var apiKey = pref.getString("apiKeyCartera");

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
        headers: <String, String>{'x-api-key': apiKey,'contrato': contrato.toString()}).timeout(Duration(seconds: 10));

        if(response.body.isEmpty){
          result.mensaje = "\nAPI ERROR.\nTOKEN NO AUTORIZADO. POR FAVOR VUELVA A INTENTARLO.";
          result.result = false;
          await pref.setString('tokenConsultaCurp', null);
        }else if(json.decode(response.body)['data'] != null){
          result.contrato = Contrato();
          result.mensaje = "OK";
          result.result = true;
          result.integrantes = List();
          for(Map contratoMap in json.decode(response.body)['data']['integrantes']){
            Integrante integrante = new Integrante(cveCliente: contratoMap['cveCli'], importe: double.parse(contratoMap['importeT'].toString()), nombreCompleto: contratoMap['nombreCom'], telefono: contratoMap['telefonoCel']);
            result.integrantes.add(integrante);
          }
          var data = json.decode(response.body)['data'];
          result.contrato.fechaTermina = data['fechaTermina'].toString();
          result.contrato.fechaInicio = data['fechaInicio'].toString();
          result.contrato.importe = double.parse(data['importe'].toString());
          result.contrato.saldoActual = double.parse(data['saldoActual'].toString());
          result.contrato.saldoAtrazado = double.parse(data['saldoAtrazado'].toString());
          result.contrato.diasAtrazo = int.parse(data['diasAtrazo'].toString());
          result.contrato.pagoXPlazo = double.parse(data['pagoXPlazo'].toString());
          result.contrato.ultimoPagoPlazo = int.parse(data['ultimoPlazoPag'].toString());
          result.contrato.plazos = int.parse(data['plazos'].toString());
          result.contrato.capital = double.parse(data['capital'].toString());
          result.contrato.interes = double.parse(data['interes'].toString());
          result.contrato.status = data['status'].toString();
          result.contrato.contacto = data['contacto'].toString();
          result.contrato.integrantesCant = int.parse(data['integrantesCant'].toString()); 
        }else{
          result.mensaje = "\n"+json.decode(response.body)['resultDesc'];
          result.result = false;
        }

      }catch(e){
        result.mensaje = "\nERROR AL CONSULTAR CON LA APLICACIÓN DE CONSULTA.\n\nPOR FAVOR REVISA TU CONEXIÓN A INTERNET O VUELVALO A INTENTAR MAS TARDE";
        result.result = false;
      }
    }
    return result;
  }

  Future<IntegranteDetalleRequest> consultaIntegranteDetalle(contrato, cveCliente)async{
    IntegranteDetalleRequest result = new IntegranteDetalleRequest();
    final String action = "creditoDetalle";
    ConsultaApiKey consultaApiKey;
    final pref = await SharedPreferences.getInstance();
    var apiKey = pref.getString("apiKeyCartera");

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
        headers: <String, String>{'x-api-key': apiKey,'contrato': contrato.toString(), 'cveCliente': cveCliente}).timeout(Duration(seconds: 10));

        if(response.body.isEmpty){
          result.mensaje = "\nAPI ERROR.\nTOKEN NO AUTORIZADO. POR FAVOR VUELVA A INTENTARLO.";
          result.result = false;
          await pref.setString('tokenConsultaCurp', null);
        }else if(json.decode(response.body)['data'] != null){
          result.mensaje = "OK";
          result.result = true;
          var data = json.decode(response.body)['data'];
          result.integrante = Integrante(
            cveCliente: cveCliente,
            importe: double.parse(data['importeT'].toString()),
            //nombreCompleto: data['nombreCompleto'].toString(),
            //telefono: data['telCel'].toString(),
            capital: double.parse(data['capital'].toString()),
            diasAtrazo: int.parse(data['diaAtr'].toString()),
            fechaTermina: data['fechaTermina'].toString(),
            fechaUltimoPago: data['fechaUltimoPago'].toString(),
            folio: int.parse(data['folio'].toString()),
            interes: double.parse(data['interes'].toString()),
            noCda: int.parse(data['noCda'].toString()),
            pagos: int.parse(data['pagos'].toString()),
            saldoActual: double.parse(data['saldoActual'].toString()),
            saldoAtrazado: double.parse(data['salAtr'].toString())
          );
        }else{
          result.mensaje = "\n"+json.decode(response.body)['resultDesc'];
          result.result = false;
        }
      }catch(e){
        result.mensaje = "\nERROR AL CONSULTAR CON LA APLICACIÓN DE CONSULTA.\n\nPOR FAVOR REVISA TU CONEXIÓN A INTERNET O VUELVALO A INTENTAR MAS TARDE";
        result.result = false;
      }
    }
    return result;
  }
}