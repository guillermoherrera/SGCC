import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:responsive_container/responsive_container.dart';
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
  final Color colorTema;
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
  double paddingTop = 50;
  bool obscureText1 = true;
  
  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;
    if(isLandscape){
      setState(() { paddingTop = 5;});
    }else{
      setState(() { paddingTop = 50;});
    }
    return Scaffold(
      key: _scaffoldKey,
      /*appBar: AppBar(
        title: Text("Iniciar Sesión"),
        centerTitle: true,
        backgroundColor: Color(0xff76BD21),
      ),*/
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
                  colors: [Colors.white, Colors.white])
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ResponsiveContainer(
                      heightPercent: 40.0,
                      widthPercent: 100.0,
                      child: Container(decoration: BoxDecoration(
                          gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [widget.colorTema, widget.colorTema])
                        ), child: Image.asset("images/adminconfia.png", color: Colors.white),
                      )
                    ),
                    ResponsiveContainer(
                      heightPercent: 60.0,
                      widthPercent: 100.0,
                      child: SingleChildScrollView(child: Container(decoration: BoxDecoration(
                          gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Colors.white, Colors.white])
                        ), child: Column(children: formLogin())
                      ))
                    ),
                  ]
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> formLogin(){
    return [
      //Image.asset("images/adminconfia.png"),
      padded(
        childs: TextFormField(
          controller: email,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.account_circle),
            labelText: "Usuario o correo",
            fillColor: Color(0xfff2f2f2),
            filled: true,
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
          ),
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          validator: (value){ return value.isEmpty ? "Por favor ingresa tu correo" : null; },
        )
      ),
      padded(
        childs: TextFormField(
          controller: pass,
          obscureText: obscureText1,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock),
            labelText: "Contraseña",
            fillColor: Color(0xfff2f2f2),
            filled: true,
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            suffixIcon: IconButton(icon: Icon(Icons.remove_red_eye), onPressed: (){setState(() {obscureText1 = !obscureText1;});})
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
      padding: EdgeInsets.fromLTRB(20, paddingTop, 20, 20),//EdgeInsets.symmetric(vertical: 8.0),
      child: childs,
    );
  }

  List<Widget> buttonWidget(){
    return[
      styleButton(buttonEnabled ? "INICIAR SESIÓN" : "VERIFICANDO, POR FAVOR ESPERE ...", validateSubmit),
    ];
  }

  Widget styleButton(String text, VoidCallback onPress){
    return Padding(padding: EdgeInsets.fromLTRB(10, paddingTop, 20, 0),child: SizedBox(width: double.infinity, child: new RaisedButton(
      onPressed: buttonEnabled ? onPress : (){},
      color: Color(0xfff2f2f2),
      textColor: widget.colorTema,
      child: FittedBox(fit:BoxFit.fitWidth, child: Text(text, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))),
      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0))
    )));
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
    }else if(word.contains("ERROR_NETWORK")){
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
        pref.setString("name",querySnapshot.documents[0].data['nombre']);
        pref.setBool("passGenerico", querySnapshot.documents[0].data['passGenerico']);
        pref.setString("documentID",querySnapshot.documents[0].documentID);
        pref.setInt("sistema",querySnapshot.documents[0].data['sistema']);
        pref.setString("sistemaDesc",querySnapshot.documents[0].data['sistemaDesc']);
      }else{
        pref.setInt("tipoUsuario", 0);
        pref.setString("name","");
        pref.setBool("passGenerico", false);
        pref.setString("documentID","");
        pref.setInt("sistema", 0);
        pref.setString("sistemaDesc", null);
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

      if(pref.getInt("sistema") == 0 || pref.getInt("sistema") == null)
        throw new FormatException("Sistema no especificado");
    }catch(e){
      pref.setInt("tipoUsuario",0);
      pref.setString("name","");
      pref.setBool("passGenerico", false);
      pref.setString("documentID","");
      pref.setInt("sistema", 0);
      pref.setString("sistemaDesc", null);
    }

  }
}