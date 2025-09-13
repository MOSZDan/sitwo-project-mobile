// lib/models/consulta.dart

import 'horario.dart';
import 'odontologo.dart';
import 'paciente_mini.dart';
import 'tipo_consulta.dart';

class EstadoConsulta {
  final int id;
  final String estado;

  EstadoConsulta({required this.id, required this.estado});

  factory EstadoConsulta.fromJson(Map<String, dynamic> json) {
    return EstadoConsulta(
      id: json['id'],
      estado: json['estado'],
    );
  }
}

class Consulta {
  final int id;
  final String fecha;
  final PacienteMini paciente;
  final Odontologo odontologo;
  final Horario horario;
  final TipoConsulta tipoConsulta;
  final EstadoConsulta estadoConsulta;

  Consulta({
    required this.id,
    required this.fecha,
    required this.paciente,
    required this.odontologo,
    required this.horario,
    required this.tipoConsulta,
    required this.estadoConsulta,
  });

  factory Consulta.fromJson(Map<String, dynamic> json) {
    return Consulta(
      id: json['id'],
      fecha: json['fecha'],
      paciente: PacienteMini.fromJson(json['codpaciente']),
      odontologo: Odontologo.fromJson(json['cododontologo']),
      horario: Horario.fromJson(json['idhorario']),
      tipoConsulta: TipoConsulta.fromJson(json['idtipoconsulta']),
      estadoConsulta: EstadoConsulta.fromJson(json['idestadoconsulta']),
    );
  }
}