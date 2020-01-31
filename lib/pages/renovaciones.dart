import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:responsive_container/responsive_container.dart';
import 'package:sgcartera_app/models/grupo_renovacion.dart';
import 'package:sgcartera_app/pages/renovacionesDetalle.dart';

class Renovaciones extends StatefulWidget {
  Renovaciones({this.colorTema, this.actualizaHome});
  final MaterialColor colorTema;
  final VoidCallback actualizaHome;
  @override
  _RenovacionesState createState() => _RenovacionesState();
}

class _RenovacionesState extends State<Renovaciones> {
  List<GrupoRenovacion> listaRenovacion = List();
  GlobalKey<RefreshIndicatorState> refreshKey = GlobalKey<RefreshIndicatorState>();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(Duration(days: 7));
  String mensaje = "Cargando ...🕔";

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
    await Future.delayed(Duration(seconds:1));
    listaRenovacion.clear();
    for(var i = 0; i <= 5; i++){
      GrupoRenovacion grupoRenovacion = new GrupoRenovacion(
        nombre: "Grupo Renovacion"+ (i+1).toString(),
        fechaTermino: startDate,
        grupoID: 400+i 
      );
      listaRenovacion.add(grupoRenovacion);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    final bool isLandscape = orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBar(
        title: Text("Renovaciones"),
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
          Column(children: <Widget>[
            ResponsiveContainer(
              heightPercent: 30.0,
              widthPercent: 100.0,
              child: Container(decoration: BoxDecoration(
                  gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [widget.colorTema[300], widget.colorTema[900]])
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
            listaRenovacion.length > 0 ? Expanded(child: renovacionLista()) : Padding(padding: EdgeInsets.all(20.0),child: Center(child: Text(mensaje, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: widget.colorTema)))),
            ]
          )
          ]
        )
      ),
    );
  }

  Widget renovacionLista(){
    return ListView.builder(
      itemCount: listaRenovacion.length,
      itemBuilder: (context, index){
        return InkWell(
          child: Card(
            child: Container(
              child: ListTile(
                leading: Icon(Icons.group, color: widget.colorTema,size: 40.0,),
                title: Text(listaRenovacion[index].nombre, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Fecha termino: " + formatDate(listaRenovacion[index].fechaTermino, [dd, '/', mm, '/', yyyy])),
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
          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context)=> RenovacionesDetalle(colorTema: widget.colorTema, grupoInfo: listaRenovacion[index], actualizaHome: widget.actualizaHome)));},
        );
      }
    );
  }
}

/*RaisedButton(
              onPressed: ()async{ await displayDateRangePicker(context);},
              child: Text("Selecciona el rango de fechas"),
            ) */