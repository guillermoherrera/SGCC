import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/pages/cartera.dart';
import 'package:sgcartera_app/pages/mis_solicitudes.dart';
import 'package:sgcartera_app/pages/nuevas_solicitudes.dart';
import 'package:sgcartera_app/pages/root_page.dart';
import 'package:sgcartera_app/pages/solicitud.dart';

class CustomDrawer extends StatefulWidget {
  CustomDrawer({this.authFirebase, this.onSingIn});
  final AuthFirebase authFirebase;
  final VoidCallback onSingIn;
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String email = "correo@dominio.com", name = "Usuario";
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
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
                colors: [Colors.blue, Colors.white])
            ),
          ),
          InkWell(
            onTap: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootPage(authFirebase: widget.authFirebase,)));},
            child: ListTile(
              title: Text("Inicio"),
              leading: Icon(Icons.home, color: Colors.blue,),
            ),
          ),
          InkWell(
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => NuevasSolicitudes() ));},
            child: ListTile(
              title: Text("Nueva Solicitud de Crédito"),
              leading: Icon(Icons.add_to_photos, color: Colors.blue,),
            ),
          ),
          InkWell(
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> MisSolicitudes() ));},
            child: ListTile(
              title: Text("Mis Solicitudes"),
              leading: Icon(Icons.folder_open, color: Colors.blue,),
            ),
          ),
          InkWell(
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> Cartera() ));},
            child: ListTile(
              title: Text("Mi Cartera"),
              leading: Icon(Icons.account_balance_wallet, color: Colors.blue,),
            ),
          ),
          Divider(),
          InkWell(
            onTap: (){
              _logOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootPage(authFirebase: widget.authFirebase,)));
            },
            child: ListTile(
              title: Text("Cerrar Sesión"),
              leading: Icon(Icons.exit_to_app, color: Colors.red,),
            ),
          ),
          InkWell(
            onTap: (){},
            child: ListTile(
              title: Text("Acerca de ..."),
              leading: Icon(Icons.help, color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }

  void _logOut() async{
    await widget.authFirebase.signOut();
  }
}