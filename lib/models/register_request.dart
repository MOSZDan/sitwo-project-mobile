class RegisterRequest {
  final String email;
  final String password;
  final String nombre;
  final String apellido;
  final String telefono;
  final String sexo; // "M" o "F"
  final String direccion;
  final String fechanacimiento;
  final String carnetidentidad;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.sexo,
    required this.direccion,
    required this.fechanacimiento,
    required this.carnetidentidad,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'sexo': sexo,
      'direccion': direccion,
      'fechanacimiento': fechanacimiento,
      'carnetidentidad': carnetidentidad,
    };
  }
}

class RegisterResponse {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? errors;

  RegisterResponse({
    required this.success,
    required this.message,
    this.token,
    this.errors,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
      errors: json['errors'],
    );
  }
}
