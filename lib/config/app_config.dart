class AppConfig {
  // URL del backend
  static const String baseUrl =
      'https://sitwo-project-backend-vzq2.onrender.com';
//static const String baseUrl =
//    'http://10.0.2.2:8001';
  // Endpoints de API
  static const String apiPrefix = '/api';

  // Auth endpoints

  static const String registerEndpoint = '$apiPrefix/auth/register/';
  static const String loginEndpoint = '$apiPrefix/auth/login/';

  // Health check
  static const String healthEndpoint = '$apiPrefix/health/';

  // Headers por defecto
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers con autenticación
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Token $token',
  };

  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);

  // Configuración de la app
  static const String appName = 'Dental Clinic';
  static const String appVersion = '1.0.0';
}
