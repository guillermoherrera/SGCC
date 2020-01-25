import 'package:flutter/material.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:sgcartera_app/pages/carteraDetalle.dart';

class Cartera extends StatefulWidget {
  Cartera({this.colorTema});
  final MaterialColor colorTema;
  @override
  _CarteraState createState() => _CarteraState();
}

class _CarteraState extends State<Cartera> {
  List<String> listaCartera = List();
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    getListDocumentos();
    super.initState();
  }

  getListDocumentos()async{
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
        title: Text("Mi Cartera"),
        centerTitle: true,
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
                colors: [Colors.green[100], Colors.white])
              ),
            ),
            Column(children: <Widget>[
              ResponsiveContainer(
                heightPercent: 30.0,
                widthPercent: 100.0,
                child: Container(color: widget.colorTema[700], child: Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center ,children: <Widget>[Icon(Icons.assignment,color: Colors.white60, size: isLandscape ? 50.0 : 150.0), Text("CONTRATOS DE CARTERA: "+ listaCartera.length.toString(), style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),)]),
                )),
              ),
              listaCartera.length > 0 ? Expanded(child:carteraLista()) : Expanded(child: ListView())
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
            child: Container(
              child: ListTile(
                leading: Icon(Icons.group, color: widget.colorTema,size: 40.0,),
                title: Text("Item " + listaCartera[index], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Subtitulo: Item " + listaCartera[index]),
                isThreeLine: true,
                trailing: Column(children: <Widget>[ Icon(Icons.arrow_forward_ios)], mainAxisAlignment: MainAxisAlignment.center,),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [widget.colorTema[400], Colors.white])
              ),
            )
          ),
          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> CarteraDetalle(colorTema: widget.colorTema, title: "Detalle Item " + listaCartera[index])));},
        );
      }
    );
  }
}