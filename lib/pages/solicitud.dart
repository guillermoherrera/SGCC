import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/classes/consulta.dart';
import 'package:sgcartera_app/models/curp_request.dart';
import 'package:sgcartera_app/models/persona.dart';
import 'package:sgcartera_app/models/solicitud.dart';
import 'package:sgcartera_app/pages/root_page.dart';
import 'package:sgcartera_app/pages/solicitud1.dart';
import 'package:sgcartera_app/pages/solicitud2.dart';
import 'package:sgcartera_app/sqlite_files/models/cat_estado.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_catEstado.dart';

import 'home.dart';
//import 'package:intl/intl.dart';

class Solicitud extends StatefulWidget {
  Solicitud({this.title, this.colorTema, this.grupoId, this.grupoNombre, this.actualizaHome});
  final String title;
  final MaterialColor colorTema;
  final int grupoId;
  final String grupoNombre;
  final VoidCallback actualizaHome;
  @override
  _SolicitudState createState() => _SolicitudState();
}

class _SolicitudState extends State<Solicitud> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  var nombre = TextEditingController();
  var nombreAdicional = TextEditingController();
  var apellidoPrimero = TextEditingController();
  var apellidoSegundo = TextEditingController();
  var fechaNacimiento = TextEditingController();
  var curp = TextEditingController();
  var rfc = TextEditingController();
  var importe = TextEditingController();
  var telefono = TextEditingController();
  bool buttonEnabled = true;
  AuthFirebase authFirebase = new AuthFirebase();
  Consulta consulta = new Consulta();
  List<CatEstado> estados = List();

  DateTime now = new DateTime.now();
  DateTime selectedDate;
  //var formatter = new DateFormat('dd / MM / yyyy');
  
  String formatted;

  Future<Null> _selectDate(BuildContext context) async {
    selectedDate = DateTime(now.year - 18, now.month, now.day);
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      locale: const Locale('es'),
      firstDate: DateTime(1950, 1),
      lastDate: DateTime(2019));
    if (picked != null)
      if(selectedDate.difference(picked).inDays >= 0){
        setState(() {
          selectedDate = picked;
          fechaNacimiento.text = formatDate(selectedDate, [dd, '/', mm, '/', yyyy]);
          getCurpRfc();
        });
      }else{
        fechaNacimiento.text = "No válido";
      }
  }

  getEstados()async{
    estados = await RepositoryCatEstados.getAllCatEstados();
  }

  @override
  void initState() {
    getEstados();
    //formatted = formatter.format(selectedDate);
    //fechaNacimiento.text = formatted;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //onWillPop: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootPage(authFirebase: authFirebase, colorTema: widget.colorTema,))),
      onWillPop: ()=> Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomePage(onSingIn: (){}, colorTema: widget.colorTema,)), (Route<dynamic> route) => false),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title),
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
                SingleChildScrollView(
                  child: Container(
                    child: Card(
                      color: Colors.white70,
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 8.0,
                      child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: formSolicitud(),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      )
    );
  }
  
  List<Widget> formSolicitud(){
    return [
      Container(
        child: Center(
          child: Text("DATOS DEL CLIENTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
      ),
      Divider(),
      padded(
        TextFormField(
          controller: importe,
          maxLength: 14,
          style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: "Importe Capital",
            prefixIcon: Icon(Icons.attach_money)
          ),
          keyboardType: TextInputType.number,
          //enabled: false,
          validator: (value){
            //return value.isEmpty ? "Ingresa el importe" : null;},
            if(value.isEmpty){
              return "Ingresa el importe";
            }else{
              double cant = double.parse(value);
              if(cant <= 0 || cant%500 > 0 ){
                return "El importe debe ser multiplo de 500 (ej. 500, 1000, 1500 ...)";
              }else{
                return null;
              }
            }
          }
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          flexPadded(TextFormField(
              controller: curp,
              maxLength: 18,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "CURP"
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                if (curp.text != value.toUpperCase())
                  curp.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){
                if(value.isEmpty){
                  return "Ingresa la CURP";
                }else if(value.length < 18){
                  return "Complenta la CURP";
                }
                return null;
              },
            )
          ),
          flexPadded(
            Center(child: 
            RaisedButton(
              onPressed: ()=>consultarCurp(),
              color: Colors.blue,
              padding: EdgeInsets.all(0.0),
              child: Column(children: <Widget>[Icon(Icons.search, color: Colors.white,),Text("Consultar Curp", style: TextStyle(color: Colors.white),)],),
            ))
          )
        ]
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          flexPadded(TextFormField(
              controller: nombre,
              maxLength: 30,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Nombre"
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                getCurpRfc();
                if (nombre.text != value.toUpperCase())
                  nombre.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){return value.isEmpty ? "Ingresa el nombre" : null;},
            )
          ),
          flexPadded(TextFormField(
              controller: nombreAdicional,
              maxLength: 30,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Segundo Nombre"
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                getCurpRfc();
                if (nombreAdicional.text != value.toUpperCase())
                  nombreAdicional.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              //validator: (value){return value.isEmpty ? "Por favor ingresa tu nombre" : null;},
            )
          )
        ]
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          flexPadded(TextFormField(
              controller: apellidoPrimero,
              maxLength: 30,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Primer Apellido"
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                getCurpRfc();
                if (apellidoPrimero.text != value.toUpperCase())
                  apellidoPrimero.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){return value.isEmpty ? "Ingresa el apellido" : null;},
            )
          ),
          flexPadded(TextFormField(
              controller: apellidoSegundo,
              maxLength: 30,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Segundo Apellido"
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                getCurpRfc();
                if (apellidoSegundo.text != value.toUpperCase())
                  apellidoSegundo.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              //validator: (value){return value.isEmpty ? "Ingresa el segundo apellido" : null;},
            )
          )
        ]
      ),

      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          flexPadded(InkWell(
              child: AbsorbPointer(child:TextFormField(
                controller: fechaNacimiento,
                maxLength: 10,
                style: TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: "Fecha de Nacimiento",
                  //icon: Icon(Icons.calendar_today)
                  helperText: "dia/mes/año"
                ),
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.datetime,
                //enabled: false,
                validator: (value){
                  //return value.isEmpty ? "Por favor ingresa la fecha de nacimiento" : null;
                  if(value.isEmpty){
                    return "Por favor ingresa la fecha de nacimiento";
                  }else if(value.length < 10){
                    return "Debe ser mayor de edad";
                  }
                },
              ),),
              onTap: () => _selectDate(context),
            )
          ),
          /*flexPadded(TextFormField(
              controller: curp,
              maxLength: 18,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "CURP"
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                if (curp.text != value.toUpperCase())
                  curp.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){
                if(value.isEmpty){
                  return "Ingresa la CURP";
                }else if(value.length < 18){
                  return "Complenta la CURP";
                }
                return null;
              },
            )
          ),*/
        ]
      ),
      Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          flexPadded(TextFormField(
              controller: rfc,
              maxLength: 13,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "RFC"
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                if (rfc.text != value.toUpperCase())
                  rfc.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){
                if(value.isEmpty){
                  return "Ingresa el RFC";
                }else if(value.length < 10){
                  return "Complenta el RFC";
                }
                return null;
              },
            )
          ),
          flexPadded(TextFormField(
              controller: telefono,
              maxLength: 10,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Teléfono"
              ),
              keyboardType: TextInputType.number,
              validator: (value){
                if(value.isEmpty){
                  return "Ingresa un teléfono";
                }else if(value.length < 10){
                  return "Complenta el teléfono";
                }
                return null;
              },
            )
          ),
        ]
      ),
      Column(
        children: buttonWidget(),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text("Paso 1 de 3", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))
        ],
      )
    ];
  }

  Widget flexPadded(Widget childs){
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: childs,
      ),
    );
  }

  Widget padded(Widget childs){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: childs,
    );
  }

  List<Widget> buttonWidget(){
    return [
      styleButton(validaSubmit, buttonEnabled ? "CONTINUAR" : "CARGANDO ...")
    ];
  }

  Widget styleButton(VoidCallback onPressed, String text){
    return RaisedButton(
      onPressed: buttonEnabled ? onPressed : (){},
      color: widget.colorTema,
      textColor: Colors.white,
      child: Text(text),
    );
  }

  void validaSubmit(){
    FocusScope.of(context).requestFocus(FocusNode());
    if(formKey.currentState.validate()){
      _buttonStatus();
      Persona persona;
      persona = new Persona(
        nombre: nombre.text,
        nombreSegundo: nombreAdicional.text,
        apellido:  apellidoPrimero.text,
        apellidoSegundo: apellidoSegundo.text,
        curp: curp.text,
        rfc: rfc.text,
        fechaNacimiento: selectedDate,
        telefono: telefono.text
      );
      SolicitudObj solicitudObj;
      solicitudObj = new SolicitudObj(
        persona: persona.toJson(),
        importe: double.parse(importe.text),
        tipoContrato: widget.grupoId == null ? 1 : 2,
        userID: "userID",
        grupoId: widget.grupoId,
        grupoNombre: widget.grupoNombre
      );
      _buttonStatus();
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>SolicitudDocumentos(title: widget.title, datos: solicitudObj, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome)));
      estados.sort((a, b) => a.estado.compareTo(b.estado));
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SolicitudDireccion(title: widget.title, datos: solicitudObj, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome, estados: estados)));
    }else{
      final snackBar = SnackBar(
        content: Text("Error al guardar. Revisa el formulario para más información.", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.red[300],
        duration: Duration(seconds: 3),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  void _buttonStatus(){
    setState(() {
     buttonEnabled = buttonEnabled ? false : true; 
    });
  }

  void getCurpRfc(){
    String curpStr = "";
    List<String> vocales = <String>['A','E','I','O','U','a','e','i','o','u'];

    curpStr = curpStr + (apellidoPrimero.text.length > 0 ? apellidoPrimero.text[0] : 'X');

    bool bandera = false;
    for(int i = 0;(bandera == false && apellidoPrimero.text.length > 0); i++){
      if(vocales.contains(apellidoPrimero.text[i])){
        bandera = true;
        curpStr = curpStr + apellidoPrimero.text[i];
      }
      if(apellidoPrimero.text.length == i+1)
        bandera = true;
    }

    curpStr = curpStr + (apellidoSegundo.text.length > 0 ? apellidoSegundo.text[0] : 'X');
    if((nombre.text == "MARÍA" || nombre.text == "JOSÉ" || nombre.text == "MARIA" || nombre.text == "JOSE") && nombreAdicional.text.length > 0){
      curpStr = curpStr + (nombreAdicional.text.length > 0 ? nombreAdicional.text[0] : 'X');
    }else{
      curpStr = curpStr + (nombre.text.length > 0 ? nombre.text[0] : 'X');
    }
    if(fechaNacimiento.text.length > 0){
      curpStr = curpStr + fechaNacimiento.text[8] +fechaNacimiento.text [9];
      curpStr = curpStr + fechaNacimiento.text[3] +fechaNacimiento.text [4];
      curpStr = curpStr + fechaNacimiento.text[0] +fechaNacimiento.text [1];
    }

    curp.text = curpStr;
    rfc.text = curpStr;
  }

  consultarCurp()async{
    CurpRequest curpRequest;
    mostrarShowDialog(1,"\nCONSULTANDO CURP ...");
    clearFields();
    if(curp.text.length == 18){
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          curpRequest = await consulta.consultaCurp(curp.text);
          if(curpRequest.result){
            Navigator.pop(context);
            fillFields(curpRequest.datos.persona);
            mostrarShowDialog(3, curpRequest.mensaje);
            print('connected');
          }else{
            Navigator.pop(context);
            mostrarShowDialog(2, curpRequest.mensaje);
            print('not connected');
          }
        }
      } on SocketException catch (_) {
        print('not connected');
        Navigator.pop(context);
        mostrarShowDialog(2, "\nSIN CONEXIÓN");
      }
    }else{
      Navigator.pop(context);
      mostrarShowDialog(2, "\nLA CURP '"+curp.text+"' NO TIENE LA LONGITUD CORRECTA (18 CARACTERES)");
    }
  }

  mostrarShowDialog(int conectado, String mensaje){
    Widget icono;
    switch (conectado) {
      case 1:
        icono = CircularProgressIndicator();
        break;
      case 2:
        icono = Icon(Icons.error, color: Colors.red, size: 100.0,);
        break;
      case 3:
        icono = Icon(Icons.check_circle, color: Colors.green, size: 100.0,);
        break;
      default:
        icono = Icon(Icons.error, color: Colors.yellow, size: 100.0,);
        break;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: (){},
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                //conectado ? CircularProgressIndicator() : Icon(Icons.error, color: Colors.red, size: 100.0,),
                //conectado ? Text("\nCONSULTANDO CURP ...") : Text("\nSIN CONEXIÓN"),
                icono,
                Text(mensaje)
              ],
            ),
            actions: <Widget>[
              conectado != 1 ?
              new FlatButton(
                child: const Text("CERRAR"),
                onPressed: (){Navigator.pop(context);}
              ) : null
            ],
          )
        );
      },
    );
  }

  clearFields(){
    nombre.text = "";
    nombreAdicional.text = "";
    apellidoPrimero.text = "";
    apellidoSegundo.text = "";
    rfc.text = "";
    selectedDate = null;
    fechaNacimiento.text = "";
  }

  fillFields(Map persona){
    nombre.text = persona['nombre'];
    nombreAdicional.text = persona['nombreSegundo'];
    apellidoPrimero.text = persona['apellido'];
    apellidoSegundo.text = persona['apellidoSegundo'];
    rfc.text = persona['rfc'].isEmpty ? curp.text.substring(0,10) :persona['rfc'];
    selectedDate = persona['fechaNacimiento'];
    fechaNacimiento.text = formatDate( persona['fechaNacimiento'], [dd, '/', mm, '/', yyyy]);
  }
}