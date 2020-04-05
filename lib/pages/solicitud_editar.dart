import 'package:date_format/date_format.dart';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/models/direccion.dart';
import 'package:sgcartera_app/models/persona.dart';
import 'package:sgcartera_app/models/solicitud.dart';
import 'package:sgcartera_app/pages/solicitud2.dart';
import 'package:sgcartera_app/pages/solicitud_editar1.dart';
import 'package:sgcartera_app/pages/solicitud_editar2.dart';
import 'package:sgcartera_app/sqlite_files/models/cat_estado.dart';
import 'package:sgcartera_app/sqlite_files/models/grupo.dart';
import 'package:sgcartera_app/sqlite_files/models/solicitud.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_catEstado.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_grupo.dart';
import 'package:sgcartera_app/sqlite_files/repositories/repository_service_solicitudes.dart';

class SolicitudEditar extends StatefulWidget {
  SolicitudEditar({this.title, this.colorTema, this.idSolicitud});
  final String title;
  final int idSolicitud;
  final Color colorTema;
  @override
  _SolicitudEditarState createState() => _SolicitudEditarState();
}

class _SolicitudEditarState extends State<SolicitudEditar> {
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
  List<CatEstado> estados = List();
  int intentoCurp = 0; //auxiliar para la validación de las palabras altisonantes

  String userID;
  int idSolicitud;
  int tipoContrato;
  int idGrupo;
  String nombreGrupo;
  double importeOriginal;

  String direccion1;
  String coloniaPoblacion;
  String delegacionMunicipio;
  String ciudad;
  String estado;
  int cp;
  String pais;

  DateTime now = new DateTime.now();
  DateTime selectedDate;
  DateTime selectedDateAux;
  //var formatter = new DateFormat('dd / MM / yyyy');
  
  String formatted;

  Future<Null> _selectDate(BuildContext context) async {
    selectedDateAux = DateTime(now.year - 18, now.month, now.day);
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      //locale: const Locale('es'),
      firstDate: DateTime(1950, 1),
      lastDate: DateTime(2019));
    if (picked != null)
      if(selectedDateAux.difference(picked).inDays >= 0){
        setState(() {
          selectedDate = picked;
          fechaNacimiento.text = formatDate(selectedDate, [dd, '/', mm, '/', yyyy]);
          getCurpRfc();
        });
      }else{
        fechaNacimiento.text = "No válido";
      }
  }

  getSolicitudInfo() async{
    estados = await RepositoryCatEstados.getAllCatEstados();
    var solicitudEditar = await ServiceRepositorySolicitudes.getOneSolicitud(widget.idSolicitud);
    nombre.text = solicitudEditar.nombrePrimero;
    nombreAdicional.text = solicitudEditar.nombreSegundo;
    apellidoPrimero.text = solicitudEditar.apellidoPrimero;
    apellidoSegundo.text = solicitudEditar.apellidoSegundo;
    selectedDate = DateTime.fromMillisecondsSinceEpoch(solicitudEditar.fechaNacimiento);
    fechaNacimiento.text = formatDate(selectedDate, [dd, '/', mm, '/', yyyy]);
    curp.text = solicitudEditar.curp;
    rfc.text = solicitudEditar.rfc;
    importe.text = solicitudEditar.importe.toString();
    importeOriginal = solicitudEditar.importe;
    telefono.text = solicitudEditar.telefono;

    userID = solicitudEditar.userID;
    idSolicitud = solicitudEditar.idSolicitud;
    tipoContrato = solicitudEditar.tipoContrato;
    idGrupo = solicitudEditar.idGrupo;
    nombreGrupo = solicitudEditar.nombreGrupo;

    direccion1 = solicitudEditar.direccion1;
    coloniaPoblacion = solicitudEditar.coloniaPoblacion;
    delegacionMunicipio = solicitudEditar.delegacionMunicipio;
    ciudad = solicitudEditar.ciudad;
    estado = solicitudEditar.estado;
    cp = solicitudEditar.cp;
    pais = solicitudEditar.pais;
  }

  @override
  void initState() {
    getSolicitudInfo();
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){return new Future(() => false);},
      child: Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        leading: Container(),
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
                  child: ConstrainedBox( constraints: BoxConstraints(minHeight: constraint.maxHeight), child: Card(
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
                            child: Column(
                              children: formSolicitud(),
                            ),
                          ),
                          Expanded(child:  
                            Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: styleButton(validaSubmit, buttonEnabled ? "GUARDAR Y CONTINUAR" : "CARGANDO ..."),
                            ),
                          )
                        ]
                      ))
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      )
    ));
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
            //return value.isEmpty ? "Ingresa el importe" : null;
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
          },
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:InkWell(
              child: AbsorbPointer(child:TextFormField(
                controller: fechaNacimiento,
                maxLength: 14,
                style: TextStyle(fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: "Fecha de Nac.",
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
          )),
          Flexible(
            flex: 3,
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
      styleButton(validaSubmit, buttonEnabled ? "GUARDAR Y CONTINUAR" : "CARGANDO ...")
    ];
  }

  Widget styleButton(VoidCallback onPressed, String text){
    return SizedBox(width: double.infinity, child:RaisedButton(
      onPressed: buttonEnabled ? onPressed : (){},
      color: Color(0xff1A9CFF),
      textColor: Colors.white,
      padding: EdgeInsets.all(12),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.arrow_forward),Text(text, style: TextStyle(fontSize: 20),)]),
    ));
  }

  void validaSubmit() async{
    FocusScope.of(context).requestFocus(FocusNode());
    if(formKey.currentState.validate()  && getCurpRfc()){
      _buttonStatus();
      
      final Solicitud solicitud = new Solicitud(
        idSolicitud: idSolicitud,
        importe: double.parse(importe.text),
        nombrePrimero: nombre.text,
        nombreSegundo: nombreAdicional.text,
        apellidoPrimero: apellidoPrimero.text,
        apellidoSegundo: apellidoSegundo.text,
        fechaNacimiento: selectedDate.millisecondsSinceEpoch,
        curp: removeDiacritics(curp.text),
        rfc: rfc.text,
        telefono:  telefono.text,
        userID: userID,
        status: idGrupo == null ? 0 : 6 ,
        tipoContrato: tipoContrato,
        idGrupo: idGrupo,
        nombreGrupo: nombreGrupo,
        direccion1: direccion1,
        coloniaPoblacion: coloniaPoblacion,
        delegacionMunicipio: delegacionMunicipio,
        ciudad: ciudad,
        estado: estado,
        cp: cp,
        pais: pais
      );

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

      Direccion direccion;
      direccion = new Direccion(
        direccion1: direccion1,
        coloniaPoblacion: coloniaPoblacion,
        delegacionMunicipio: delegacionMunicipio,
        ciudad: ciudad,
        estado: estado,
        cp: cp,
        pais: pais
      );

      SolicitudObj solicitudObj;
      solicitudObj = new SolicitudObj(
        persona: persona.toJson(),
        direccion:  direccion.toJson(),
        importe: double.parse(importe.text),
        tipoContrato: tipoContrato,
        userID: userID,
        grupoId: idGrupo,
        grupoNombre: nombreGrupo,
      );

      await ServiceRepositorySolicitudes.updateSolicitud(solicitud).then((_) async{
        if(idGrupo != null){
          Grupo grupo = await ServiceRepositoryGrupos.getOneGrupo(idGrupo);
          double diferenciaIporte =  double.parse(importe.text) - importeOriginal;
          Grupo grupoAux = new Grupo(idGrupo: grupo.idGrupo, cantidad: grupo.cantidad + 0, importe: grupo.importe + diferenciaIporte);
          await ServiceRepositoryGrupos.updateGrupoImpCant(grupoAux);
        }
        _buttonStatus();
      });
      //Navigator.push(context, MaterialPageRoute(builder: (context)=>SolicitudDocumentosEditar(title: widget.title, datos: solicitudObj, colorTema: widget.colorTema, solicitudId: idSolicitud)));
      estados.sort((a, b) => a.estado.compareTo(b.estado));
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SolicitudDireccionEditar(title: widget.title, datos: solicitudObj, colorTema: widget.colorTema, actualizaHome: (){}, idSolicitud: idSolicitud, estados: estados)));
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

    //validacion tildes y palabras incovenientes
    curpStr = removeDiacritics(curpStr);
    if(palInc.contains(curpStr) && intentoCurp != 4){
      intentoCurp += 1;
      curpStr = curpStr.substring(0,1) + 'X' + curpStr.substring(2);
    }else{
      intentoCurp = 0;
    }

    //fecha de Nacimiento
    if(fechaNacimiento.text.length > 0){
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
}