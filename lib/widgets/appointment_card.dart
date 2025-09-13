// lib/widgets/appointment_card.dart

import 'package:flutter/material.dart';

import '../models/consulta.dart';
import 'package:intl/intl.dart';

class AppointmentCard extends StatelessWidget {
  final Consulta consulta;

  const AppointmentCard({super.key, required this.consulta});

  @override
  Widget build(BuildContext context) {
    final DateTime date = DateTime.parse(consulta.fecha);
    final String formattedDate = DateFormat.yMMMMd('es_ES').format(date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF06B6D4),
                  ),
                ),
                Text(
                  consulta.horario.hora,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF06B6D4),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.medical_services_outlined,
              label: 'Consulta:',
              value: consulta.tipoConsulta.nombre,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Odontólogo:',
              value: consulta.odontologo.nombreCompleto,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Chip(
                label: Text(consulta.estadoConsulta.estado),
                backgroundColor: _getStatusColor(consulta.estadoConsulta.estado),
                labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'agendada':
        return Colors.blueAccent;
      case 'confirmada':
        return Colors.green;
      case 'cancelada':
        return Colors.redAccent;
      case 'completada':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}