import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';

import 'package:mime_type/mime_type.dart';
import 'package:sgcartera_app/models/backBlaze_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackBlaze{

  Firestore _firestore = Firestore.instance;
  DocumentSnapshot _datosBackBlaze;

  Future<B2GetUploadUrl> b2AuthorizeAccount(SharedPreferences pref) async{
    B2GetUploadUrl b2getUploadUrl = new B2GetUploadUrl();

    Query q = _firestore.collection("backBlazeKeys");
    QuerySnapshot querySnapshot = await q.getDocuments();

    if(querySnapshot.documents.length != 0){
      _datosBackBlaze = querySnapshot.documents[0];
      final String applicationKeyId = _datosBackBlaze.data['applicationKeyId'];
      final String applicationKey = _datosBackBlaze.data['applicationKey'];
      final String bucketId = _datosBackBlaze.data['bucketId'];

      var bytes = utf8.encode(applicationKeyId+":"+applicationKey);
      var base64Str = base64Encode(bytes);
      var bAuth = 'Basic '+base64Str;

      http.Response response = await http.get("https://api.backblazeb2.com/b2api/v2/b2_authorize_account",
        headers: <String, String>{'authorization':bAuth});
      
      await pref.setString("apiUrl", json.decode(response.body)['apiUrl']);
      await pref.setString("accountAuthorizationToken", json.decode(response.body)['authorizationToken']);
      await pref.setString("bucketId", bucketId);

      b2getUploadUrl.apiUrl = json.decode(response.body)['apiUrl'];
      b2getUploadUrl.accountAuthorizationToken = json.decode(response.body)['authorizationToken'];
      b2getUploadUrl.bucketId = bucketId;
    }

    return b2getUploadUrl;
  }

  Future<B2UploadFile> b2GetUploadUrl(SharedPreferences pref) async{
    B2UploadFile b2uploadFile = new B2UploadFile();

    var apiUrl = pref.getString("apiUrl");
    var accountAuthorizationToken = pref.getString("accountAuthorizationToken");
    var bucketId = pref.getString("bucketId");

    if(apiUrl == null || accountAuthorizationToken == null || bucketId == null){
      B2GetUploadUrl b2getUploadUrl = await b2AuthorizeAccount(pref);
      apiUrl = b2getUploadUrl.apiUrl;
      accountAuthorizationToken = b2getUploadUrl.accountAuthorizationToken;
      bucketId = b2getUploadUrl.bucketId;
    }

    http.Response response = await http.post(apiUrl + "/b2api/v2/b2_get_upload_url",
      headers: <String, String>{'authorization': accountAuthorizationToken},
      body: json.encoder.convert({"bucketId":bucketId}));

    await pref.setString("uploadUrl", json.decode(response.body)['uploadUrl']);
    await pref.setString("uploadAuthorizationToken", json.decode(response.body)['authorizationToken']);

    b2uploadFile.uploadUrl = json.decode(response.body)['uploadUrl'];
    b2uploadFile.uploadAuthorizationToken = json.decode(response.body)['authorizationToken'];

    return b2uploadFile;
  }

  Future<BackBlazeRequest> b2UploadFile(file) async {
    BackBlazeRequest result = new BackBlazeRequest();
    
    final pref = await SharedPreferences.getInstance();
    var uploadUrl = pref.getString("uploadUrl");
    var uploadAuthorizationToken = pref.getString("uploadAuthorizationToken");

    if(uploadUrl == null || uploadAuthorizationToken == null){
      B2UploadFile b2uploadFile = await b2GetUploadUrl(pref);
      uploadUrl = b2uploadFile.uploadUrl;
      uploadAuthorizationToken = b2uploadFile.uploadAuthorizationToken;
    }

    String mimeType = mime(path.basename(file.path));
    String ext = "."+mimeType.split("/")[1];
    var localFile = file; 
    var fileName = DateTime.now().millisecondsSinceEpoch.toString()+ext;//cambiar por nombre
    var contentType = mimeType ;
    
    Uint8List bytes = localFile.readAsBytesSync() as Uint8List;
    var _sha1 = sha1.convert(bytes);
    
    http.Response response = await http.post(uploadUrl,
      headers: <String, String>{
        'authorization': uploadAuthorizationToken,
        'X-Bz-File-Name': fileName,
        'Content-Type': contentType,
        'X-Bz-Content-Sha1': _sha1.toString(),
        'X-Bz-Info-author': "unknow"
      },
      body: bytes);

    if(response.statusCode == 200){
      result.mensaje = "Imagen Guardada";
      result.result = true;
      result.documentId = json.decode(response.body)['fileId'];
    }else if(response.statusCode == 401){
      await b2GetUploadUrl(pref);
      result = await b2UploadFile(localFile);
    }else{
      result.mensaje = "Error " + response.statusCode.toString();
      result.result = false;
    }
    
    return result;
  }

}