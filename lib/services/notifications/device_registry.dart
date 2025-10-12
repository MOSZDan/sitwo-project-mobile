import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';

typedef GetAuthToken = Future<String?> Function();

class DeviceRegistry {
  /// Registra/actualiza el dispositivo en el backend (endpoint real).
  static Future<void> register({
    required String baseUrl,
    required GetAuthToken getAuthToken,
    required String fcmToken,
    String? model,
    String? appVersion,
    String androidChannel = 'smilestudio_default',
  }) async {
    final auth = await getAuthToken();
    if (auth == null || auth.isEmpty) return;

    final uri = Uri.parse('$baseUrl/api/mobile-notif/register-device/');
    final body = <String, dynamic>{
      'token_fcm': fcmToken,
      'plataforma': Platform.isAndroid ? 'android' : 'ios',
      'modelo_dispositivo': model ?? '',
      'version_app': appVersion ?? '',
      'canal_android': androidChannel,
      // ⚠️ NO ENVIAR usuario_codigo: el backend lo resuelve desde el token
    };

    final resp = await http.post(
      uri,
      headers: {
        ...AppConfig.getAuthHeaders(auth),
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode >= 400) {
      if (kDebugMode) {
        debugPrint(
          '[DeviceRegistry] register-device ${resp.statusCode}: ${resp.body}',
        );
      }
    }
  }
}
