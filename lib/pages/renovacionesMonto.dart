import 'package:flutter/material.dart';
import 'package:sgcartera_app/models/renovacion.dart';

import 'confia_shop.dart';

class RenovacionMonto extends StatefulWidget {
  RenovacionMonto({this.renovacion, this.colorTema, this.index, this.montoChange});
  RenovacionObj renovacion;
  final Color colorTema;
  final int index;
  //final VoidCallback montoChange;
  final void Function(int, double) montoChange;
  @override
  _RenovacionMontoState createState() => _RenovacionMontoState();
}

class _RenovacionMontoState extends State<RenovacionMonto> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var importe = TextEditingController();
  final formKey = new GlobalKey<FormState>();
  bool importeActualiza = false;

  @override
  void initState() {
    importe.text = widget.renovacion.importe.toStringAsFixed(0);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.renovacion.nombre, style: TextStyle(color: Colors.white)),
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
                              child: Row(mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[Icon(Icons.edit),Text("ACTUALIZAR IMPORTE", style: TextStyle(fontSize: 20),)]),
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
      Padding(padding: EdgeInsets.only(top: 20), child: Image.asset("images/confiaShop.png", height: 70,)),
      confiaShop(),
      /*Padding(padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0), child:SizedBox(width: double.infinity, child: RaisedButton(
        onPressed: ()async{
          validaSubmit();
          //widget.montoChange(3, 10.0);
          //Navigator.push(context, MaterialPageRoute(builder: (context) => ConfiaShopView()));
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("ACTUALIZAR IMPORTE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),]),
        color: widget.colorTema,
      ))),*/
      Divider(),
      padded(
        TextFormField(
          controller: importe,
          maxLength: 14,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0),
          decoration: InputDecoration(
            labelText: "Importe Capital",
            prefixIcon: Icon(Icons.attach_money, size: 40.0,),
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
      Divider(),
      Container(
        child: datos(),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Color(0xfff2f2f2)
        ),
      ),
    ];
  }

  Widget padded(Widget childs){
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 10),
      child: childs,
    );
  }

  Widget datos(){
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
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("NOMBRE: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.renovacion.nombre),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("RENOVACION IMPORTE: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.renovacion.importe.toStringAsFixed(2), style: TextStyle(color: importeActualiza ? Colors.green : Colors.black, fontWeight: importeActualiza ? FontWeight.bold : null)),
              ]
            ),
            TableRow(
              children: [
                Divider(),
                Divider(),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child:Text("DATOS ACTUALES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                Container()
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("IMPORTE: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.renovacion.importeHistorico.toStringAsFixed(2)),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("CAPITAL: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.renovacion.capital.toStringAsFixed(2)),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("DÍAS DE ATRASO: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.renovacion.diasAtraso.toString()),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("CLIENTE ID: ", style: TextStyle(fontWeight: FontWeight.bold, color:  Colors.grey))),
                Text(widget.renovacion.clienteID.toString()),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("CRÉDITO ID: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.renovacion.creditoID.toString()),
              ]
            ),
            TableRow(
              children: [
                Container(padding: EdgeInsets.only(bottom: 5),child: Text("BENEFICIO CONFIASHOP: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                Text(widget.renovacion.beneficios != null ? widget.renovacion.beneficios[0]['cveBeneficio'] : "N/A"),
              ]
            ),
          ],
        )
      ],
    );
  }

  Widget confiaShop(){    
    return Padding(padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0), child:SizedBox(width: double.infinity, child: RaisedButton(
      onPressed: ()async{
        Navigator.push(context, MaterialPageRoute(builder: (context) => ConfiaShopView()));
      },
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Icon(Icons.shopping_cart, color: Colors.white) ,Text(" CONFIASHOP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),]),
      color: Colors.purple,
    )));
  }

  void validaSubmit(){
    //FocusScope.of(context).requestFocus(FocusNode());
    var snackBar;

    if(formKey.currentState.validate()){
      if(double.parse(importe.text) != widget.renovacion.importe){      
        widget.montoChange(widget.index, double.parse(importe.text));
        setState(() {
          importeActualiza = true;
          widget.renovacion.importe = double.parse(importe.text);
        });
        snackBar = SnackBar(
          content: Text("Importe Capital Actualizado.", style: TextStyle(fontWeight: FontWeight.bold),),
          backgroundColor: Colors.green[300],
          duration: Duration(seconds: 3),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    }else{
      snackBar = SnackBar(
        content: Text("Error al actualizar. Revisa el formulario para más información.", style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.red[300],
        duration: Duration(seconds: 3),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }
}