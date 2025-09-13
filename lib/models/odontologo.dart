class Odontologo {
  final int codUsuario;
  final String nombre;
  final String apellido;
  final String especialidad;

  Odontologo({
    required this.codUsuario,
    required this.nombre,
    required this.apellido,
    required this.especialidad,
  });

  String get nombreCompleto => '$nombre $apellido';

  factory Odontologo.fromJson(Map<String, dynamic> json) {
    final codUsuarioData = json['codusuario'] as Map<String, dynamic>;
    return Odontologo(
      codUsuario: codUsuarioData['codigo'] as int,
      nombre: codUsuarioData['nombre'] as String,
      apellido: codUsuarioData['apellido'] as String,
      especialidad: json['especialidad'] as String? ?? 'General',
    );
  }
}