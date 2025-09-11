import 'package:flutter/material.dart';
import '../screens/register_screen.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
// import '../screens/profile_screen.dart';       // Descomentar cuando exista
// import '../screens/appointments_screen.dart';  // Descomentar cuando exista

class AppRoutes {
  // Rutas definidas como constantes
  static const String register = '/register';
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String appointments = '/appointments';
  static const String splash = '/splash';

  // Mapa de rutas - fácil de mantener
  static Map<String, WidgetBuilder> get routes {
    return {
      register: (context) => const RegisterScreen(),
      login: (context) => const LoginScreen(),
      home: (context) => const HomeScreen(),

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
}
