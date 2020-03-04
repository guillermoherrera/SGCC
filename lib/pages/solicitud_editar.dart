import 'package:date_format/date_format.dart';
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
    return Scaffold(
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
            //return value.isEmpty ? "Ingresa el importe" : null;
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
          flexPadded(InkWell(
              child: AbsorbPointer(child:TextFormField(
                controller: fechaNacimiento,
                maxLength: 14,
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
          flexPadded(TextFormField(
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
          ),
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
                }else if(value.length < 10){
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
    if(formKey.currentState.validate()){
      _buttonStatus();
      
      final Solicitud solicitud = new Solicitud(
        idSolicitud: idSolicitud,
        importe: double.parse(importe.text),
        nombrePrimero: nombre.text,
        nombreSegundo: nombreAdicional.text,
        apellidoPrimero: apellidoPrimero.text,
        apellidoSegundo: apellidoSegundo.text,
        fechaNacimiento: selectedDate.millisecondsSinceEpoch,
        curp: curp.text,
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
    //curpStr = curpStr + (nombre.text.length > 0 ? nombre.text[0] : 'X');
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

    if(curp.text.length < 18) curp.text = curpStr;
    rfc.text = curpStr;
  }
}