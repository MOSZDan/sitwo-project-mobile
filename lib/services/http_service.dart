import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal();

  // GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await _getToken();
      final headers =
          token != null
              ? AppConfig.getAuthHeaders(token)
              : AppConfig.defaultHeaders;

      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}$endpoint'), headers: headers)
          .timeout(AppConfig.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error en GET: $e');
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await _getToken();
      final headers =
          token != null
              ? AppConfig.getAuthHeaders(token)
              : AppConfig.defaultHeaders;

      final response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}$endpoint'),
            headers: headers,
            body: json.encode(data),
          )
          .timeout(AppConfig.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error en POST: $e');
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final token = await _getToken();
      final headers =
          token != null
              ? AppConfig.getAuthHeaders(token)
              : AppConfig.defaultHeaders;

      final response = await http
          .put(
            Uri.parse('${AppConfig.baseUrl}$endpoint'),
            headers: headers,
            body: json.encode(data),
          )
          .timeout(AppConfig.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error en PUT: $e');
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await _getToken();
      final headers =
          token != null
              ? AppConfig.getAuthHeaders(token)
              : AppConfig.defaultHeaders;

      final response = await http
          .delete(Uri.parse('${AppConfig.baseUrl}$endpoint'), headers: headers)
          .timeout(AppConfig.requestTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error en DELETE: $e');
    }
  }

  // Manejo de respuestas
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return json.decode(response.body);
    } else {
      String errorMessage;
      try {
        final errorBody = json.decode(response.body);

        // Manejo específico por código de error
        switch (response.statusCode) {
          case 400:
            if (errorBody['email'] != null) {
              errorMessage = 'Este email ya está registrado';
            } else if (errorBody['carnetidentidad'] != null) {
              errorMessage = 'Este carnet de identidad ya está registrado';
            } else {
              errorMessage =
                  errorBody['detail'] ??
                  errorBody['message'] ??
                  'Los datos enviados no son válidos';
            }
            break;
          case 401:
            errorMessage = 'Credenciales incorrectas';
            break;
          case 403:
            errorMessage = 'No tienes permisos para realizar esta acción';
            break;
          case 404:
            errorMessage = 'El recurso solicitado no existe';
            break;
          case 500:
            errorMessage = 'Error interno del servidor';
            break;
          default:
            errorMessage =
                errorBody['detail'] ??
                errorBody['message'] ??
                'Error del servidor: ${response.statusCode}';
        }
      } catch (e) {
        errorMessage = 'Error del servidor: ${response.statusCode}';
      }
      throw Exception(errorMessage);
    }
  }

  // Gestión de tokens
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
