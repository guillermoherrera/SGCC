import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/consulta_cartera.dart';
import 'package:sgcartera_app/models/responses.dart';
import 'package:sgcartera_app/pages/carteraIntegrantes.dart';

class CarteraDetalle extends StatefulWidget {
  CarteraDetalle({this.colorTema, this.title, this.contrato});
  final Color colorTema;
  final String title;
  final int contrato;
  @override
  _CarteraDetalleState createState() => _CarteraDetalleState();
}

class _CarteraDetalleState extends State<CarteraDetalle> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  bool isData = false;
  ConsultaCartera consultaCartera = new ConsultaCartera();
  Widget cargando = Padding(padding: EdgeInsets.all(2), child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
  ContratoDetalleRequest contratoDRequest;
  Contrato contrato;

  @override
  void initState() {
    getInfo();
    super.initState();
  }

  getInfo()async{
    await Future.delayed(Duration(seconds:1));
    contratoDRequest = await consultaCartera.consultaContratoDetalle(widget.contrato);
    if(contratoDRequest.result){
      isData = true;
      contratoDRequest.contrato.nombreGeneral = widget.title;
      contratoDRequest.contrato.contratoId = widget.contrato;
      contrato = contratoDRequest.contrato;
    }else{
      cargando = Column(children:[
        Icon(Icons.perm_scan_wifi ,color: Colors.white, size: 40.0,),
        Text("Error al obtener Datos.", style: TextStyle(color: Colors.white),)
      ]);
      //Icon(Icons.signal_wifi_off ,color: Colors.white, size: 40.0,);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: ()async{
          await Future.delayed(Duration(seconds:1));
          await getInfo();
        },
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
            Column(
              children:<Widget>[
                InkWell(
                  child: Card(
                    elevation: 0.0,
                    child: Container(
                      child: ListTile(
                      //leading: Icon(Icons.assignment,color: Colors.white, size: 40.0,),
                      title: Text("", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white)),
                      subtitle: Center(child: isData ? Icon(Icons.account_balance_wallet,color: Colors.white, size: 40.0,) : cargando ),
                      //trailing: Text(""),
                      isThreeLine: true,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [widget.colorTema, widget.colorTema])
                      ),
                    )
                  ),
                  onTap: (){},
                ),
                Expanded(child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
                    ),
                    child:  Padding(
                      padding: EdgeInsets.fromLTRB(13, 13, 13, 3),
                      child: ListView.builder(
                        itemCount: 1,
                        itemBuilder: (context, index){
                          return datos();
                        }
                      )
                    ),
                  ))
                )
              ]
            )
          ]
        )
      ),
      floatingActionButton: isData ? FloatingActionButton(
        child: Icon(Icons.list, color: Colors.white),
        backgroundColor: widget.colorTema,onPressed: ()async{
          Navigator.push(context, MaterialPageRoute(builder: (context) => CarteraIntegrantes(colorTema: widget.colorTema, grupoInfo: contratoDRequest)));
          //await Navigator.push(context, MaterialPageRoute(builder: (context) =>  RenovacionMonto(renovacion: listaRenovacion[index], colorTema: widget.colorTema, index: index, montoChange: montoChange)));
        }
      ) : null,
    );
  }

  Widget datos(){
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.all(10.0), child: 
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Text("Cartera", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
              Text("Fecha Inicio: "+(isData ? contrato.fechaInicio.substring(0, 10) : "**/**/**")+"\nFecha Termino: "+(isData ? contrato.fechaTermina.substring(0, 10) : "**/**/**"), style: TextStyle(color: Colors.grey, fontSize: 16.0),)
            ],
          ),
        ),
        Padding(padding: EdgeInsets.all(10.0), child: 
          Table(
            columnWidths: {1: FractionColumnWidth(.4)},
            children: [
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Contrato ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text(widget.contrato.toString(), style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Importe Total ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text(isData ? "\$"+contrato.importe.toStringAsFixed(2): "\$*,*.*", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Saldo Actual ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text(isData ? "\$"+contrato.saldoActual.toStringAsFixed(2) : "\$*,*.*", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Saldo Atrasado ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text(isData ? "\$"+contrato.saldoAtrazado.toStringAsFixed(2) : "\$*,*.*", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Días Atraso ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text(isData ? contrato.diasAtrazo.toString() : "*", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
            ]
          )
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(child: 
            Card(
              color: Color(0xfff2f2f2),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50.0))//.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
              ),
              child:  Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start ,children: <Widget>[
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(isData ? "\$"+contrato.pagoXPlazo.toStringAsFixed(2) : "\$*,*.*", style: TextStyle(fontSize: 30.0))),
                  Text("Pago plazo", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text(isData ? contrato.ultimoPagoPlazo.toString() : "*", style: TextStyle(fontSize: 20.0)),
                  Text("Plazo actual", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text(isData ? contrato.plazos.toString() : "**", style: TextStyle(fontSize: 20.0)),
                  Text("Plazos", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  /*Text(""),
                  Text(isData ? contrato.integrantesCant.toString() : "*", style: TextStyle(fontSize: 20.0)),
                  Text("Integrantes", style: TextStyle(color: widget.colorTema, fontSize: 15)),*/
                ])
              ),
            )),
            Expanded(child:
            Card(
              color: Color(0xfff2f2f2),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50.0))//.only(topLeft: Radius.circular(50.0), topRight: Radius.circular(50.0)),
              ),
              child:  Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start ,children: <Widget>[
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(isData ? "\$"+contrato.capital.toStringAsFixed(2) : "\$*,*.*", style: TextStyle(fontSize: 30.0))),
                  Text("Capital", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text(isData ? "\$"+contrato.interes.toStringAsFixed(2) : "\$*,*.*", style: TextStyle(fontSize: 20.0)),
                  Text("Interes", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text(isData ? contrato.integrantesCant.toString() : "*", style: TextStyle(fontSize: 20.0)),
                  Text("Integrantes", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  /*Text(""),
                  Text(isData ? contrato.status.toString() : "\$*,*.*", style: TextStyle(fontSize: 20.0)),
                  Text("Status", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text(isData ? contrato.contacto.toString() : "*", style: TextStyle(fontSize: 20.0)),
                  Text("Contacto", style: TextStyle(color: widget.colorTema, fontSize: 15)),*/
                ])
              ),
            )
            )
          ],
        ),
      ],
    );
  }
}