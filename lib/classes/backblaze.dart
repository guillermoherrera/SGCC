import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';

import 'package:mime_type/mime_type.dart';

class BackBlaze{

  Future<String> b2AuthorizeAccount() async{
    final String applicationKeyId = "000dda8ac4349d00000000002";
    final String applicationKey = "K000Ik4ZWbksJmEAz4q2MjQIf0eKnt0";

    var bytes = utf8.encode(applicationKeyId+":"+applicationKey);
    var base64Str = base64Encode(bytes);
    var bAuth = 'Basic '+base64Str;

    http.Response res = await http.get("https://api.backblazeb2.com/b2api/v2/b2_authorize_account",
      headers: <String, String>{'authorization':bAuth});
    
    print(res);

    var respuesta = json.decode(res.body);

    return "";
  }

  Future<String> b2GetUploadUrl() async{
    var apiUrl = "https://api000.backblazeb2.com" ;
    var accountAuthorizationToken = "4_000dda8ac4349d00000000002_018f5875_14a18d_acct_QiFtM1oRGdE5QpHw69IkINsVkX4="; 
    var bucketId = "8ded7a684a0c947364d90d10";

    http.Response response = await http.post(apiUrl + "/b2api/v2/b2_get_upload_url",
      headers: <String, String>{'authorization': accountAuthorizationToken},
      body: json.encoder.convert({"bucketId":bucketId}));

    return "";
  }

  Future<String> b2UploadFile(file) async {
    
    String mimeType = mime(path.basename(file.path));
    
    String ext = "."+mimeType.split("/")[1];
    var uploadUrl = "https://pod-000-1061-14.backblaze.com/b2api/v2/b2_upload_file/8ded7a684a0c947364d90d10/c000_v0001061_t0030";
    var localFile = file; 
    var uploadAuthorizationToken = "4_000dda8ac4349d00000000002_018f58f0_78389d_upld_DSBqzqojxlRkE6IAolqT7spFN1Q=";
    var fileName = "imagenPrueba"+ext;//cambiar por nombre
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
    
    //response.statusCode == 200;

    var respuesta = json.decode(response.body);
    return "";
  }

}