import 'package:flutter/material.dart';
import 'package:responsive_container/responsive_container.dart';
import 'package:sgcartera_app/pages/carteraDetalle.dart';

import 'mis_solicitudes.dart';
import 'renovaciones.dart';

class Cartera extends StatefulWidget {
  Cartera({this.colorTema, this.actualizaHome, this.cambio});
  final Color colorTema;
  final VoidCallback actualizaHome;
  int cambio;
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
      listaCartera.add((i+1).toString());
    }
    setState(() {
      
    });
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pop(context);
      break;
      case 1:
        Navigator.pushReplacement(context, MyCustomRoute(builder: (_) => MisSolicitudes(colorTema: widget.colorTema, actualizaHome: widget.actualizaHome, cambio: widget.cambio) ));
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MisSolicitudes(colorTema: widget.colorTema, actualizaHome: widget.actualizaHome, cambio: widget.cambio) ));
      break;
      case 3:
        Navigator.pushReplacement(context, MyCustomRoute(builder: (_) => Renovaciones(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome, cambio: widget.cambio) )); 
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Renovaciones(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome, cambio: widget.cambio) )); 
      break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('images/adminconfia.png', color: Colors.white, fit: BoxFit.cover),//Text("Mi Cartera", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        leading: Container(),
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
                    title: Text("\nLISTA DE CONTRATOS EN CARTERA: "+listaCartera.length.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white)),
                    subtitle: Row(children:<Widget>[Text(" ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))]),
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
      bottomNavigationBar: Stack(
        children: <Widget>[
          Row(
            children:<Widget>[
              Expanded(child:Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xffffffff),)),
              Expanded(child: Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xffffffff),)),
              Expanded(child: Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xff1a9cff),)),
              Expanded(child: Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xffffffff),))
            ]
          ),
          Container(margin: EdgeInsets.only(top:3),child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                title: Text('Inicio'),
              ),
              BottomNavigationBarItem(
                icon: widget.cambio == null ? Icon(Icons.monetization_on) : widget.cambio > 0 ? Stack(children: <Widget>[
                  Icon(Icons.monetization_on),
                  Positioned(
                      bottom: -5.0,
                      left: 8.0,
                      child: new Center(
                        child: new Text(
                          ".",
                          style: new TextStyle(
                              color: Colors.red,
                              fontSize: 90.0,
                              fontWeight: FontWeight.w500

                          ),
                        ),
                      )),
                    ],
                  ) : Icon(Icons.monetization_on),
                title: Text('Solicitudes'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                title: Text('Cartera'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.cached),
                title: Text('Renovación'),
              ),
            ],
            currentIndex: 2,
            selectedItemColor: Color(0xff1a9cff),
            backgroundColor: Color(0xffffffff),
            unselectedItemColor: Color(0xffa9a9a9),
            onTap: _onItemTapped,
          ))
        ]
      )
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
                title: Text("LAS PAGADORAS " + listaCartera[index], style: TextStyle(fontWeight: FontWeight.bold)),
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
          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> CarteraDetalle(colorTema: widget.colorTema, title: "LAS PAGADORAS " + listaCartera[index], contrato: 123450+index+1,)));},
        );
      }
    );
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (settings.isInitialRoute)
      return child;
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return new FadeTransition(opacity: animation, child: child);
  }
}