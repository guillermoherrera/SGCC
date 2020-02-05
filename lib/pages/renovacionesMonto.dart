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
        title: Text(widget.renovacion.nombre),
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
                colors: [Colors.green[100], Colors.white])
              ),
            ),
            SingleChildScrollView(
              child: Container(
                child: Card(
                  color: Colors.white70,
                  margin:  EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 8.0,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(children: vista())
                  )
                )
              )
            )
          ]
        )
      ),
    ));
  }

  List<Widget> vista(){
    return [
      padded(
        TextFormField(
          controller: importe,
          maxLength: 14,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40.0),
          decoration: InputDecoration(
            labelText: "Importe Capital",
            prefixIcon: Icon(Icons.attach_money, size: 40.0,),
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
      Padding(padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0), child:SizedBox(width: double.infinity, child: RaisedButton(
        onPressed: ()async{
          validaSubmit();
          //widget.montoChange(3, 10.0);
          //Navigator.push(context, MaterialPageRoute(builder: (context) => ConfiaShopView()));
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("ACTUALIZAR IMPORTE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),]),
        color: widget.colorTema,
      ))),
      Divider(),
      datos(),
      Divider(),
      Image.asset("images/confiaShop.png", height: 70,),
      confiaShop()
    ];
  }

  Widget padded(Widget childs){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: childs,
    );
  }

  Widget datos(){
    return Column(
      children: <Widget>[
        Container(child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("DATOS DEL CLIENTE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0)),
          ],
        ), margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0)),
        Table(
          columnWidths: {0: FractionColumnWidth(.1)},
          children: [
            TableRow(
              children: [
                Icon(Icons.person, size: 15.0, color: widget.colorTema,),
                Text("NOMBRE: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                Text(widget.renovacion.nombre, style: TextStyle(fontSize: 15.0)),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.attach_money, size: 15.0, color: widget.colorTema,),
                Text("IMPORTE: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                Text(widget.renovacion.importe.toStringAsFixed(2), style: TextStyle(fontSize: 15.0, color: importeActualiza ? Colors.green : Colors.black, fontWeight: importeActualiza ? FontWeight.bold : null)),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.attach_money, size: 15.0, color: widget.colorTema,),
                Text("CAPITAL: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                Text(widget.renovacion.capital.toStringAsFixed(2), style: TextStyle(fontSize: 15.0)),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.calendar_today, size: 15.0, color: widget.colorTema,),
                Text("DÍAS DE ATRASO: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                Text(widget.renovacion.diasAtraso.toString(), style: TextStyle(fontSize: 15.0)),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.format_list_numbered, size: 15.0, color: widget.colorTema,),
                Text("CLIENTE ID: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                Text(widget.renovacion.clienteID.toString(), style: TextStyle(fontSize: 15.0)),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.format_list_numbered, size: 15.0, color: widget.colorTema,),
                Text("CRÉDITO ID: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                Text(widget.renovacion.creditoID.toString(), style: TextStyle(fontSize: 15.0)),
              ]
            ),
            TableRow(
              children: [
                Icon(Icons.shopping_cart, size: 15.0, color: widget.colorTema,),
                Text("BENEFICIO CONFIASHOP: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0)),
                Text(widget.renovacion.beneficios != null ? widget.renovacion.beneficios[0]['cveBeneficio'] : "N/A", style: TextStyle(fontSize: 15.0)),
              ]
            ),
          ],
        )
      ],
    );
  }

  Widget confiaShop(){    
    return Padding(padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0), child:SizedBox(width: double.infinity, child: RaisedButton(
      onPressed: ()async{
        Navigator.push(context, MaterialPageRoute(builder: (context) => ConfiaShopView()));
      },
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Icon(Icons.shopping_cart, color: Colors.white) ,Text("ConfiaShop", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),]),
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