// lib/services/notifications/fcm_initializer.dart
import 'dart:io';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../firebase_options.dart';
import 'device_registry.dart';

@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

final FlutterLocalNotificationsPlugin _local =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel _androidChannel = AndroidNotificationChannel(
  'smilestudio_default',
  'SmileStudio Notificaciones',
  description: 'Canal por defecto para notificaciones push',
  importance: Importance.high,
  playSound: true,
);

class FcmInitializer {
  /// Inicializa FCM y registra el dispositivo en el backend cuando haya sesión.
  static Future<void> init({
    required String baseUrl,
    required Future<String?> Function() getAuthToken,
    String appVersion = '1.0.0',
  }) async {
    // 1) Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 2) Handlers
    FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // 3) Permisos (iOS / Android 13+)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (kDebugMode) {
      debugPrint('FCM permission: ${settings.authorizationStatus}');
    }

    // 4) Canal + notificaciones locales (foreground)
    await _initLocalNotifications();

    // 5) Token con reintentos (evita crash por SERVICE_NOT_AVAILABLE)
    final token = await _tryGetToken(retries: 5);
    if (token != null && token.isNotEmpty) {
      if (kDebugMode) debugPrint('FCM TOKEN OBTENIDO: $token');
      await DeviceRegistry.register(
        baseUrl: baseUrl,
        getAuthToken: getAuthToken,
        fcmToken: token,
        appVersion: appVersion,
      );
    } else {
      if (kDebugMode) debugPrint('FCM: no se obtuvo token tras reintentos');
    }

    // 6) Refresh de token → re-registrar
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) debugPrint('FCM TOKEN REFRESH: $newToken');
      if (newToken.isNotEmpty) {
        await DeviceRegistry.register(
          baseUrl: baseUrl,
          getAuthToken: getAuthToken,
          fcmToken: newToken,
          appVersion: appVersion,
        );
      }
    });

    // 7) Mensajes
    FirebaseMessaging.onMessage.listen((RemoteMessage m) async {
      await _showLocal(m);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage m) async {
      if (kDebugMode) debugPrint('onMessageOpenedApp data: ${m.data}');
    });
  }

  static Future<String?> _tryGetToken({int retries = 3}) async {
    for (var i = 0; i < retries; i++) {
      try {
        final t = await FirebaseMessaging.instance.getToken();
        if (t != null && t.isNotEmpty) return t;
        if (kDebugMode) {
          debugPrint(
            'getToken devolvió null/empty (intento ${i + 1}/$retries)',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('FCM getToken error (intento ${i + 1}/$retries): $e');
        }
      }
      await Future.delayed(Duration(seconds: 2 * (i + 1)));
    }
    return null;
  }

  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );
    await _local.initialize(initSettings);

    if (Platform.isAndroid) {
      final android =
          _local
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await android?.createNotificationChannel(_androidChannel);
    }
  }

  static Future<void> _showLocal(RemoteMessage m) async {
    final title = m.notification?.title ?? 'Notificación';
    final body = m.notification?.body ?? '';
    final data = m.data;

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );
    await _local.show(
      m.hashCode,
      title,
      body,
      details,
      payload: data.isEmpty ? null : jsonEncode(data),
    );
  }
}
