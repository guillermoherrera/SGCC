import 'package:flutter/material.dart';
import 'package:sgcartera_app/Models/auth_res.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';

class Login extends StatefulWidget {
  Login({this.auth, this.onSingIn});
  final AuthFirebase auth;
  final VoidCallback onSingIn;
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = new GlobalKey<FormState>();
  var email = TextEditingController();
  var pass = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool buttonEnabled = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Iniciar Sesión"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Container(
            child: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(),
                    child: Card(
                      color: Colors.white70,
                      margin: EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 80),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 8.0,
                      child: Padding(
                        padding: EdgeInsets.all(25),
                        child: Column(
                          children: formLogin(),
                        ),
                      ),
                    )
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> formLogin(){
    return [
      padded(
        childs: TextFormField(
          controller: email,
          decoration: InputDecoration(
            icon: Icon(Icons.alternate_email),
            labelText: "Correo"
          ),
          autocorrect: false,
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
      color: Colors.blue,
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
        widget.onSingIn();
      }else{
        String mensaje = getMessage(authRes.mensaje);
        final snackBar = SnackBar(
          content: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.blue,
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
    }else{
      return "Correo y/o contraseña incorrectos.";
    }
  }
}