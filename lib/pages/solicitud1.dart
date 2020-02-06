import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:sgcartera_app/models/direccion.dart';
import 'package:sgcartera_app/models/solicitud.dart';
import 'package:sgcartera_app/pages/solicitud2.dart';
import 'package:sgcartera_app/sqlite_files/models/cat_estado.dart';

class SolicitudDireccion extends StatefulWidget {
  SolicitudDireccion({this.actualizaHome, this.colorTema, this.datos,this.title,this.estados, this.esRenovacion});
  final String title;
  final SolicitudObj datos;
  final Color colorTema;
  final VoidCallback actualizaHome;
  final List<CatEstado> estados;
  bool esRenovacion;
  @override
  _SolicitudDireccionState createState() => _SolicitudDireccionState();
}

class _SolicitudDireccionState extends State<SolicitudDireccion> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();
  var direccion1 = TextEditingController();
  var colonia = TextEditingController();
  var municipio = TextEditingController();
  var ciudad = TextEditingController();
  var estadoCod = TextEditingController();
  var cp = TextEditingController();
  var paisCod = TextEditingController();
  bool buttonEnabled = true;
  //List<CatEstado> estados = List();
  var estado;
  String estadoAux = "Estado";

  @override
  void initState() {
    if(widget.esRenovacion == null){widget.esRenovacion = false;}
    paisCod.text = "MX";
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
                              children: formSolicitudD(),
                            ),
                          ),
                          Expanded(child:  
                            Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: styleButton(validaSubmit, buttonEnabled ? "SIGUIENTE" : "CARGANDO ..."),
                            ),
                          )
                        ] 
                      ) 
                    ),
                  ),
                ));
              })
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> formSolicitudD(){
    return [
      Container(
        child: Center(
          child: Text("DIRECCIÓN DEL CLIENTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
      ),
      Divider(),
      padded(
        TextFormField(
          controller: direccion1,
          maxLength: 40,
          style: TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            labelText: "Calle y numero",
            fillColor: Color(0xfff2f2f2),
            filled: true,
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(10.0),
              ),
            ),
            //prefixIcon: Icon(Icons.attach_money)
          ),
          onChanged: (value) {
            if (direccion1.text != value.toUpperCase())
              direccion1.value = direccion1.value.copyWith(text: value.toUpperCase());
          },
          validator: (value){
            //return value.isEmpty ? "Ingresa el importe" : null;},
            if(value.isEmpty){
              return "Ingresa la calle y numero del domicilio";
            }else{
              return null;
            }
          }
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          flexPadded(TextFormField(
              controller: colonia,
              maxLength: 40,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Colonia",
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
                if (colonia.text != value.toUpperCase())
                  colonia.value = colonia.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){return value.isEmpty ? "Ingresa la colonia o población" : null;},
            )
          ),
          flexPadded(TextFormField(
              controller: municipio,
              maxLength: 40,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Delegación/Municipio",
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
                if (municipio.text != value.toUpperCase())
                  municipio.value = municipio.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){return value.isEmpty && ciudad.text.isEmpty ? "Ingresa la delegación o municipio" : null;},
            )
          )
        ]
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          flexPadded(TextFormField(
              controller: ciudad,
              maxLength: 40,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Ciudad",
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
                if (ciudad.text != value.toUpperCase())
                  ciudad.value = ciudad.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){return value.isEmpty && municipio.text.isEmpty ? "Ingresa la ciudad" : null;},
            )
          ),
          flexPadded(
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //Text("Estado: "),
                  InkWell(onTap:(){FocusScope.of(context).requestFocus(FocusNode());},child: DropdownButton(
                    items: widget.estados.map((f)=>DropdownMenuItem(
                      child: Text(f.estado),
                      value: f.codigo
                      )).toList(),
                    onChanged: MediaQuery.of(context).viewInsets.bottom == 0 ?(estadoSel){
                      setState(() {
                        estadoCod.text = estadoSel;
                        estado = estadoSel;
                        estadoAux = widget.estados.firstWhere((f)=>f.codigo == estadoSel).estado;
                      });
                    } : null,
                    value: estado,
                    underline: Container(color: Colors.grey,height: 1),
                    isExpanded: true,
                    hint: Text(estadoAux),
                  ))
                ],
              )
              /*TextFormField(
              controller: estadoCod,
              maxLength: 4,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Estado"
              ),
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                if (estadoCod.text != value.toUpperCase())
                  estadoCod.value = estadoCod.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){return value.isEmpty ? "Ingresa el Estado" : null;},
            )*/
          )
        ]
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          flexPadded(TextFormField(
              controller: cp,
              maxLength: 5,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Código Postal",
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
                  return "Ingresa el código postal";
                }else{
                  return value.length != 5 ? "Completa el código postals" : null;
                }
              },
            )
          ),
          flexPadded(TextFormField(
              controller: paisCod,
              maxLength: 4,
              style: TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "País",
                fillColor: Color(0xfff2f2f2),
                filled: true,
                border: new OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    const Radius.circular(10.0),
                  ),
                ),
              ),
              enabled: false,
              textCapitalization: TextCapitalization.characters,
              onChanged: (value) {
                if (paisCod.text != value.toUpperCase())
                  paisCod.value = paisCod.value.copyWith(text: value.toUpperCase());
              },
              validator: (value){return value.isEmpty ? "Ingresa el País" : null;},
            )
          )
        ]
      ),
      Container(
        child: datosPrevios(),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Color(0xfff2f2f2)
        ),
      )
      ,
      /*Column(
        children: buttonWidget(),
      ),*/
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text("Paso 2 de 3", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10))
        ],
      )
    ];
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
      padding: EdgeInsets.all(10),
      child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.arrow_forward),Text(text, style: TextStyle(fontSize: 20),)]),
    ));
  }

  void validaSubmit(){
    FocusScope.of(context).requestFocus(FocusNode());
    if(formKey.currentState.validate() && estado != null){
      _buttonStatus();
      Direccion direccion = new Direccion(
        direccion1: direccion1.text,
        coloniaPoblacion: colonia.text,
        delegacionMunicipio: municipio.text,
        ciudad: ciudad.text,
        estado: estadoCod.text,
        cp: int.parse(cp.text),
        pais: paisCod.text
      );
      widget.datos.direccion = direccion.toJson();
      _buttonStatus();
      Navigator.push(context, MaterialPageRoute(builder: (context)=>SolicitudDocumentos(title: widget.title, datos: widget.datos, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome, esRenovacion: widget.esRenovacion)));
      
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

  Widget padded(Widget childs){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: childs,
    );
  }

  Widget flexPadded(Widget childs){
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: childs,
      ),
    );
  }

  Widget datosPrevios(){
    return Column(
      children: <Widget>[
        Container(child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.person, color: widget.colorTema,),
            Text("DATOS DEL CLIENTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ), margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0)),
        Table(
          columnWidths: {1: FractionColumnWidth(.5)},
          children: [
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("IMPORTE CAPITAL: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.datos.importe.toStringAsFixed(2)),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("NOMBRE: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.datos.persona['nombre'] +" "+ widget.datos.persona['nombreSegundo'] +" "+ widget.datos.persona['apellido'] +" "+ widget.datos.persona['apellidoSegundo']),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("FECHA DE NACIMIENTO: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(formatDate(widget.datos.persona['fechaNacimiento'], [dd, '/', mm, '/', yyyy])),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("CURP: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.datos.persona['curp']),
              ],
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("RFC: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.datos.persona['rfc']),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("TELÉFONO: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.datos.persona['telefono']),
              ]
            )
          ],
        )
      ],
    );
  }
}