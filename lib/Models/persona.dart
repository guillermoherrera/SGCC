class Persona{
  String nombre;
  String nombreSegundo;
  String apellido;
  String apellidoSegundo;
  DateTime fechaNacimiento;
  String curp;
  String rfc;
  String telefono;

  Persona({
    this.nombre,
    this.apellido,
    this.apellidoSegundo,
    this.curp,
    this.fechaNacimiento,
    this.nombreSegundo,
    this.rfc,
    this.telefono
  });

  Map<String, dynamic> toJson()=>{
    'nombre': nombre,
    'apellido': apellido,
    'apellidoSegundo': apellidoSegundo,
    'curp': curp,
    'fechaNacimiento': fechaNacimiento,
    'nombreSegundo': nombreSegundo,
    'rfc': rfc,
    'telefono': telefono
  };
}
