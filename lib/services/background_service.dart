import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screener_micin_app/services/notification_service.dart'; // Adjust package name
import 'package:screener_micin_app/logic/screener_logic.dart'; // Adjust package name

// Foreground Service Logic
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'screener_service',
      initialNotificationTitle: 'Screener Service',
      initialNotificationContent: 'Monitoring market...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(autoStart: true, onForeground: onStart),
  );
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Do NOT call DartPluginRegistrant here - it should only be in main isolate
  // DartPluginRegistrant.ensureInitialized();

  // Set up notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // We assume NotificationService.initialize() logic is essentially this setup,
  // but we need to ensure the channel exists for the service notification itself.

  // Create channel for the Foreground Service notification
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'screener_service',
    'Screener Background Service',
    description: 'Running screener in background',
    importance: Importance.low,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  // Initialize general alerts channel
  await NotificationService.initialize();

  // Logic Loop - DISABLED for WebSocket Backend
  // Background service is not needed with real-time WebSocket streaming from Golang backend
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Screener Active",
          content: "Using Realtime WebSocket Backend",
        );
      }
    }

    // No scanning logic - app receives real-time data via WebSocket
  });
}
