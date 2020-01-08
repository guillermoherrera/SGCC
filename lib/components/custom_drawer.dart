import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/pages/acerca_de.dart';
import 'package:sgcartera_app/pages/cartera.dart';
import 'package:sgcartera_app/pages/home.dart';
import 'package:sgcartera_app/pages/lista_solicitudes.dart';
import 'package:sgcartera_app/pages/mis_solicitudes.dart';
import 'package:sgcartera_app/pages/nuevas_solicitudes.dart';
import 'package:sgcartera_app/pages/root_page.dart';
import 'package:sgcartera_app/pages/solicitud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({this.authFirebase, this.onSingIn, this.colorTema, this.actualizaHome, this.cantSolicitudesCambios, this.sincManual });
  final AuthFirebase authFirebase;
  final VoidCallback onSingIn;
  final MaterialColor colorTema;
  final VoidCallback actualizaHome;
  final int cantSolicitudesCambios;
  final bool sincManual;
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String email = "correo@dominio.com", name = "", fechaSinc = "";
  bool sinc = false;

  Future<void> getDatos() async{
    final pref = await SharedPreferences.getInstance();
    email = pref.getString("email");
    fechaSinc = pref.getString("fechaSinc");
    sinc = pref.getBool("Sinc");
    setState(() {});
  }
  
  @override
  void initState() {
    getDatos();
    // TODO: implement initState
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: <Widget>[Expanded(child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(email, style: TextStyle(color: Colors.black),),
            accountEmail: Text(name, style: TextStyle(color: Colors.black)),
            currentAccountPicture: GestureDetector(
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white,)
              ),
            ),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [widget.colorTema, Colors.white])
            ),
          ),
          InkWell(
            onTap: (){widget.sincManual ? Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>HomePage(onSingIn: (){}, colorTema: widget.colorTema,)), (Route<dynamic> route) => false) : Navigator.pop(context); },//Navigator.popUntil(context, ModalRoute.withName('/'));},//Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootPage(authFirebase: widget.authFirebase, colorTema: widget.colorTema,)));},
            child: ListTile(
              title: Text("Inicio", style: TextStyle(fontWeight: FontWeight.bold),),
              leading: Icon(Icons.home, color: widget.colorTema[900],),
            ),
          ),
          Divider(),
          InkWell(
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => NuevasSolicitudes(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome) ));},
            child: ListTile(
              title: Text("Nueva Solicitud de Crédito"),
              leading: Icon(Icons.add_to_photos, color: widget.colorTema,),
            ),
          ),
          InkWell(
            onTap: (){widget.sincManual ? Navigator.push(context, MaterialPageRoute(builder: (context)=> MisSolicitudes(colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) )) : Navigator.pop(context);},
            child: ListTile(
              title: Text("Mis Solicitudes"),
              leading: Icon(Icons.folder_open, color: widget.colorTema,),
            ),
          ),
          InkWell(
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "Cambio de Documentos", status: 2, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));},
            child: ListTile(
              title: Text("Cambio de Documentos"),
              leading: Icon(Icons.autorenew, color: widget.colorTema,),
              trailing: numeroACambiar(widget.cantSolicitudesCambios),
            ),
          ),
          Divider(),
          InkWell(
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> Cartera() ));},
            child: ListTile(
              title: Text("Mi Cartera"),
              leading: Icon(Icons.account_balance_wallet, color: widget.colorTema,),
            ),
          ),
          Divider(),
          InkWell(
            onTap: (){},
            child: ListTile(
              title: Text("Renovaciones"),
              leading: Icon(Icons.cached, color: widget.colorTema,),
            ),
          ),
          Divider(),
          InkWell(
            onTap: (){
              _logOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootPage(authFirebase: widget.authFirebase, colorTema: widget.colorTema,)));
            },
            child: ListTile(
              title: Text("Cerrar Sesión"),
              leading: Icon(Icons.exit_to_app, color: Colors.red,),
            ),
          ),
          InkWell(
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> About(colorTema: widget.colorTema)));},
            child: ListTile(
              title: Text("Acerca De ..."),
              leading: Icon(Icons.info, color: Colors.blueAccent),
            ),
          )
        ],
      ),),Text(fechaSinc != null ? "Ultima Sincronización: "+fechaSinc : "", style: TextStyle(color: sinc ? Colors.black38 : Colors.red[200], fontWeight: FontWeight.bold))])
    );
  }

  void _logOut() async{
    final pref = await SharedPreferences.getInstance();
    pref.clear();
    await widget.authFirebase.signOut();
  }

  Widget numeroACambiar(int n){
    switch (n) {
      case 0:
        return Text("");
        break;
      case 1:
        return Icon(Icons.filter_1, color: Colors.redAccent[700]);
        break;
      case 2:
        return Icon(Icons.filter_2, color: Colors.redAccent[700]);
        break;
      case 3:
        return Icon(Icons.filter_3, color: Colors.redAccent[700]);
        break;
      case 4:
        return Icon(Icons.filter_4, color: Colors.redAccent[700]);
        break;
      case 5:
        return Icon(Icons.filter_5, color: Colors.redAccent[700]);
        break;
      case 6:
        return Icon(Icons.filter_6, color: Colors.redAccent[700]);
        break;
      case 7:
        return Icon(Icons.filter_7, color: Colors.redAccent[700]);
        break;
      case 8:
        return Icon(Icons.filter_8, color: Colors.redAccent[700]);
        break;
      case 9:
        return Icon(Icons.filter_9, color: Colors.redAccent[700]);
        break;
      default:
        return Icon(Icons.filter_9_plus, color: Colors.redAccent[700]);
        break;
    }
  }
}