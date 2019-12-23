import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/Models/auth_res.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/sqlite_files/database_creator.dart';
import 'package:sgcartera_app/sqlite_files/models/cat_documento.dart';
import 'package:sgcartera_app/sqlite_files/models/cat_estado.dart';
import 'package:sgcartera_app/sqlite_files/models/cat_integrantes.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_catDocumento.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_catEstado.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_catIntegrantes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  Login({this.auth, this.onSingIn, this.colorTema});
  final AuthFirebase auth;
  final VoidCallback onSingIn;
  final MaterialColor colorTema;
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = new GlobalKey<FormState>();
  var email = TextEditingController();
  var pass = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool buttonEnabled = true;
  Firestore _firestore = Firestore.instance;
  AuthFirebase authFirebase = new AuthFirebase();
  DocumentSnapshot _datosCatalogo;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Iniciar Sesión"),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: Container(
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [widget.colorTema[100], Colors.white])
                ),
              ),
              Center(child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(),
                  child: Card(
                    color: Colors.white70,
                    margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 20.0,
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: Column(
                        children: formLogin(),
                      ),
                    ),
                  )
                )
              ))
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> formLogin(){
    return [
      Image.asset("images/adminconfia.png"),
      padded(
        childs: TextFormField(
          controller: email,
          decoration: InputDecoration(
            icon: Icon(Icons.alternate_email),
            labelText: "Correo"
          ),
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          validator: (value){ return value.isEmpty ? "Por favor ingresa tu correo" : null; },
        )
      ),
      padded(
        childs: TextFormField(
          controller: pass,
          obscureText: true,
          decoration: InputDecoration(
            icon: Icon(Icons.lock),
            labelText: "Contraseña"
          ),
          validator: (value){return value.isEmpty ? "Por favor ingresa tu contraseña" : null;},
        )
      ),
      Column(
        children: buttonWidget(),
      )
    ];
  }

  Widget padded({Widget childs}){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: childs,
    );
  }

  List<Widget> buttonWidget(){
    return[
      styleButton(buttonEnabled ? "Iniciar Sesión" : "Cargando ...", validateSubmit),
    ];
  }

  Widget styleButton(String text, VoidCallback onPress){
    return new RaisedButton(
      onPressed: buttonEnabled ? onPress : (){},
      color: widget.colorTema,
      textColor: Colors.white,
      child: Text(text),
    );
  }

  void validateSubmit() async{
    if(formKey.currentState.validate()){
      _buttonStatus();
      FocusScope.of(context).requestFocus(FocusNode());
      AuthRes authRes;
      authRes = await widget.auth.signIn(email.text, pass.text);
      if(authRes.result){
        final pref = await SharedPreferences.getInstance();
        await pref.setString("email", email.text);
        await pref.setString("pass", pass.text);
        await pref.setString("uid", authRes.uid);
        await getCatalogos();
        widget.onSingIn();
      }else{
        String mensaje = getMessage(authRes.mensaje);
        final snackBar = SnackBar(
          content: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
        _buttonStatus();
      }
    }
  }

  void _buttonStatus(){
    setState(() {
     buttonEnabled = buttonEnabled ? false : true;
    });
  }

  String getMessage(String word){
    if(word.contains("ERROR_INVALID_EMAIL")){
      return "El formato del correo no es correcto.";
    }else if(word.contains("Given String is empty or null")){
      return "Es necesario llenar los campos de correo y contraseña para iniciar sesión.";
    }else if(word.contains("ERROR_TOO_MANY_REQUESTS")){
      return "ATENCIÓN: Has intentado iniciar sesión demasiadas veces, intentalo de nuevo mas tarde o ponte en contacto con soporte.";
    }else if(word.contains("An internal error has occurred. [ 7: ]")){
      return "Error interno, revisa tu conexión a internet.";
    }else if(word.contains("TimeoutException")){
      return "Error interno, revisa tu conexión a internet.";
    }else{
      return "Correo y/o contraseña incorrectos.";
    }
  }

  Future<void> getCatalogos() async{
    QuerySnapshot querySnapshot;
    Query q;
    final pref = await SharedPreferences.getInstance();
    
    try{
      //Tipo de usuario
      q = _firestore.collection("UsuariosTipos").where('uid', isEqualTo: pref.getString('uid'));
      querySnapshot = await q.getDocuments();
      if(querySnapshot.documents.length > 0){
        pref.setInt("tipoUsuario",querySnapshot.documents[0].data['tipoUsuario']);
      }else{
        pref.setInt("tipoUsuario",0);
      }
      
      //catDocumentos
      await RepositoryServiceCatDocumento.deleteAll();
      q = _firestore.collection("catDocumentos").where('activo', isEqualTo: true);
      querySnapshot = await q.getDocuments();
      for (DocumentSnapshot value in querySnapshot.documents) {
        final catDocumento = CatDocumento(tipo: value.data['tipo'], descDocumento: value.data['descDocumento'] );
        await RepositoryServiceCatDocumento.addCatDocumento(catDocumento);
      }

      //catIntegrantes
      await RepositoryServiceCatIntegrantes.deleteAll();
      q = _firestore.collection("catIntegrantesGrupo").where('activo', isEqualTo: true);
      querySnapshot = await q.getDocuments();
      final catIntegrante = CatIntegrante(cantidad: querySnapshot.documents[0].data['cantidad']);
      await RepositoryServiceCatIntegrantes.addCatIntegrante(catIntegrante);

      //catEstados
      await RepositoryCatEstados.deleteAll();
      q = _firestore.collection("catEstados");
      querySnapshot = await q.getDocuments();
      for(DocumentSnapshot value in querySnapshot.documents){
        final catEstado = CatEstado(codigo: value.data['codigo'], estado: value.data['estado']);
        await RepositoryCatEstados.addCatEstado(catEstado);
      }
    }catch(e){
      pref.setInt("tipoUsuario",0);
    }

  }
}