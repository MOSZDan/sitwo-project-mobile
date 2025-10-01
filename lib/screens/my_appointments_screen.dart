// lib/screens/my_appointments_screen.dart
import 'package:flutter/material.dart';
import '../models/consulta.dart';
import '../services/http_service.dart';
import '../widgets/appointment_card.dart';
import 'schedule_appointment_screen.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final HttpService _httpService = HttpService();
  List<Consulta>? _appointments;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMyAppointments();
  }

  Future<void> _fetchMyAppointments() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final patientId = await _httpService.getPatientId();
      if (patientId == null) {
        throw Exception('ID de paciente no encontrado. Por favor, inicie sesión de nuevo.');
      }

      final response = await _httpService.get('/api/consultas/?codpaciente=$patientId');
      final List<dynamic> results = response['results'];
      
      // Filtrar citas para excluir las pasadas y las ya canceladas
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day); // Normalizar para comparar solo la fecha

      final upcomingAppointments = results.map((json) => Consulta.fromJson(json)).where((consulta) {
        final appointmentDate = DateTime.parse(consulta.fecha);
        final isPast = appointmentDate.isBefore(todayDate);
        final isCancelled = consulta.estadoConsulta.estado.trim().toLowerCase() == 'cancelada';
        
        // La cita se muestra solo si NO es pasada y NO está cancelada
        return !isPast && !isCancelled;
      }).toList();

      if (mounted) {
        setState(() {
          _appointments = upcomingAppointments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelAppointment(int consultaId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cancelación'),
        content: const Text('¿Estás seguro de que deseas cancelar esta cita?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _httpService.delete('/api/consultas/$consultaId/');
        if (mounted) {
          setState(() {
            _appointments!.removeWhere((c) => c.id == consultaId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cita cancelada con éxito.'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cancelar la cita: ${e.toString()}'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  void _rescheduleAppointment(Consulta consulta) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ScheduleAppointmentScreen(appointmentToReschedule: consulta),
      ),
    ).then((success) {
      if (success == true) {
        _fetchMyAppointments(); // Recargar la lista para ver la cita actualizada
      }
    });
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: $_error', textAlign: TextAlign.center)));
    }

    if (_appointments == null || _appointments!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('No tienes citas futuras agendadas.', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMyAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _appointments!.length,
        itemBuilder: (context, index) {
          final appointment = _appointments![index];
          return AppointmentCard(
            consulta: appointment,
            onCancel: () => _cancelAppointment(appointment.id),
            onReschedule: () => _rescheduleAppointment(appointment),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Citas')),
      body: _buildBody(),
    );
  }
}