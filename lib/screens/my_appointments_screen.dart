// lib/screens/my_appointments_screen.dart
import 'package:flutter/material.dart';
import '../models/consulta.dart';
import '../services/http_service.dart';
import '../widgets/appointment_card.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final HttpService _httpService = HttpService();
  late Future<List<Consulta>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _fetchMyAppointments();
  }

  Future<List<Consulta>> _fetchMyAppointments() async {
    final patientId = await _httpService.getPatientId();
    if (patientId == null) {
      throw Exception('ID de paciente no encontrado. Por favor, inicie sesión de nuevo.');
    }

    final response = await _httpService.get('/api/consultas/?codpaciente=$patientId');
    final List<dynamic> results = response['results'];

    return results.map((json) => Consulta.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
      ),
      body: FutureBuilder<List<Consulta>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
              ),
            );
          }

          final appointments = snapshot.data;
          if (appointments == null || appointments.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aún no tienes citas agendadas.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _appointmentsFuture = _fetchMyAppointments();
              });
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                return AppointmentCard(consulta: appointments[index]);
              },
            ),
          );
        },
      ),
    );
  }
}