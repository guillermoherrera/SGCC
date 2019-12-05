import 'package:flutter/material.dart';
import 'package:sgcartera_app/pages/grupos.dart';
import 'package:sgcartera_app/pages/lista_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MisSolicitudes extends StatefulWidget {
  MisSolicitudes({this.colorTema, this.actualizaHome});
  MaterialColor colorTema;
  final VoidCallback actualizaHome;
  @override
  _MisSolicitudesState createState() => _MisSolicitudesState();
}

class _MisSolicitudesState extends State<MisSolicitudes> {
  int userType;

  Future<void> getInfo() async{
    final pref = await SharedPreferences.getInstance();
    userType = pref.getInt('tipoUsuario');
    setState(() {
      
    });
  }

  @override
  void initState() {
    getInfo();
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Solicitudes"),
        centerTitle: true,
      ),
      body: userType == 0 ? Center(child: Padding(padding: EdgeInsets.all(50), child:Text("Tu Usuario no esta asignado. :(\n\nPonte en contacto con soporte para mas información."))) : Container(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [widget.colorTema[100], Colors.white])
              ),
            ),
            GridView.builder(
              itemCount: userType == 1 ? 4 : 5,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index){
                int iter = userType == 1 ? index+1 : index;
                return Padding(
                  padding: const EdgeInsets.all(0),
                  child: itemSolicitudes(iter),
                );
              }
            )
          ]
        )
      ),
    );
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
            colors: [widget.colorTema[400], Colors.white])
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
        return Icon(Icons.group, size: 90,color: Colors.yellow[700],);
        break;
      case 1:
        return Icon(Icons.access_time, size: 90,color: Colors.yellow[700],);
        break;
      case 2:
        return Icon(Icons.done_all, size: 90, color: Colors.grey);
        break;
      case 3:
        return Icon(Icons.done_all, size: 90,color: Colors.green,);
        break;
      case 4:
        return Icon(Icons.block, size: 90, color: Colors.red);
        break;
      default:
        return Icon(Icons.add_call, size: 90);
        break;
    }
  }

  Widget textoItem(i){
    switch(i){
      case 0:
        return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("Grupos Capturados\n", style: TextStyle(fontWeight: FontWeight.bold),)),);
        break;
      case 1:
        return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("En Espera (no\nsincronizadas)", style: TextStyle(fontWeight: FontWeight.bold),)),);
        break;
      case 2:
        return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("Por autorizar\n", style: TextStyle(fontWeight: FontWeight.bold))));
        break;
      case 3:
        return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("Aprobadas\n", style: TextStyle(fontWeight: FontWeight.bold))));
        break;
      case 4:
        return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("Denegadas\n", style: TextStyle(fontWeight: FontWeight.bold))));
        break;
      default:
        return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("x_x")));
        break;
    }
  }

  void _accionItem(i){
    switch(i){
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => Group(colorTema: widget.colorTema,actualizaHome: widget.actualizaHome )));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "En Espera (no sincronizadas)", status: 0, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome,) ));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "Por autorizar", status: 1, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "Aprobadas", status: 2, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "Denegadas", status: 3, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));
        break;
      default:
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ListaSolicitudes(title: "x_x", status: 0, colorTema: widget.colorTema, actualizaHome: widget.actualizaHome) ));
        break;
    }
  }
}