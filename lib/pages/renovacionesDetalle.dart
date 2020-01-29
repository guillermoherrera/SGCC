import 'package:flutter/material.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:sgcartera_app/models/renovacion.dart';
import 'package:sgcartera_app/pages/renovacionesMonto.dart';

class RenovacionesDetalle extends StatefulWidget {
  RenovacionesDetalle({this.colorTema, this.title});
  final MaterialColor colorTema;
  final String title;
  @override
  _RenovacionesDetalleState createState() => _RenovacionesDetalleState();
}

class _RenovacionesDetalleState extends State<RenovacionesDetalle> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  List<Renovacion> listaRenovacion = List();
  List<Renovacion> listaRenEnviar = List();
  String mensaje = "Cargando ...🕔";
  int integrantes = 0;
  double importe = 0.0;
  List<bool> inputs = new List<bool>();

  @override
  void initState() {
    getListDocumentos();
    super.initState();
  }

  getListDocumentos()async{
    listaRenovacion.clear();
    inputs.clear();
    for(var i = 0; i <= 5; i++){
      Renovacion renovacion = new Renovacion(
        creditoID: 100+i, 
        clienteID: 1000+i,
        nombre: "Nombre Cliente " + (i+1).toString(),
        importe: 1000.0 + i,
        capital: 100.0 + i,
        diasAtraso: i, 
        beneficios: i%2 == 0 ? [{"cveBeneficio":"A"}] : null
      );
      /*importe += renovacion.importe;
      integrantes += 1;*/
      listaRenovacion.add(renovacion);
      listaRenEnviar.add(renovacion);
      inputs.add(true);
    }
    getSuma();
  }

  getSuma(){
    var envia = listaRenEnviar.where((r)=>r != null);
    var sum = envia.toList().fold(0, (a,b)=>a.importe + b.importe);
    print("object");
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.person_add), onPressed: () {
          })
        ],
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
                colors: [Colors.green[100], Colors.white])
              ),
            ),
            Column(children: <Widget>[
              ResponsiveContainer(
                heightPercent: 30.0,
                widthPercent: 100.0,
                child: Container(decoration: BoxDecoration(
                    gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [widget.colorTema[300], widget.colorTema[900]])
                  ), child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center ,children: <Widget>[Icon(Icons.group,color: Colors.white60, size: isLandscape ? 50.0 : 150.0), Text("INTEGRANTES: "+integrantes.toString()+"\nIMPORTE: "+importe.toString(), style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),)]),
                )),
              ),
              Padding(padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0), child:SizedBox(width: double.infinity, child: RaisedButton(
                onPressed: ()async{ },
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("SOLICITAR RENOVACIÓN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),]),
                color: widget.colorTema,
              ))),
              listaRenovacion.length > 0 ? Expanded(child: renovacionLista()) : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema)))),
            ])
          ]
        )
      ),
    );
  }

  Widget renovacionLista(){
    return ListView.builder(
      itemCount: listaRenovacion.length,
      itemBuilder: (context, index){
        return InkWell(
          child: Card(
            child: Container(
              child: ListTile(
                title: Text(listaRenovacion[index].nombre),
                subtitle: subtitleLista(listaRenovacion[index]),
                trailing: IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: ()async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) =>  RenovacionMonto(renovacion: listaRenovacion[index], colorTema: widget.colorTema, index: index)));
                },),
                leading: Checkbox(
                  value: inputs[index],
                  onChanged: (bool val){
                    itemChange(val, index);
                  },
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [widget.colorTema[400], Colors.white])
              ),
            )
          )
        );
      }
    );
  }

  Widget subtitleLista(Renovacion renovacion){
    if(renovacion.beneficios != null){
      return Text("IMPORTE: "+renovacion.importe.toString()+"     BENEFICIO CONFIASHOP", style: TextStyle(fontWeight: FontWeight.bold));
    }else{
      return Text("IMPORTE: "+renovacion.importe.toString(), style: TextStyle(fontWeight: FontWeight.bold));
    }
  } 

  void itemChange(bool val,int index){
    setState(() {
      inputs[index] = val;
      if(val){
        integrantes += 1;
        importe += listaRenovacion[index].importe;
        listaRenEnviar[index] = listaRenovacion[index];
      }else{
        integrantes -= 1;
        importe -= listaRenovacion[index].importe;
        listaRenEnviar[index] = null;
      }
    });
  }

  void montoChange(int index, double monto){

  }
}