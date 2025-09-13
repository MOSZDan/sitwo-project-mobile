// lib/screens/receptionist_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/consulta.dart';
import '../services/http_service.dart';
import '../utils/app_routes.dart';

class ReceptionistDashboardScreen extends StatefulWidget {
  const ReceptionistDashboardScreen({super.key});

  @override
  State<ReceptionistDashboardScreen> createState() => _ReceptionistDashboardScreenState();
}

class _ReceptionistDashboardScreenState extends State<ReceptionistDashboardScreen> {
  final HttpService _httpService = HttpService();
  List<Consulta> _appointments = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchAppointmentsForDate(_selectedDate);
  }

  Future<void> _fetchAppointmentsForDate(DateTime date) async {
    setState(() => _isLoading = true);
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final response = await _httpService.get('/api/consultas/?fecha=$dateString');
      final List<dynamic> results = response['results'];
      setState(() {
        _appointments = results.map((json) => Consulta.fromJson(json)).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar citas: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmAppointment(int appointmentId) async {
    try {
      // Asumimos que el ID del estado "Confirmada" es 2
      await _httpService.patch('/api/consultas/$appointmentId/', {'idestadoconsulta': 2});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita confirmada con éxito'), backgroundColor: Colors.green),
      );
      _fetchAppointmentsForDate(_selectedDate); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al confirmar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchAppointmentsForDate(_selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Recepcionista'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _httpService.removeToken();
              AppRoutes.navigateAndClearStack(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _appointments.isEmpty
                ? const Center(child: Text('No hay citas para esta fecha.'))
                : ListView.builder(
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final consulta = _appointments[index];
                return _buildAppointmentTile(consulta);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
              _fetchAppointmentsForDate(_selectedDate);
            },
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Text(
              DateFormat.yMMMMd('es_ES').format(_selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
              _fetchAppointmentsForDate(_selectedDate);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentTile(Consulta consulta) {
    bool isConfirmed = consulta.estadoConsulta.estado.toLowerCase() == 'confirmada';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text('${consulta.paciente.codusuario.nombre} ${consulta.paciente.codusuario.apellido}'),
        subtitle: Text('${consulta.tipoConsulta.nombre} con ${consulta.odontologo.nombreCompleto}'),
        leading: CircleAvatar(child: Text(consulta.horario.hora)),
        trailing: isConfirmed
            ? const Chip(label: Text('Confirmada'), backgroundColor: Colors.green)
            : ElevatedButton(
          onPressed: () => _confirmAppointment(consulta.id),
          child: const Text('Confirmar'),
        ),
      ),
    );
  }
}