import 'package:flutter/material.dart';
import 'package:sgcartera_app/classes/auth_firebase.dart';
import 'package:sgcartera_app/pages/acerca_de.dart';
import 'package:sgcartera_app/pages/cambio_contrasena.dart';
import 'package:sgcartera_app/pages/root_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerComponent extends StatefulWidget {
  DrawerComponent({this.authFirebase, this.onSingIn, this.colorTema, this.actualizaHome, this.changePass, this.sincManual });
  final AuthFirebase authFirebase;
  final VoidCallback onSingIn;
  final Color colorTema;
  final VoidCallback actualizaHome;
  final bool changePass;
  final bool sincManual;
  @override
  _DrawerComponentState createState() => _DrawerComponentState();
}

class _DrawerComponentState extends State<DrawerComponent> {
  String email = "correo@dominio.com", name = "", fechaSinc = "", sistema = "";
  bool sinc = false;
  double heigthSize = 100.0;

  Future<void> getDatos() async{
    final pref = await SharedPreferences.getInstance();
    email = pref.getString("email");
    name = pref.getString("name");
    fechaSinc = pref.getString("fechaSinc");
    sinc = pref.getBool("Sinc");
    sistema = getSistema(pref.getInt('sistema'));
    if(sinc == null){sinc = true;};
    setState(() {});
  }

  void _logOut() async{
    final pref = await SharedPreferences.getInstance();
    pref.clear();
    await widget.authFirebase.signOut();
  }
  
  @override
  void initState() {
    getDatos();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;
    if(isLandscape){
      setState(() { heigthSize = 10.0;});
    }else{
      setState(() { heigthSize = 100.0;});
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width * .99,
      child: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent, //or any other color you want. e.g Colors.blue.withOpacity(0.5)
        ),
        child: Drawer(
          child: Container(
            color: widget.colorTema.withOpacity(0.0),
            child: Column(           
              children: options(),
            )
          )
        )
      )
    );
  }

  String getSistema(sistema){
    switch (sistema) {
      case 1:
        return "VR";
        break;
      case 2:
        return "OPORTUNIDADES";
        break;
      case 3:
        return "CRECE";
        break;
      case 4:
        return "GYT";
        break;
      default:
        return "SIN SISTEMA";
    }
  }

  List<Widget> options() {
    return [
      Container(
        height: heigthSize,
        color: widget.colorTema.withOpacity(0.8),
      ),
      Container(child: ListView(
          shrinkWrap: true,
          children: _informacion(),
        ), color: widget.colorTema.withOpacity(0.8)
      ),
      Expanded(
        child: Container(
          child: ListView(
            children: _navegacion(),
          ),
          color: Colors.white.withOpacity(0.8),
          padding: EdgeInsets.symmetric(horizontal: 50.0),
        ),  
      ),
      SizedBox(child: Container(
        child: Center(
          child: Text(
            fechaSinc != null ? "Ultima Sincronización: "+fechaSinc : "",
            style: TextStyle(
              color: sinc == true ? Colors.black38 : Colors.red[200],
              fontWeight: FontWeight.bold
            )
          ),
        ),
        //height: 30,
        color: Colors.white.withOpacity(0.8),
      ), width: double.infinity),
    ];
  }

  List<Widget>_informacion() {
    return [
       Container(
        child: Icon(Icons.person, color: widget.colorTema, size: 100.0),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle
        ),
      ),
      Container(height: 10,),
      Padding(padding: EdgeInsets.symmetric(horizontal: 5.0),child: Center(child: FittedBox(fit:BoxFit.fitWidth, child: Text((name != "" ? name : "Asesor no especificado"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30))))),
      Center(child: Text(email+" | "+sistema, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,))),
      Container(height: heigthSize/2,),
    ];
  }

  List<Widget> _navegacion() {
    return [
      InkWell(
        onTap: (){Navigator.pop(context);},
        child: ListTile(
          title: Text("INICIO", style: TextStyle(fontWeight: FontWeight.bold),),
          leading: Container(
            child: Icon(Icons.home, color: Colors.white,),
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.colorTema
            ),
          )
        ),
      ),
      Divider(),
      InkWell(
        onTap: (){ Navigator.push(context, MaterialPageRoute(builder: (context) => CambioContrasena(colorTema: widget.colorTema, changePass: widget.changePass, actualizaHome: widget.actualizaHome) ));},
        child: ListTile(
          title: Text("CAMBIO DE CONTRASEÑA", style: TextStyle(fontWeight: FontWeight.bold),),
          leading: Container(
            child: Icon(Icons.lock, color: Colors.white,),
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.colorTema
            ),
          ),
          trailing: widget.changePass ? Icon(Icons.error, color: Colors.yellow[900]) : null,
        ),
      ),
      Divider(),
      InkWell(
        onTap: (){
          if(widget.sincManual){
            _logOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RootPage(authFirebase: widget.authFirebase, colorTema: widget.colorTema,)));
          }
        },
        child: ListTile(
          title: Text(widget.sincManual ? "CERRAR SESIÓN" : "SINCRONIZANDO ...", style: TextStyle(fontWeight: FontWeight.bold)),
          leading: widget.sincManual ? Container(
            child: Icon(Icons.exit_to_app, color: Colors.white,),
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.colorTema
            ),
          ) : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),),
        ),
      ),
      Divider(),
      InkWell(
        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> About(colorTema: widget.colorTema)));},
        child: ListTile(
          title: Text("ACERCA DE ...", style: TextStyle(fontWeight: FontWeight.bold)),
          leading: Container(
            child: Icon(Icons.info, color: Colors.white,),
            padding: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.colorTema
            ),
          ),
        ),
      )
    ];
  }
}