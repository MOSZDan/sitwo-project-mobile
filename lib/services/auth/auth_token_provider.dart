// lib/services/auth/auth_token_provider.dart
class AuthTokenProvider {
  AuthTokenProvider._internal();
  static final AuthTokenProvider instance = AuthTokenProvider._internal();

  String? _token;

  /// Guarda el JWT (llámalo al terminar login)
  void setToken(String token) {
    _token = token;
  }

  /// Borra el JWT (logout)
  void clear() {
    _token = null;
  }

  /// Obtiene el JWT actual
  Future<String?> getToken() async => _token;
}
