class TipoConsulta {
  final int id;
  final String nombre;

  TipoConsulta({required this.id, required this.nombre});

  factory TipoConsulta.fromJson(Map<String, dynamic> json) {
    return TipoConsulta(
      id: json['id'] as int,
      nombre: json['nombreconsulta'] as String,
    );
  }
}
class ConsultaRequest {
  final String fecha;
  final int codpaciente;
  final int cododontologo;
  final int idhorario;
  final int idtipoconsulta;
  final int idestadoconsulta;

  ConsultaRequest({
    required this.fecha,
    required this.codpaciente,
    required this.cododontologo,
    required this.idhorario,
    required this.idtipoconsulta,
    required this.idestadoconsulta,
  });

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha,
      'codpaciente': codpaciente,
      'cododontologo': cododontologo,
      'idhorario': idhorario,
      'idtipoconsulta': idtipoconsulta,
      'idestadoconsulta': idestadoconsulta,
    };
  }
}