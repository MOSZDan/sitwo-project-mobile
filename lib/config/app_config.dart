class AppConfig {
  // URL del backend
  static const String baseUrl = //'http://127.0.0.1:8000';
      //'http://10.0.2.2:8000'; //'http://192.168.0.7:8000' ;
      'https://notificct.dpdns.org';

  // Endpoints de API
  static const String apiPrefix = '/api';

  // Auth endpoints

  static const String registerEndpoint = '$apiPrefix/auth/register/';
  static const String loginEndpoint = '$apiPrefix/auth/login/';

  // Health check
  static const String healthEndpoint = '$apiPrefix/health/';
  static const String odontologosEndpoint = '$apiPrefix/odontologos/';
  static const String horariosEndpoint = '$apiPrefix/horarios/';
  static const String tiposConsultaEndpoint = '$apiPrefix/tipos-consulta/';
  static const String consultasEndpoint = '$apiPrefix/consultas/';

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

  // Headers con autenticación y tenant
  static Map<String, String> getAuthHeadersWithTenant(String token, String? tenantSubdomain) {
    final headers = {
      ...defaultHeaders,
      'Authorization': 'Token $token',
    };

    // Agregar header de tenant si está disponible
    if (tenantSubdomain != null && tenantSubdomain.isNotEmpty) {
      headers['X-Tenant-Subdomain'] = tenantSubdomain;
    }

    return headers;
  }

  // Headers con tenant (sin autenticación)
  static Map<String, String> getHeadersWithTenant(String? tenantSubdomain) {
    final headers = {...defaultHeaders};

    // Agregar header de tenant si está disponible
    if (tenantSubdomain != null && tenantSubdomain.isNotEmpty) {
      headers['X-Tenant-Subdomain'] = tenantSubdomain;
    }

    return headers;
  }

  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);

  // Configuración de la app
  static const String appName = 'Dental Clinic';
  static const String appVersion = '1.0.0';

  // Configuración Multi-Tenant
  static const bool multiTenantEnabled = true;
  static const String tenantInputHint = 'Ej: norte, sur, este';
  static const String tenantInputLabel = 'Código de Clínica';
  static const String tenantInputHelper = 'Ingresa el código proporcionado por tu clínica';
}
