import 'package:flutter/material.dart';
import '../services/http_service.dart';
import '../utils/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final httpService = HttpService();
    await httpService.removeToken();
    AppRoutes.navigateAndClearStack(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página de Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => AppRoutes.navigateToProfile(context),
            tooltip: 'Editar Perfil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Inicio de sesión exitoso!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Bienvenido a la aplicación.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Botón principal - Programar Cita
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text('Programar Cita'),
              onPressed: () {
                AppRoutes.navigateToScheduleAppointment(context);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            // Botón secundario - Ver Mis Citas
            OutlinedButton.icon(
              icon: const Icon(Icons.list_alt_outlined),
              label: const Text('Ver Mis Citas'),
              onPressed: () {
                AppRoutes.navigateToMyAppointments(context);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 48),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),

            // Botón secundario - Configurar Notificaciones
            OutlinedButton.icon(
              icon: const Icon(Icons.notifications_outlined),
              label: const Text('Configurar Notificaciones'),
              onPressed: () {
                AppRoutes.navigateToNotificationSettings(context);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 48),
                textStyle: const TextStyle(fontSize: 16),
                side: const BorderSide(color: Color(0xFF8B5CF6)),
                foregroundColor: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}