import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:responsive_container/responsive_container.dart';
import 'package:sgcartera_app/classes/consulta_cartera.dart';
import 'package:sgcartera_app/models/grupo_renovacion.dart';
import 'package:sgcartera_app/models/responses.dart';
import 'package:sgcartera_app/pages/renovacionesDetalle.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cartera.dart';
import 'mis_solicitudes.dart';

class Renovaciones extends StatefulWidget {
  Renovaciones({this.colorTema, this.actualizaHome, this.cambio});
  final Color colorTema;
  final VoidCallback actualizaHome;
  int cambio;
  @override
  _RenovacionesState createState() => _RenovacionesState();
}

class _RenovacionesState extends State<Renovaciones> {
  //List<GrupoRenovacion> listaRenovacion = List();
  List<Contrato> listaRenovacion = List();
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 7));
  String mensaje = "Cargando ...🕔";
  ConsultaCartera consultaCartera = new ConsultaCartera();
  int userType = 1;

  Future displayDateRangePicker(BuildContext context)async{
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: startDate,
      initialLastDate: endDate,
      firstDate: new DateTime(2015),
      lastDate: new DateTime(DateTime.now().year + 1)
    );
    if (picked != null && picked.length == 2) {
      setState(() {
        listaRenovacion.clear();
      });
      print(picked);
      setState((){
        mensaje = "Cargando ...🕔";
        startDate = picked[0];
        endDate = picked[1];
        getListDocumentos();
      });
    }
  }

  @override
  void initState() {
    getListDocumentos();
    super.initState();
  }

  getListDocumentos()async{
    final pref = await SharedPreferences.getInstance();
    userType = pref.getInt('tipoUsuario');
    if(userType != null && userType > 0){
      await Future.delayed(Duration(seconds:1));
      ContratosRequest contratosRequest;
      contratosRequest = await consultaCartera.consultaContratosR(formatDate(startDate, [dd, '/', mm, '/', yyyy]), formatDate(endDate, [dd, '/', mm, '/', yyyy]));
      if(contratosRequest.result){
        listaRenovacion.clear();
        mensaje = "Consulta sin resultados.";//"Consulta del día "+formatDate(startDate, [dd, '/', mm, '/', yyyy])+" al día "+formatDate(endDate, [dd, '/', mm, '/', yyyy])+" sin resultados.";
        for(var i = 0; i < contratosRequest.contratosCant ; i++){
          Contrato contrato = new Contrato(
            status: contratosRequest.contratos[i].status,
            contratoId: contratosRequest.contratos[i].contratoId,
            nombreGeneral: contratosRequest.contratos[i].nombreGeneral,
            fechaTermina: contratosRequest.contratos[i].fechaTermina
          );
          listaRenovacion.add(contrato);
        }
        //someObjects.sort((a, b) => a.someProperty.compareTo(b.someProperty));
        //listaRenovacion.sort((a,b) => a.nombreGeneral.compareTo(b.nombreGeneral));
      }else{
        mensaje = contratosRequest.mensaje;
      }
    }
    setState(() {});
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
      case 2:
        Navigator.pushReplacement(context, MyCustomRoute(builder: (_) => Cartera(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome, cambio: widget.cambio) ));
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Cartera(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome, cambio: widget.cambio) ));
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
        title: Image.asset('images/adminconfia.png', color: Colors.white, fit: BoxFit.cover),//Text("Renovaciones", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        leading: Container(),
        actions: <Widget>[
          //IconButton(icon: Icon(Icons.date_range, color: Colors.white), onPressed: ()async{await displayDateRangePicker(context);},)
        ],
      ),
      body: userType == null ? Container() : userType == 0 ? Container(child: Center(child:SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[Image.asset("images/page_not_found.png"), Padding(padding: EdgeInsets.all(50), child:Text("Usuario no encontrado.\n\nTu usuario no esta asignado, ponte en contacto con soporte para mas información.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))]))),color: Colors.white,) : RefreshIndicator(
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
                  title: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text("\nCONTRATOS A TERMINAR: "+listaRenovacion.length.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white))),
                  subtitle: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children:<Widget>[Icon(Icons.calendar_today, color: Colors.white, size: 10,),  Text(" Consulta del día "+formatDate(startDate, [dd, '/', mm, '/', yyyy])+" al día "+formatDate(endDate, [dd, '/', mm, '/', yyyy]), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))])),
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
                  padding: EdgeInsets.fromLTRB(13, 16, 13, 3),
                  child: listaRenovacion.length > 0 ? renovacionLista() : Center(child: ListView.builder(shrinkWrap: true,itemCount: 1,itemBuilder:(context, index){ return Column(mainAxisAlignment: MainAxisAlignment.center, children:[mensaje == "Cargando ...🕔" ? Padding(padding: EdgeInsets.only(top:5), child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(widget.colorTema))) : Image.asset("images/empty.png"), Padding(padding: EdgeInsets.all(50), child:Text(mensaje, style: TextStyle( fontSize: 15)))]);}),),
                ),
              )
            )),
            /*ResponsiveContainer(
              heightPercent: 30.0,
              widthPercent: 100.0,
              child: Container(decoration: BoxDecoration(
                  gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [widget.colorTema, widget.colorTema])
                ), child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center ,children: <Widget>[Icon(Icons.assignment,color: Colors.white60, size: isLandscape ? 50.0 : 150.0), Text("CONTRATOS PROXIMOS A LIQUIDAR: "+listaRenovacion.length.toString(), style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),)]),
              )),
            ),
            SizedBox(width: double.infinity, child: Container(padding: EdgeInsets.all(10.0), child: Text("Consulta del día "+formatDate(startDate, [dd, '/', mm, '/', yyyy])+" al día "+formatDate(endDate, [dd, '/', mm, '/', yyyy]), style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),), color: Colors.blueAccent,),),
            Padding(padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0), child:SizedBox(width: double.infinity, child: RaisedButton(
              onPressed: ()async{ await displayDateRangePicker(context);},
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[Text("SELECCIONA LAS FECHAS PARA LA CONSULTA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Icon(Icons.touch_app, color: Colors.white,)]),
              color: widget.colorTema,
            ))),
            listaRenovacion.length > 0 ? Expanded(child: renovacionLista()) : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema)))),*/
          ])
          ]
        )
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.date_range, color: Colors.white), backgroundColor: widget.colorTema,onPressed: ()async{await displayDateRangePicker(context);}),
      bottomNavigationBar: Stack(
        children: <Widget>[
          Row(
            children:<Widget>[
              Expanded(child:Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xffffffff),)),
              Expanded(child: Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xffffffff),)),
              Expanded(child: Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xffffffff),)),
              Expanded(child: Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xff1a9cff),))
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
            currentIndex: 3,
            selectedItemColor: Color(0xff1a9cff),
            backgroundColor: Color(0xffffffff),
            unselectedItemColor: Color(0xffa9a9a9),
            onTap: _onItemTapped,
          ))
        ]
      )
    );
  }

  Widget renovacionLista(){
    return ListView.builder(
      itemCount: listaRenovacion.length,
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
                title: Text(listaRenovacion[index].nombreGeneral, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Contrato: " + listaRenovacion[index].contratoId.toString()+" | Status: " + listaRenovacion[index].status.toString()+"\nFecha termino: " + listaRenovacion[index].fechaTermina.substring(0, 10)),
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
          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> RenovacionesDetalle(colorTema: widget.colorTema, grupoInfo: listaRenovacion[index], actualizaHome: widget.actualizaHome)));},
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

/*RaisedButton(
              onPressed: ()async{ await displayDateRangePicker(context);},
              child: Text("Selecciona el rango de fechas"),
            ) */