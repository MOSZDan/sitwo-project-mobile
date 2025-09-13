class Horario {
  final int id;
  final String hora;

  Horario({required this.id, required this.hora});

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'] as int,
      hora: (json['hora'] as String).substring(0, 5), // Formato HH:mm
    );
  }
}