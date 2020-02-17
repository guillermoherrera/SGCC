import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CambioContrasena extends StatefulWidget {
  CambioContrasena({this.colorTema, this.changePass, this.actualizaHome});
  final Color colorTema;
  bool changePass;
  final VoidCallback actualizaHome;
  @override
  _CambioContrasenaState createState() => _CambioContrasenaState();
}

class _CambioContrasenaState extends State<CambioContrasena> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  var passActual = TextEditingController();
  var passNuevo = TextEditingController();
  var passConfirm = TextEditingController();
  String pass = "", documentID = "";
  AuthFirebase authFirebase = new AuthFirebase();
  Firestore _firestore = Firestore.instance;
  bool cargando = false;
  bool obscureText1 = true, obscureText2 = true, obscureText3 = true;
  
  
  Future<void> getDatos() async{
    final pref = await SharedPreferences.getInstance();
    pass = pref.getString("pass");
    documentID = pref.getString('documentID');
  }

  @override
  void initState() {
    getDatos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Cambio de Contraseña", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
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
                colors: [widget.colorTema, widget.colorTema])
              ),
            ),
            LayoutBuilder(
              builder: (context, constraint){
              return SingleChildScrollView(
                child: ConstrainedBox( constraints: BoxConstraints(minHeight: constraint.maxHeight),
                  child: Card(
                    color: Colors.white,
                    margin:  EdgeInsets.all(4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
                    ),
                    elevation: 0.0,
                    child: IntrinsicHeight( child:Column(
                      children: [
                          Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(children: vista())
                        ),
                        Expanded(child:  
                          Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: SizedBox(width: double.infinity, child: RaisedButton(
                              onPressed: ()async{
                                validaSubmit();
                              },
                              color: Color(0xff1A9CFF),
                              textColor: Colors.white,
                              padding: EdgeInsets.all(12),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(cargando ? Icons.watch_later : Icons.edit),Text(cargando ? " CAMBIANDO CONTRASEÑA ..." : " ACTUALIZAR CONTRASEÑA", style: TextStyle(fontSize: 20),)]),
                            ))
                          ),
                        )
                      ]
                    ))
                  )
                )
              );}
            )
          ]
        )
      ),
    ));
  }

  List<Widget> vista(){
    return [
      Container(
        child: info(),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          //color: Color(0xfff2f2f2)
        ),
      ),
      Divider(),
      padded(
        TextFormField(
          controller: passActual,
          maxLength: 20,
          style: TextStyle(fontWeight: FontWeight.bold),
          obscureText: obscureText1,
          decoration: InputDecoration(
            labelText: "Contraseña Actual",
            fillColor: Color(0xfff2f2f2),
            filled: true,
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            suffixIcon: IconButton(icon: Icon(Icons.remove_red_eye), onPressed: (){setState(() {obscureText1 = !obscureText1;});})
          ),
          //textCapitalization: TextCapitalization.characters,
          validator: (value){
            if(value.isEmpty){
              return "Ingresa la contraseña actual";
            }else if(value.length < 6){
              return "Debe tener 6 caracteres minimo";
            }else if(pass != value){
              return "La contraseña actual no es correcta";
            }
            return null;
          },
        )
      ),
      Divider(),
      padded(
        TextFormField(
          controller: passNuevo,
          maxLength: 20,
          style: TextStyle(fontWeight: FontWeight.bold),
          obscureText: obscureText2,
          decoration: InputDecoration(
            labelText: "Nueva Contraseña",
            fillColor: Color(0xfff2f2f2),
            filled: true,
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            suffixIcon: IconButton(icon: Icon(Icons.remove_red_eye), onPressed: (){setState(() {obscureText2 = !obscureText2;});})
          ),
          //textCapitalization: TextCapitalization.characters,
          validator: (value){
            if(value.isEmpty){
              return "Ingresa la nueva contraseña";
            }else if(value.length < 6){
              return "Debe tener 6 caracteres minimo";
            }else if(value == passActual.text){
              return "Debe ser diferente a la contraseña actual";
            }
            return null;
          },
        )
      ),
      padded(
        TextFormField(
          controller: passConfirm,
          maxLength: 20,
          style: TextStyle(fontWeight: FontWeight.bold),
          obscureText: obscureText3,
          decoration: InputDecoration(
            labelText: "Confirma Nueva Contraseña",
            fillColor: Color(0xfff2f2f2),
            filled: true,
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            suffixIcon: IconButton(icon: Icon(Icons.remove_red_eye), onPressed: (){setState(() {obscureText3 = !obscureText3;});})
          ),
          //textCapitalization: TextCapitalization.characters,
          validator: (value){
            if(value.isEmpty){
              return "Ingresa la confirmación de la nueva contraseña";
            }else if(value.length < 6){
              return "Debe tener 6 caracteres minimo";
            }else if(value != passNuevo.text){
              return "La confirmación no coincide con la nueva contraseña";
            }
            return null;
          },
        )
      ),
    ];
  }

  Widget info(){
    return Column(
      children: <Widget>[
        Container(child:Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            widget.changePass ? Icon(Icons.error, color: Colors.yellow[900], size: 40) : Icon(Icons.lock, color: widget.colorTema, size: 40),
            Container(
              child: widget.changePass ? Text("\nLa contraseña actual NO es segura.\n\nEs recomendable cambiar la contraseña actual por una personalizada para mayor seguridad.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)) :
                Text("\nEs recomendable cambiar la contraseña periodicamente para mayor seguridad.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
            )
          ],
        ))
      ]
    );
  }

  void validaSubmit() async{
    final pref = await SharedPreferences.getInstance();
    FocusScope.of(context).requestFocus(FocusNode());
    var snackBar;
    setState(() {
      cargando = true;  
    });
    if(formKey.currentState.validate()){
      if(await authFirebase.changePass(passNuevo.text, pref.getString("email"), passActual.text)){
        pref.setBool("passGenerico", false);
        widget.changePass = false;
        pref.setString("pass", passNuevo.text);
        pass = passNuevo.text;
        await _firestore.collection("UsuariosTipos").document(documentID).updateData({"passGenerico": false}).timeout(Duration(seconds:3)).catchError((error){print("ERROR AL REGISTRAR CAMBIO DE CONTRASEÑA");});
        passActual.text = "";
        passNuevo.text = "";
        passConfirm.text = "";
        widget.actualizaHome();
        snackBar = SnackBar(
          content: Text("Contraseña Actualizada.", style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.green[300],
          duration: Duration(seconds: 3),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }else{
        snackBar = SnackBar(
          content: Text("Contraseña no Actualizada.", style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.red[300],
          duration: Duration(seconds: 3),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }
    setState(() {
      cargando = false;  
    });
  }

  Widget padded(Widget childs){
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
      child: childs,
    );
  }
}