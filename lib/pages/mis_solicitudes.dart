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
  final GlobalKey<AnimatedListState> _key = GlobalKey();

  Future<void> getInfo() async{
    final pref = await SharedPreferences.getInstance();
    userType = pref.getInt('tipoUsuario');
    setState(() {
      
    });
  }

  getListDocumentos()async{
    setState(() {
      items = 1;  
    });
    await Future.delayed(Duration(milliseconds:/*250*/300));
    for(int i=0;i<7;i++){
      _addItem(items);
      items++;
      await Future.delayed(Duration(milliseconds:/*250*/50));
    }
    /*setState(() {
      items = 8;
    });*/
  }
  _addItem(i){
    if(_key.currentState != null) _key.currentState.insertItem(i);
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
          //IconButton(icon: Icon(Icons.add_circle_outline, color: Colors.white), onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => NuevasSolicitudes(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome) ));},)
        ]
      ),
      body: userType == 0 ? Container(child: Center(child:SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[Image.asset("images/page_not_found.png"), Padding(padding: EdgeInsets.all(50), child:Text("Usuario no encontrado.\n\nTu usuario no esta asignado, ponte en contacto con soporte para mas información.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))]))),color: Colors.white,) : Container(
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
                    title: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text("\nMIS SOLICITUDES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0, color:Colors.white))),
                    subtitle: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Text("Seguimiento y estado de solicitudes.", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))),
                    //trailing: Text(""),
                    //isThreeLine: true,
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
                    child: items > 0 ? Stack(children:<Widget>[Center(child:Opacity(opacity: 0.0, child: Image.asset("images/onboarding.png"))),listaOpciones()]) : Center(child:Opacity(opacity: 1, child: Image.asset("images/onboarding.png")))
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
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add, color: Colors.white), backgroundColor: widget.colorTema,onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => NuevasSolicitudes(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome) ));}),
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
    return AnimatedList(
      key: _key,
      initialItemCount: items,
      itemBuilder: (context, index, animation){
        if(index == 0){
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: Row(children: <Widget>[
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                        child: Divider(
                          color: Colors.black,
                          height: 36,
                        )),
                  ),
                  Icon(Icons.phone_iphone, color: widget.colorTema),
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          color: Colors.black,
                          height: 36,
                        )),
                  ),
                ])
          );
        }else if(index == 4){
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child:Row(children: <Widget>[
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                        child: Divider(
                          color: Colors.black,
                          height: 36,
                        )),
                  ),
                  Icon(Icons.wifi, color: widget.colorTema),
                  Expanded(
                    child: new Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: Divider(
                          color: Colors.black,
                          height: 36,
                        )),
                  ),
                ])
          );
        }else{
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child:InkWell(
                  onTap: ()=>_accionItem(index),
                  child: Opacity(opacity: 0.8, child: Card(
                    /*shape: RoundedRectangleBorder(
                      side: BorderSide(color:widget.colorTema, width:3.0),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50.0),
                        topRight: Radius.circular(50.0),
                        bottomLeft: Radius.circular(50.0),
                        bottomRight: Radius.circular(50.0)
                      ),
                    ),*/
                    child: Container(
                      child: ListTile(
                        leading: iconoItem(index),
                        title: textoItem(index),
                        subtitle: Text(""),//Text(getImporte(grupos[index])),
                        //isThreeLine: true,
                        trailing: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[getNotif(index)])
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Colors.white, Colors.white]),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50.0),
                          topRight: Radius.circular(50.0),
                          bottomLeft: Radius.circular(50.0),
                          bottomRight: Radius.circular(50.0)
                        ),
                      ),
                    ),
                  ))
                )
          );
        }
      },
    );
  }

  Widget getNotif(index){
    if(index == 3){
      if(widget.cambio > 0){
        return  Container(child:Text(widget.cambio.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)), padding: EdgeInsets.all(4),decoration: BoxDecoration(color: Colors.red , shape: BoxShape.circle),);//Icon(Icons.filter_1, color: Colors.red);    
      }else{
        return Text("");
      }
      /*switch (widget.cambio) {
        case 0:
          return Text("");
          break;
        case 1:
          return  Container(child:Text(widget.cambio.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)), padding: EdgeInsets.all(6),decoration: BoxDecoration(color: Colors.red ,borderRadius: BorderRadius.all(Radius.circular(15))),);//Icon(Icons.filter_1, color: Colors.red);
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
      }*/
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

  Widget iconoItem(i){
    switch(i){
      case 1:
        if(userType == 1){
          return Icon(Icons.format_align_justify, size: 40,);
        }else{
          return Container(child: Icon(Icons.lock_open, size: 40,color: Colors.white), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.black ,borderRadius: BorderRadius.all(Radius.circular(25))));
        }
        break;
      case 2:
        return Container(child: Icon(Icons.lock, size: 40,color: Colors.white,), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.yellow[700] ,borderRadius: BorderRadius.all(Radius.circular(25))));
        break;
      case 5:
        return Container(child: Icon(Icons.done, size: 40, color: Colors.white), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.grey ,borderRadius: BorderRadius.all(Radius.circular(25))));
        break;
      case 3:
        return Container(child: Icon(Icons.autorenew, size: 40, color: Colors.white), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.blue ,borderRadius: BorderRadius.all(Radius.circular(25))));
        break;
      case 6:
        return Container(child: Icon(Icons.done, size: 40,color: Colors.white,), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: widget.colorTema ,borderRadius: BorderRadius.all(Radius.circular(25))));
        break;
      case 7:
        return Container(child: Icon(Icons.close, size: 40, color: Colors.white), padding: EdgeInsets.all(3),decoration: BoxDecoration(color: Colors.red ,borderRadius: BorderRadius.all(Radius.circular(25))));
        break;
      default:
        return Icon(Icons.add_call, size: 90);
        break;
    }
  }

  Widget textoItem(i){
    switch(i){
      case 1:
        if(userType == 1){
          return Center(child: FittedBox(fit:BoxFit.fitWidth, child: Text("\nMIS SOLICITUDES ...", style: TextStyle(fontWeight: FontWeight.bold),)),);
        }
        else{
          return Center(child: FittedBox(fit:BoxFit.fitWidth, child: Text("\nGrupos Abiertos (en Captura)", style: TextStyle(fontWeight: FontWeight.bold),)));
        }
        break;
      case 2:
        String texto = userType == 1 ? "\nEn Espera (no sincronizado)" : userType == 2 ? "\nGrupos Cerrados (En Espera)" : "\nEn Espera";
        return Center(child: FittedBox(fit:BoxFit.fitWidth, child: Text(texto, style: TextStyle(fontWeight: FontWeight.bold),)),);
        break;
      case 5:
        return Center(child: FittedBox(fit:BoxFit.fitWidth, child: Text("\nGrupos Por Dictaminar", style: TextStyle(fontWeight: FontWeight.bold))));
        break;
      case 3:
        return Center(child: FittedBox(fit:BoxFit.fitWidth, child: Text("\nCambio de Documentos", style: TextStyle(fontWeight: FontWeight.bold))));
        break;
      case 6:
        return Center(child: FittedBox(fit:BoxFit.fitWidth, child: Text("\nGrupos Dictaminados", style: TextStyle(fontWeight: FontWeight.bold))));
        break;
      case 7:
        return Center(child: FittedBox(fit:BoxFit.fitWidth, child: Text("\nGrupos Rechazados", style: TextStyle(fontWeight: FontWeight.bold))));
        break;
      default:
        return Center(child: FittedBox(fit:BoxFit.fitWidth, child: Text("\nx_x")));
        break;
    }
  }

  void _accionItem(i){
    switch(i){
      case 1:
        if(userType == 1){

        }
        else{
          Navigator.push(context, MaterialPageRoute(builder: (context) => Group(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome )));
        }
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "En Espera (no sincronizado)", status: 0, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome,) ));
        break;
      case 5:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "Por Dictaminar", status: 1, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "Cambio de Documentos", status: 2, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));
        break;
      case 6:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "Dictaminadas", status: 3, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));
        break;
      case 7:
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