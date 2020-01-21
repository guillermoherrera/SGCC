import 'package:flutter/material.dart';
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
  }

  @override
  Widget build(BuildContext context) {
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
            listaCartera.length > 0 ? carteraLista() : ListView()
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
          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> CarteraDetalle(colorTema: widget.colorTema, title: "Item " + listaCartera[index])));},
        );
      }
    );
  }
}