import 'package:flutter/material.dart';
import 'package:sgcartera_app/pages/grupos.dart';
import 'package:sgcartera_app/pages/lista_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cartera.dart';
import 'nuevas_solicitudes.dart';
import 'renovaciones.dart';

class MisSolicitudes extends StatefulWidget {
  MisSolicitudes({this.colorTema, this.actualizaHome, this.cambio});
  Color colorTema;
  final VoidCallback actualizaHome;
  int cambio;
  @override
  _MisSolicitudesState createState() => _MisSolicitudesState();
}

class _MisSolicitudesState extends State<MisSolicitudes> {
  int userType;
  int items = 0;

  Future<void> getInfo() async{
    final pref = await SharedPreferences.getInstance();
    userType = pref.getInt('tipoUsuario');
    setState(() {
      
    });
  }

  getListDocumentos()async{
    await Future.delayed(Duration(milliseconds:250));
    setState(() {
      items = 6;
    });
  }

  @override
  void initState() {
    getInfo();
    getListDocumentos();
    super.initState();
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pop(context);
      break;
      case 2:
        Navigator.pushReplacement(context, MyCustomRoute(builder: (_) => Cartera(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome, cambio: widget.cambio,) ));
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Cartera(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome, cambio: widget.cambio,) ));
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
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('images/adminconfia.png', color: Colors.white, fit: BoxFit.cover),//Text("Mis Solicitudes", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
        leading: Container(),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add_circle_outline, color: Colors.white), onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => NuevasSolicitudes(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome) ));},)
        ]
      ),
      body: userType == 0 ? Center(child: Padding(padding: EdgeInsets.all(50), child:Text("Tu Usuario no esta asignado.  ☹️☹️☹️\n\nPonte en contacto con soporte para mas información.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema)))) : Container(
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
                    //leading: Icon(Icons.assignment,color: Colors.white, size: 40.0,),
                    title: Text("\n", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white)),
                    subtitle: Center(child: Icon(Icons.assignment,color: Colors.white, size: 40.0,)),
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
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(13, 13, 13, 3),//.all(13.0),
                    child: items > 0 ? listaOpciones() : Container()
                  ),
                )
              )),
            ]),
            /*GridView.builder(
              itemCount: 6,//userType == 1 ? 5 : 6,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index){
                int iter = index;//iter = userType == 1 ? index+1 : index;
                return Padding(
                  padding: const EdgeInsets.all(0),
                  child: itemSolicitudes(iter),
                );
              }
            )*/
          ]
        )
      ),
      bottomNavigationBar: Stack(
        children: <Widget>[
          Row(
            children:<Widget>[
              Expanded(child:Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xffffffff),)),
              Expanded(child: Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xff1a9cff),)),
              Expanded(child: Container(padding: EdgeInsets.all(20),child: Text(""), color: Color(0xffffffff),)),
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
            currentIndex: 1,
            selectedItemColor: Color(0xff1a9cff),
            backgroundColor: Color(0xffffffff),
            unselectedItemColor: Color(0xffa9a9a9),
            onTap: _onItemTapped,
          ))
        ]
      )
    );
  }

  Widget listaOpciones(){
    return ListView.builder(
      itemCount: items,
      itemBuilder: (context, index){
        return InkWell(
          onTap: ()=>_accionItem(index),
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
                leading: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[iconoItem(index)]),
                title: textoItem(index),
                subtitle: Text("\n"),//Text(getImporte(grupos[index])),
                isThreeLine: true,
                trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[getNotif(index)])
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.white, Colors.white])
              ),
            ),
          )
        );
      },
    );
  }

  Widget getNotif(index){
    if(index == 3){
      switch (widget.cambio) {
        case 0:
          return Text("");
          break;
        case 1:
          return  Container(child:Text(widget.cambio.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)), padding: EdgeInsets.all(9),decoration: BoxDecoration(color: Colors.red ,borderRadius: BorderRadius.all(Radius.circular(10))),);//Icon(Icons.filter_1, color: Colors.red);
          break;
        case 2:
          return Icon(Icons.filter_2, color: Colors.red);
          break;
        case 3:
          return Icon(Icons.filter_3, color: Colors.red);
          break;
        case 4:
          return Icon(Icons.filter_4, color: Colors.red);
          break;
        case 5:
          return Icon(Icons.filter_5, color: Colors.red);
          break;
        case 6:
          return Icon(Icons.filter_6, color: Colors.red);
          break;
        case 7:
          return Icon(Icons.filter_7, color: Colors.red);
          break;
        case 8:
          return Icon(Icons.filter_8, color: Colors.red);
          break;
        case 9:
          return Icon(Icons.filter_9, color: Colors.red);
          break;
        default:
          return Icon(Icons.filter_9_plus, color: Colors.red);
          break;
      }
    }else{
      return Container(child: Text(""));
    }
  }

  Widget itemSolicitudes(i){
    return Card(
      child: Hero(
        tag: Text("itemSolicitud"+i.toString()),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [widget.colorTema, Colors.white])
          ),
          child: InkWell(
            onTap: () => _accionItem(i) ,
            child: GridTile(
              child: iconoItem(i),
              footer: Container(
                color: Colors.white70,
                child: textoItem(i),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Icon iconoItem(i){
    switch(i){
      case 0:
        if(userType == 1){
          return Icon(Icons.format_align_justify, size: 40,);
        }else{
          return Icon(Icons.group, size: 40,color: Colors.black54);
        }
        break;
      case 1:
        return Icon(Icons.access_time, size: 40,color: Colors.yellow[700],);
        break;
      case 2:
        return Icon(Icons.done_all, size: 40, color: Colors.grey);
        break;
      case 3:
        return Icon(Icons.autorenew, size: 40, color: Colors.blue);
        break;
      case 4:
        return Icon(Icons.done_all, size: 40,color: Colors.green,);
        break;
      case 5:
        return Icon(Icons.block, size: 40, color: Colors.red);
        break;
      default:
        return Icon(Icons.add_call, size: 90);
        break;
    }
  }

  Widget textoItem(i){
    switch(i){
      case 0:
        if(userType == 1){
          return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("\nMIS SOLICITUDES ...", style: TextStyle(fontWeight: FontWeight.bold),)),);
        }
        else{
          return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("\nGrupos Capturados", style: TextStyle(fontWeight: FontWeight.bold),)),);
        }
        break;
      case 1:
        String texto = userType == 1 ? "\nEn Espera (no sincronizado)" : userType == 2 ? "\nEn Espera" : "\nEn Espera";
        return Padding(padding: EdgeInsets.all(10),child: Center(child:Text(texto, style: TextStyle(fontWeight: FontWeight.bold),)),);
        break;
      case 2:
        return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("\nPor autorizar", style: TextStyle(fontWeight: FontWeight.bold))));
        break;
      case 3:
        return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("\nCambio de Documentos", style: TextStyle(fontWeight: FontWeight.bold))));
        break;
      case 4:
        return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("\nDictaminadas", style: TextStyle(fontWeight: FontWeight.bold))));
        break;
      case 5:
        return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("\nRechazadas", style: TextStyle(fontWeight: FontWeight.bold))));
        break;
      default:
        return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("\nx_x")));
        break;
    }
  }

  void _accionItem(i){
    switch(i){
      case 0:
        if(userType == 1){

        }
        else{
          Navigator.push(context, MaterialPageRoute(builder: (context) => Group(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome )));
        }
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "En Espera (no sincronizado)", status: 0, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome,) ));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "Por autorizar", status: 1, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "Cambio de Documentos", status: 2, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "Dictaminadas", status: 3, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));
        break;
      case 5:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "Rechazadas", status: 4, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));
        break;
      default:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "x_x", status: 0, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));
        break;
    }
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