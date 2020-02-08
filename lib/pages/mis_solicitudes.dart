import 'package:flutter/material.dart';
import 'package:sgcartera_app/pages/grupos.dart';
import 'package:sgcartera_app/pages/lista_solicitudes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MisSolicitudes extends StatefulWidget {
  MisSolicitudes({this.colorTema, this.actualizaHome});
  Color colorTema;
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
        title: Text("Mis Solicitudes", style: TextStyle(color: Colors.white),),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
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
                    padding: EdgeInsets.all(13.0),
                    child: listaOpciones()
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
    );
  }

  Widget listaOpciones(){
    return ListView.builder(
      itemCount: 6,
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
                leading: iconoItem(index),
                title: textoItem(index),
                subtitle: Text(""),//Text(getImporte(grupos[index])),
                isThreeLine: true,
                //trailing: getIcono(grupos[index])
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
          return Padding(padding: EdgeInsets.all(10),child: Center(child:Text("\nGrupos Capturados (grupos abiertos)", style: TextStyle(fontWeight: FontWeight.bold),)),);
        }
        break;
      case 1:
        String texto = userType == 1 ? "\nEn Espera (no sincronizado)" : userType == 2 ? "\nEn Espera (grupos cerrados)" : "\nEn Espera (solicitudes y grupos cerrados)";
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