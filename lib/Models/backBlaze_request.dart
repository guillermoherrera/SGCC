class BackBlazeRequest{
  String documentId;
  bool result;
  String mensaje;

  BackBlazeRequest({
    this.mensaje,
    this.result,
    this.documentId
  });
}

class B2GetUploadUrl {
  String apiUrl;
  String accountAuthorizationToken;
  String bucketId;
  bool result;

  B2GetUploadUrl({
    this.accountAuthorizationToken,
    this.apiUrl,
    this.bucketId,
    this.result
  });    
}

class B2UploadFile{
  String uploadUrl;
  String uploadAuthorizationToken;
  bool result;

  B2UploadFile({
    this.result,
    this.uploadAuthorizationToken,
    this.uploadUrl
  });
}

