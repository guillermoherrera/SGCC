import 'package:flutter/material.dart';
import 'package:sgcartera_app/models/responses.dart';
import 'package:sgcartera_app/pages/carteraIntegrantesDetalle.dart';

class CarteraIntegrantes extends StatefulWidget {
  CarteraIntegrantes({this.colorTema, this.grupoInfo});
  final Color colorTema;
  final ContratoDetalleRequest grupoInfo;
  @override
  _CarteraIntegrantesState createState() => _CarteraIntegrantesState();
}

class _CarteraIntegrantesState extends State<CarteraIntegrantes> {
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Integrante> listaIntegrantes = List();
  String mensaje = "Cargando ...🕔";

  @override
  void initState() {
    getListDocumentos();
    super.initState();
  }

  getListDocumentos(){
    if(widget.grupoInfo.integrantes.length > 0)
      listaIntegrantes = widget.grupoInfo.integrantes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.grupoInfo.contrato.nombreGeneral, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        actions: <Widget>[],
      ),
      body: /*RefreshIndicator(
        key: refreshKey,
        onRefresh: ()async{
          await Future.delayed(Duration(seconds:1));
        },
        child:*/ Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [widget.colorTema, widget.colorTema])
              ),
            ),
            Column(children: <Widget>[
              InkWell(
                child: Card(
                  elevation: 0.0,
                  child: Container(
                    child: ListTile(
                    leading: Icon(Icons.group,color: Colors.white, size: 40.0,),
                    title: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text("\nINTEGRANTES: "+widget.grupoInfo.contrato.integrantesCant.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white))),
                    subtitle: Text("IMPORTE: "+ widget.grupoInfo.contrato.importe.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
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
                    child: listaIntegrantes.length > 0 ?  muestraLista() : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)))),
                  ),
                )
              )),
            ])
          ]
        )
      //),
    );
  }

  Widget muestraLista(){
    return ListView.builder(
      itemCount: listaIntegrantes.length,
      itemBuilder: (context, index){
        return InkWell(
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color:widget.colorTema, width:3.0),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(50.0),
                topRight: Radius.circular(50.0),
                bottomLeft: Radius.circular(50.0),
                bottomRight: Radius.circular(50.0)
              ),
            ),
            child: Container(
              child: ListTile(
                title: Text(listaIntegrantes[index].nombreCompleto,),
                subtitle: subtitleLista(listaIntegrantes[index]),
                trailing:  IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: ()async {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CarteraIntegranteDetalle(colorTema: widget.colorTema, integrante: listaIntegrantes[index], title: listaIntegrantes[index].nombreCompleto, contratoGpo: widget.grupoInfo.contrato )));
                  //await Navigator.push(context, MaterialPageRoute(builder: (context) =>  RenovacionMonto(renovacion: listaRenovacion[index], colorTema: widget.colorTema, index: index, montoChange: montoChange)));
                },),
                leading: IconButton(icon: Icon(Icons.person, color: widget.colorTema, size: 40.0), onPressed: (){}),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, Colors.white])
              ),
            )
          )
        );
      }
    );
  }

  Widget subtitleLista(Integrante integrante){
    return Text("IMPORTE: "+integrante.importe.toString(), style: TextStyle(fontWeight: FontWeight.bold));
  } 
}