import 'package:flutter/material.dart';
import '../screens/register_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/schedule_appointment_screen.dart';
import '../screens/receptionist_dashboard_screen.dart';
// import '../screens/profile_screen.dart';       // Descomentar cuando exista
// import '../screens/appointments_screen.dart';  // Descomentar cuando exista
import '../screens/my_appointments_screen.dart';
import '../screens/profile_screen.dart';

class AppRoutes {
  // Rutas definidas como constantes
  static const String register = '/register';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String myAppointments = '/my-appointments';
  static const String appointments = '/appointments';
  static const String splash = '/splash';
  static const String scheduleAppointment = '/schedule-appointment';
  static const String receptionistDashboard = '/receptionist-dashboard';


  // Mapa de rutas - fácil de mantener

  static Map<String, WidgetBuilder> get routes {
    return {
      register: (context) => const RegisterScreen(),
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),
      scheduleAppointment: (context) => const ScheduleAppointmentScreen(),
      myAppointments: (context) => const MyAppointmentsScreen(),
      receptionistDashboard: (context) => const ReceptionistDashboardScreen(),
      profile: (context) => const ProfileScreen(),
      // TODO: Descomentar cuando las pantallas existan
      // profile: (context) => const ProfileScreen(),
      // appointments: (context) => const AppointmentsScreen(),
    };
  }

  // Rutas dinámicas - para rutas con parámetros
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Ejemplo de ruta con parámetros
      // case '/appointment-details':
      //   final appointmentId = settings.arguments as String;
      //   return MaterialPageRoute(
      //     builder: (context) => AppointmentDetailsScreen(appointmentId: appointmentId),
      //   );

      // Ruta por defecto si no encuentra la ruta
      default:
        return MaterialPageRoute(
          builder:
              (context) => Scaffold(
                appBar: AppBar(title: const Text('Página no encontrada')),
                body: const Center(
                  child: Text('Error 404 - Pantalla no encontrada'),
                ),
              ),
        );
    }
  }

  static void navigateToScheduleAppointment(BuildContext context) {
    Navigator.pushNamed(context, scheduleAppointment);
  }

  // Métodos de navegación helper - para usar en toda la app
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, login);
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, register);
  }

  static void navigateToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, home);
  }

  static void navigateToProfile(BuildContext context) {
    Navigator.pushNamed(context, profile);
  }

  static void navigateToAppointments(BuildContext context) {
    Navigator.pushNamed(context, appointments);
  }

  // Navegación con reemplazo de toda la pila (para logout)
  static void navigateAndClearStack(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  static void navigateToMyAppointments(BuildContext context) {
    Navigator.pushNamed(context, myAppointments);
  }

  static void navigateToReceptionistDashboard(BuildContext context) {
    Navigator.pushReplacementNamed(context, receptionistDashboard);
  }

}
