import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/classes/consulta.dart';
import 'package:sgcartera_app/classes/shared_class.dart';
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
  Solicitud({this.title, this.colorTema, this.grupoId, this.grupoNombre, this.actualizaHome, this.esRenovacion});
  final String title;
  final Color colorTema;
  final int grupoId;
  final String grupoNombre;
  final VoidCallback actualizaHome;
  bool esRenovacion;
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
  Shared shared = Shared();
  int intentoCurp = 0; //auxiliar para la validación de las palabras altisonantes 

  DateTime now = new DateTime.now();
  DateTime selectedDate;
  //var formatter = new DateFormat('dd / MM / yyyy');
  
  String formatted;

  Future<Null> _selectDate(BuildContext context) async {
    selectedDate = DateTime(now.year - 18, now.month, now.day);
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      //locale: const Locale('es'),
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

  getSharedP()async{
    await Future.delayed(Duration(seconds:1));
    Persona personaShared;
    personaShared = await shared.obtenerPersona();

    curp.text = personaShared.curp;
    nombre.text = personaShared.nombre;
    nombreAdicional.text = personaShared.nombreSegundo;
    apellidoPrimero.text = personaShared.apellido;
    apellidoSegundo.text = personaShared.apellidoSegundo;
    fechaNacimiento.text = personaShared.fechaNacimiento != null ? formatDate( personaShared.fechaNacimiento, [dd, '/', mm, '/', yyyy]) : null;
    selectedDate =  personaShared.fechaNacimiento;
    rfc.text = personaShared.rfc;
    telefono.text = personaShared.telefono;

    setState(() {});
  }

  @override
  void initState() {
    if(widget.esRenovacion == null){widget.esRenovacion = false;} 
    getEstados();
    getSharedP();
    //formatted = formatter.format(selectedDate);
    //fechaNacimiento.text = formatted;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //onWillPop: ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootPage(authFirebase: authFirebase, colorTema: widget.colorTema,))),
      onWillPop: ()async=>  widget.esRenovacion == null ? true : widget.esRenovacion ? true : Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomePage(onSingIn: (){}, colorTema: widget.colorTema,)), (Route<dynamic> route) => false),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(widget.title, style: TextStyle(color: Colors.white)),
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
                //Expanded(
                  LayoutBuilder(
                    builder: (context, constraint){
                    return SingleChildScrollView( child: ConstrainedBox( constraints: BoxConstraints(minHeight: constraint.maxHeight), child: Card(
                      color: Colors.white,
                      margin: EdgeInsets.all(4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
                      ),
                      elevation: 0.0,
                      child: IntrinsicHeight( child:Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(15),
                            child:  Column(
                              children: formSolicitud(),
                            ),
                          ),
                          Expanded(child:  
                            Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: styleButton(validaSubmit, buttonEnabled ? "SIGUIENTE" : "CARGANDO ..."),
                            ),
                          )
                        ]
                      )),
                    )));
                  }),
                //)
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
            prefixIcon: Icon(Icons.attach_money),
            fillColor: Color(0xfff2f2f2),
            filled: true,
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
          ),
          keyboardType: TextInputType.number,
          //enabled: false,
          validator: (value){
            //return value.isEmpty ? "Ingresa el importe" : null;},
            if(value.isEmpty){
              return "Ingresa el importe";
            }else{
              double cant;
              try{
                cant = double.parse(value);
              }catch(e){
                cant = 0;
              }
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
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:TextFormField(
              controller: curp,
              maxLength: 18,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "CURP",
                fillColor: Color(0xfff2f2f2),
                filled: true,
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
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
                  return "Completa la CURP";
                }
                return null;
              },
            )
          )),
          Flexible(
            flex: 1,
            child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
            Center(child:
            Container(margin: EdgeInsets.only(bottom: 20.0) ,child:
            RaisedButton(
              onPressed: ()=>consultarCurp(),
              color: Color.fromRGBO(26, 156, 255, 0.2),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: Color(0xff1A9CFF), width: 2.0)),
              padding: EdgeInsets.only(top:9, bottom: 9, left: 30.0, right: 30.0),
              child: Column(children: <Widget>[Icon(Icons.search, color: Colors.white,),Text("CONSULTAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),)],),
            )))
          ))
        ]
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          flexPadded(TextFormField(
              controller: nombre,
              maxLength: 50,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Nombre",
                fillColor: Color(0xfff2f2f2),
                filled: true,
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
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
              maxLength: 50,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Segundo Nombre",
                fillColor: Color(0xfff2f2f2),
                filled: true,
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
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
              maxLength: 50,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Primer Apellido",
                fillColor: Color(0xfff2f2f2),
                filled: true,
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
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
              maxLength: 50,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Segundo Apellido",
                fillColor: Color(0xfff2f2f2),
                filled: true,
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
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
                  helperText: "dia/mes/año",
                  fillColor: Color(0xfff2f2f2),
                  filled: true,
                  border: new OutlineInputBorder(
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(10.0),
                    ),
                  ),
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
                labelText: "RFC",
                fillColor: Color(0xfff2f2f2),
                filled: true,
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                if (rfc.text != value.toUpperCase())
                  rfc.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){
                if(value.isEmpty){
                  return "Ingresa el RFC";
                }else if(value.length != 10 && value.length != 13){
                  return "Completa el RFC";
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
                labelText: "Teléfono",
                fillColor: Color(0xfff2f2f2),
                filled: true,
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value){
                value = value.replaceAll(RegExp(r"[^\s\w]"), "");//quitar simbolos
                value = value.replaceAll(" ", "");//quitar espacios en blanco
                if(value.isEmpty){
                  return "Ingresa un teléfono";
                }else if(value.length < 10){
                  return "Completa el teléfono";
                }
                return null;
              },
            )
          ),
        ]
      ),
      /*Column(
        children: buttonWidget(),
      ),*/
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text("Paso 1 de 3", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))
        ],
      ),
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
    return SizedBox(width: double.infinity, child: RaisedButton(
      onPressed: buttonEnabled ? onPressed : (){},
      color: Color(0xff1A9CFF),
      textColor: Colors.white,
      padding: EdgeInsets.all(12),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.arrow_forward),Text(text, style: TextStyle(fontSize: 20),)]),
    ));
  }

  void validaSubmit(){
    FocusScope.of(context).requestFocus(FocusNode());
    if(formKey.currentState.validate() && getCurpRfc()){
      _buttonStatus();
      Persona persona;
      persona = new Persona(
        nombre: nombre.text,
        nombreSegundo: nombreAdicional.text,
        apellido:  apellidoPrimero.text,
        apellidoSegundo: apellidoSegundo.text,
        curp: removeDiacritics(curp.text),
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
      shared.guardarPersona(persona);
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SolicitudDireccion(title: widget.title, datos: solicitudObj, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome, estados: estados, esRenovacion: widget.esRenovacion)));
    }else{
      String  mensaje = '';
      if(getCurpRfc()){
        mensaje = 'Error al guardar. Revisa el formulario para más información.';
      }else{
        mensaje = 'Error en el formato de la CURP y/o RFC.';
      }

      final snackBar = SnackBar(
        content: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold),),
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

  bool getCurpRfc(){
    String curpStr = "", nomPila;
    bool result = false;
    List<String> vocales = <String>['A','E','I','O','U','a','e','i','o','u','Á','É','Í','Ó','Ú','á','é','í','ó','ú'];
    List<String> sexo = <String>['M','H'];
    List<String> entFed = <String>['AS','BC','BS','CC','CL','CM','CS','CH','DF','DG',
                                   'GT','GR','HG','JC','MC','MN','MS','NT','NL','OC',
                                   'PL','QT','QR','SP','SL','SR','TC','TS','TL','VZ',
                                   'YN','ZS','NE'];
    List<String> palInc = <String>['BACA','BAKA','BUEI','BUEY','CACA','CACO','CAGA','CAGO','CAKA','CAKO','COGE','COGI','COJA','COJE','COJI',
                                   'COJO','COLA','CULO','FALO','FETO','GETA','GUEI','GUEY','JETA','JOTO','KACA','KACO','KAGA','KAGO','KAKA',
                                   'KAKO','KOGE','KOGI','KOJA','KOJE','KOJI','KOJO','KOLA','KULO','LILO','LOCA','LOCO','LOKA','LOKO','MAME',
                                   'MAMO','MEAR','MEAS','MEON','MIAR','MION','MOCO','MOKO','MULA','MULO','NACA','NACO','PEDA','PEDO','PENE',
                                   'PIPI','PITO','POPO','PUTA','PUTO','QULO','RATA','ROBA','ROBE','ROBO','RUIN','SENO','TETA','VACA','VAGA',
                                   'VAGO','VAKA','VUEI','VUEY','WUEI','WUEY'];                            

    //primer letra primer Apellido
    curpStr = curpStr + (apellidoPrimero.text.length > 0 ? apellidoPrimero.text[0] : 'X');

    //primer vocal primer Apellido
    bool bandera = false;
    for(int i = 1;(bandera == false && apellidoPrimero.text.length > 1); i++){
      if(vocales.contains(apellidoPrimero.text[i])){
        bandera = true;
        curpStr = curpStr + apellidoPrimero.text[i];
      }
      if(apellidoPrimero.text.length == i+1)
        bandera = true;
    }

    //primera letra segundo apellido
    curpStr = curpStr + (apellidoSegundo.text.length > 0 ? apellidoSegundo.text[0] : 'X');
    
    //primera letra nombre pila
    if((nombre.text == "MARÍA" || nombre.text == "JOSÉ" || nombre.text == "MARIA" || nombre.text == "JOSE") && nombreAdicional.text.length > 0){
      nomPila = nombreAdicional.text.length > 0 ? nombreAdicional.text : nombre.text;
      nomPila = nomPila.replaceAll("DE LAS ", "").replaceAll("DE LOS ", "").replaceAll("DE LA ", "").replaceAll("DEL ", "").replaceAll("DE ", "");
      curpStr = curpStr + (nomPila.length > 0 ? nomPila[0] : 'X');
    }else{
      curpStr = curpStr + (nombre.text.length > 0 ? nombre.text[0] : 'X');
      nomPila = nombre.text;
    }

    //validacion tildes y palabras altisonantes
    curpStr = removeDiacritics(curpStr);
    if(palInc.contains(curpStr) && intentoCurp != 4){
      intentoCurp += 1;
      curpStr = curpStr.substring(0,1) + 'X' + curpStr.substring(2);
    }else{
      intentoCurp = 0;
    }

    //fecha de Nacimiento
    if(fechaNacimiento.text.length > 9){
      curpStr = curpStr + fechaNacimiento.text[8] +fechaNacimiento.text [9];
      curpStr = curpStr + fechaNacimiento.text[3] +fechaNacimiento.text [4];
      curpStr = curpStr + fechaNacimiento.text[0] +fechaNacimiento.text [1];
    }

    String segConsonantes = "";
    //segunda consonante primer apellido
    bandera = false;
    for(int i = 1;(bandera == false && apellidoPrimero.text.length > 1); i++){
      if(!vocales.contains(apellidoPrimero.text[i])){
        bandera = true;
        segConsonantes = apellidoPrimero.text[i];
      }
      if(apellidoPrimero.text.length == i+1)
        bandera = true;
      if(bandera && segConsonantes.length == 0)
        segConsonantes = 'X';
    }
    
    //segunda consonante segundo apellido
    bandera = false;
    for(int i = 1;(bandera == false && apellidoSegundo.text.length > 1); i++){
      if(!vocales.contains(apellidoSegundo.text[i])){
        bandera = true;
        segConsonantes = segConsonantes + apellidoSegundo.text[i];
      }
      if(apellidoSegundo.text.length == i+1)
        bandera = true;
      if(bandera && segConsonantes.length == 1)
        segConsonantes = segConsonantes + 'X';
    }
    if(apellidoSegundo.text.length == 0){segConsonantes = segConsonantes + 'X';}

    //segunda consonante nombre pila
    bandera = false;
    for(int i = 1;(bandera == false && nomPila.length > 1); i++){
      if(!vocales.contains(nomPila[i])){
        bandera = true;
        segConsonantes = segConsonantes + nomPila[i];
      }
      if(nomPila.length == i+1)
        bandera = true;
      if(bandera && segConsonantes.length == 2)
        segConsonantes = segConsonantes + 'X';
    }
    
    //fill 10 caracteres de campos curp y rfc
    if(curp.text.length < 18) curp.text = curpStr;
    if(rfc.text.length < 10) rfc.text = curpStr;
    
    //validaciones
    if(curp.text.length == 18 && (rfc.text.length == 10 || rfc.text.length == 13)){
      if(curp.text.substring(0,10) == curpStr && rfc.text.substring(0,10) == curpStr && sexo.contains(curp.text.substring(10,11)) && entFed.contains(curp.text.substring(11,13)) && curp.text.substring(13,16) == segConsonantes && double.tryParse(curp.text.substring(17,18)) != null ){
         result = true; 
      }
    }
    return result;
  }

  consultarCurp()async{
    CurpRequest curpRequest;
    mostrarShowDialog(1,"\nBUSCANDO CLIENTE POR SU CURP ...");
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
            shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0),side: BorderSide(color: widget.colorTema, width: 2.0)),
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
    telefono.text = persona['telefono'];
  }
}