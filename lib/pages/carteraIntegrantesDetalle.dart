import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/consulta_cartera.dart';
import 'package:sgcartera_app/models/responses.dart';

class CarteraIntegranteDetalle extends StatefulWidget {
  final Color colorTema;
  final String title;
  final Integrante integrante;
  final Contrato contratoGpo;
  CarteraIntegranteDetalle({this.colorTema, this.title, this.integrante, this.contratoGpo});
  @override
  _CarteraIntegranteDetalleState createState() => _CarteraIntegranteDetalleState();
}

class _CarteraIntegranteDetalleState extends State<CarteraIntegranteDetalle> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  bool isData = false;
  ConsultaCartera consultaCartera = new ConsultaCartera();
  Widget cargando = Padding(padding: EdgeInsets.all(2), child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
  IntegranteDetalleRequest integranteDetalleRequest;
  Integrante integrante;

  getInfo()async{
    await Future.delayed(Duration(seconds:1));
    integranteDetalleRequest = await consultaCartera.consultaIntegranteDetalle(widget.contratoGpo.contratoId, widget.integrante.cveCliente);
    if(integranteDetalleRequest.result){
      isData = true;
      integrante = integranteDetalleRequest.integrante;
    }else{
      cargando = Column(children:[
        Icon(Icons.perm_scan_wifi ,color: Colors.white, size: 40.0,),
        Text("Error al obtener Datos.", style: TextStyle(color: Colors.white),)
      ]);
    }
    setState(() {});
  }
  
  @override
  void initState() {
    getInfo();
    super.initState();
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
              Text("Fecha Termino: "+(isData ? integrante.fechaTermina.substring(0, 10) : "**/**/**")+"\nFecha Ultimo Pago: "+(isData ? integrante.fechaUltimoPago.substring(0, 10) : "**/**/**"), style: TextStyle(color: Colors.grey, fontSize: 16.0),)
            ],
          ),
        ),
        Padding(padding: EdgeInsets.all(10.0), child: 
          Table(
            columnWidths: {1: FractionColumnWidth(.4)},
            children: [
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Cliente ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text(widget.integrante.cveCliente, style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Importe ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text(isData ? "\$"+integrante.importe.toStringAsFixed(2): "\$*,*.*", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Saldo Actual ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text(isData ? "\$"+integrante.saldoActual.toStringAsFixed(2) : "\$*,*.*", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Saldo Atrasado ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text(isData ? "\$"+integrante.saldoAtrazado.toStringAsFixed(2) : "\$*,*.*", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Días Atraso ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text(isData ? integrante.diasAtrazo.toString() : "*", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
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
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(isData ? integrante.noCda.toString() : "*", style: TextStyle(fontSize: 30.0))),
                  Text("No. Corrida", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text(isData ? integrante.folio.toString() : "*", style: TextStyle(fontSize: 20.0)),
                  Text("Folio", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text(isData ? integrante.pagos.toString() : "**", style: TextStyle(fontSize: 20.0)),
                  Text("Pagos", style: TextStyle(color: widget.colorTema, fontSize: 15)),
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
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text(isData ? "\$"+integrante.capital.toStringAsFixed(2) : "\$*,*.*", style: TextStyle(fontSize: 30.0))),
                  Text("Capital", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text(isData ? "\$"+integrante.interes.toStringAsFixed(2) : "\$*,*.*", style: TextStyle(fontSize: 20.0)),
                  Text("Interes", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text(widget.integrante.telefono.toString(), style: TextStyle(fontSize: 20.0)),
                  Text("Teléfono", style: TextStyle(color: widget.colorTema, fontSize: 15)),
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