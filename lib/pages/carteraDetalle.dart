import 'package:flutter/material.dart';

class CarteraDetalle extends StatefulWidget {
  CarteraDetalle({this.colorTema, this.title});
  final Color colorTema;
  final String title;
  @override
  _CarteraDetalleState createState() => _CarteraDetalleState();
}

class _CarteraDetalleState extends State<CarteraDetalle> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  
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
                      title: Text("\n", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white)),
                      subtitle: Center(child: Icon(Icons.account_balance_wallet,color: Colors.white, size: 40.0,)),
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
                      padding: EdgeInsets.all(13.0),
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
              Text("Fecha Termino: 24/10/19\nFecha Inicio: 24/10/19", style: TextStyle(color: Colors.grey, fontSize: 16.0),)
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
                  Align(child:Text("XXXXXX", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Importe Total ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text("\$20,000.00", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Saldo Actual ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text("\$50,000.00", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Saldo Atrasado ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text("\$30,000.00", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
                ]
              ),
              TableRow(
                children: [
                  Container(padding: EdgeInsets.only(bottom: 5),child: Text("Días Atraso ", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold, color: Colors.grey))),
                  Align(child:Text("0", style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),alignment: Alignment.centerRight),
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
                padding: EdgeInsets.all(30.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start ,children: <Widget>[
                  Text("\$1,000", style: TextStyle(fontSize: 30.0)),
                  Text("Pago plazo", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text("1", style: TextStyle(fontSize: 20.0)),
                  Text("Plazo actual", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text("10", style: TextStyle(fontSize: 20.0)),
                  Text("Plazos", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text("100", style: TextStyle(fontSize: 20.0)),
                  Text("Folio", style: TextStyle(color: widget.colorTema, fontSize: 15)),
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
                padding: EdgeInsets.all(30.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start ,children: <Widget>[
                  Text("\$1,000", style: TextStyle(fontSize: 30.0)),
                  Text("Capital", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text("\$1,000", style: TextStyle(fontSize: 20.0)),
                  Text("Interes", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text("\$1,000", style: TextStyle(fontSize: 20.0)),
                  Text("Comisión", style: TextStyle(color: widget.colorTema, fontSize: 15)),
                  Text(""),
                  Text("8712345678", style: TextStyle(fontSize: 20.0)),
                  Text("Telefonó", style: TextStyle(color: widget.colorTema, fontSize: 15)),
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