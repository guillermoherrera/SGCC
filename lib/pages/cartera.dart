import 'package:flutter/material.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:sgcartera_app/pages/carteraDetalle.dart';

class Cartera extends StatefulWidget {
  Cartera({this.colorTema});
  final Color colorTema;
  @override
  _CarteraState createState() => _CarteraState();
}

class _CarteraState extends State<Cartera> {
  List<String> listaCartera = List();
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  String mensaje = "Cargando ...🕔";

  @override
  void initState() {
    getListDocumentos();
    super.initState();
  }

  getListDocumentos()async{
    await Future.delayed(Duration(seconds:1));
    listaCartera.clear();
    for(var i = 0; i <= 5; i++){
      listaCartera.add(i.toString());
    }
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBar(
        title: Text("Mi Cartera", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        key: refreshKey,
        onRefresh: ()async{
          await Future.delayed(Duration(seconds:1));
          await getListDocumentos();
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
            Column(children: <Widget>[
              InkWell(
                child: Card(
                  elevation: 0.0,
                  child: Container(
                    child: ListTile(
                    leading: Icon(Icons.assignment,color: Colors.white, size: 40.0,),
                    title: Text("\nCONTRATOS EN CARTERA: "+listaCartera.length.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white)),
                    subtitle: Row(children:<Widget>[Text("", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))]),
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
                    child: listaCartera.length > 0 ? carteraLista() : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)))),
                  ),
                )
              )),
              /*ResponsiveContainer(
                heightPercent: 30.0,
                widthPercent: 100.0,
                child: Container(color: widget.colorTema, child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center ,children: <Widget>[Icon(Icons.assignment,color: Colors.white60, size: isLandscape ? 50.0 : 150.0), Text("CONTRATOS DE CARTERA: "+ listaCartera.length.toString(), style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),)]),
                )),
              ),
              listaCartera.length > 0 ? Expanded(child:carteraLista()) : Expanded(child: ListView())*/
            ],)
          ]
        )
      ),
    );
  }

  Widget carteraLista(){
    return ListView.builder(
      itemCount: listaCartera.length,
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
                leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Icon(Icons.group, color: widget.colorTema,size: 40.0,)]),
                title: Text("nombreGeneral " + listaCartera[index], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Contrato: 12345" + listaCartera[index]),
                isThreeLine: true,
                trailing: Column(children: <Widget>[ Icon(Icons.arrow_forward_ios)], mainAxisAlignment: MainAxisAlignment.center,),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, Colors.white])
              ),
            )
          ),
          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> CarteraDetalle(colorTema: widget.colorTema, title: "nombreGeneral " + listaCartera[index])));},
        );
      }
    );
  }
}