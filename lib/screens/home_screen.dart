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
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: Center( // El body ya no necesita ser 'const' para poder añadir un botón con una función
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

            // ===== 👇 ESTE ES EL BOTÓN QUE FALTABA 👇 =====
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text('Programar Cita'),
              onPressed: () {
                // Navega a la pantalla para programar citas
                AppRoutes.navigateToScheduleAppointment(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.list_alt_outlined),
              label: const Text('Ver Mis Citas'),
              onPressed: () {
                AppRoutes.navigateToMyAppointments(context);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(200, 48), // Tamaño mínimo
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}