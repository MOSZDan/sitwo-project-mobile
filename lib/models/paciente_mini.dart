// lib/models/paciente_mini.dart

class UsuarioMini {
  final int codigo;
  final String nombre;
  final String apellido;

  UsuarioMini({
    required this.codigo,
    required this.nombre,
    required this.apellido,
  });

  factory UsuarioMini.fromJson(Map<String, dynamic> json) {
    return UsuarioMini(
      codigo: json['codigo'],
      nombre: json['nombre'],
      apellido: json['apellido'],
    );
  }
}

class PacienteMini {
  final UsuarioMini codusuario;
  final String carnetidentidad;

  PacienteMini({required this.codusuario, required this.carnetidentidad});

  factory PacienteMini.fromJson(Map<String, dynamic> json) {
    return PacienteMini(
      codusuario: UsuarioMini.fromJson(json['codusuario']),
      carnetidentidad: json['carnetidentidad'] ?? '',
    );
  }
}