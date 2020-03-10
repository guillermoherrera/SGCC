import 'package:sgcartera_app/models/direccion.dart';
import 'package:sgcartera_app/models/persona.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Shared{

  cleanSharedP() async{
    final pref = await SharedPreferences.getInstance();
    pref.remove('curp');
    pref.remove('nombre');
    pref.remove('nombreSegundo');
    pref.remove('apellido');
    pref.remove('apellidoSegundo');
    pref.remove('fechaNacimiento');
    pref.remove('rfc');
    pref.remove('telefono');

    pref.remove('direccion1');
    pref.remove('colonia');
    pref.remove('municipio');
    pref.remove('ciudad');
    pref.remove('estado');
    pref.remove('cp');
  }

  guardarPersona(Persona persona) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('curp', persona.curp);
    pref.setString('nombre', persona.nombre);
    pref.setString('nombreSegundo', persona.nombreSegundo);
    pref.setString('apellido', persona.apellido);
    pref.setString('apellidoSegundo', persona.apellidoSegundo);
    pref.setInt('fechaNacimiento', persona.fechaNacimiento.millisecondsSinceEpoch);
    pref.setString('rfc', persona.rfc);
    pref.setString('telefono', persona.telefono);
  }

  guardarDireccion(Direccion direccion) async{
    final pref = await SharedPreferences.getInstance();
    pref.setString('direccion1', direccion.direccion1);
    pref.setString('colonia', direccion.coloniaPoblacion);
    pref.setString('municipio', direccion.delegacionMunicipio);
    pref.setString('ciudad', direccion.ciudad);
    pref.setString('estado', direccion.estado);
    pref.setInt('cp', direccion.cp);
  }

  Future<Persona> obtenerPersona() async {
    final pref = await SharedPreferences.getInstance();
    Persona persona = Persona(
      curp: pref.getString('curp'),
      nombre: pref.getString('nombre'),
      nombreSegundo: pref.getString('nombreSegundo'),
      apellido: pref.getString('apellido'),
      apellidoSegundo: pref.getString('apellidoSegundo'),
      fechaNacimiento: pref.getInt('fechaNacimiento') != null ? DateTime.fromMillisecondsSinceEpoch(pref.getInt('fechaNacimiento')) : null,
      rfc: pref.getString('rfc'),
      telefono: pref.getString('telefono')     
    );
    return persona;
  }

  Future<Direccion> obtenerDireccion() async{
    final pref = await SharedPreferences.getInstance();
    Direccion direccion = Direccion(
      direccion1: pref.getString('direccion1'),
      coloniaPoblacion: pref.getString('colonia'),
      delegacionMunicipio: pref.getString('municipio'),
      ciudad: pref.getString('ciudad'),
      estado: pref.getString('estado'),
      cp: pref.getInt('cp')
    );
    return direccion;
  }
}