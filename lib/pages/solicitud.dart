import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Solicitud extends StatefulWidget {
  Solicitud({this.title});
  final String title;
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
  bool buttonEnabled = true;

  DateTime selectedDate = DateTime.now();
  var formatter = new DateFormat('dd / MM / yyyy');
  
  String formatted;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        formatted = formatter.format(selectedDate);
        fechaNacimiento.text = formatted;
      });
  }

  @override
  void initState() {
    formatted = formatter.format(selectedDate);
    //fechaNacimiento.text = formatted;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  colors: [Colors.blue[100], Colors.white])
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
          decoration: InputDecoration(
            labelText: "Importe Capital",
            icon: Icon(Icons.attach_money)
          ),
          keyboardType: TextInputType.number,
          //enabled: false,
          validator: (value){return value.isEmpty ? "Ingresa el importe" : null;},
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          flexPadded(TextFormField(
              controller: nombre,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: "Nombre"
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                if (nombre.text != value.toUpperCase())
                  nombre.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){return value.isEmpty ? "Ingresa el nombre" : null;},
            )
          ),
          flexPadded(TextFormField(
              controller: nombreAdicional,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: "Segundo Nombre"
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                if (nombre.text != value.toUpperCase())
                  nombre.value = nombre.value.copyWith(text: value.toUpperCase());
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
              decoration: InputDecoration(
                labelText: "Primer Apellido"
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                if (nombre.text != value.toUpperCase())
                  nombre.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){return value.isEmpty ? "Ingresa el apellido" : null;},
            )
          ),
          flexPadded(TextFormField(
              controller: apellidoSegundo,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: "Segundo Apellido"
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                if (nombre.text != value.toUpperCase())
                  nombre.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              //validator: (value){return value.isEmpty ? "Por favor ingresa tu nombre" : null;},
            )
          )
        ]
      ),
      padded(
        InkWell(
          child: AbsorbPointer(child:TextFormField(
            controller: fechaNacimiento,
            maxLength: 14,
            decoration: InputDecoration(
              labelText: "Fecha de Nacimiento (DD/MM/AAAA)",
              icon: Icon(Icons.calendar_today)
            ),
            textCapitalization: TextCapitalization.sentences,
            keyboardType: TextInputType.datetime,
            //enabled: false,
            validator: (value){return value.isEmpty ? "Por favor ingresa la fecha de nacimiento" : null;},
          ),),
          onTap: () => _selectDate(context),
        )
      ),
      Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          flexPadded(TextFormField(
              controller: curp,
              maxLength: 13,
              decoration: InputDecoration(
                labelText: "CURP"
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                if (nombre.text != value.toUpperCase())
                  nombre.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){return value.isEmpty ? "Ingresa la CURP" : null;},
            )
          ),
          flexPadded(TextFormField(
              controller: apellidoSegundo,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: "RFC"
              ),
              textCapitalization: TextCapitalization.sentences,
              onChanged: (value) {
                if (nombre.text != value.toUpperCase())
                  nombre.value = nombre.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){return value.isEmpty ? "Ingresa el RFC" : null;},
            )
          )
        ]
      ),
      Column(
        children: buttonWidget(),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text("Paso 1 de 2", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))
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
      color: Colors.blue,
      textColor: Colors.white,
      child: Text(text),
    );
  }

  void validaSubmit(){
    FocusScope.of(context).requestFocus(FocusNode());
    if(formKey.currentState.validate()){
      _buttonStatus();
    }else{
      final snackBar = SnackBar(
        content: Text("Error al guardar.", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.pink[800],
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
}