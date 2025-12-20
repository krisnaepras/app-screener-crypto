import 'dart:async';
import 'dart:ui';
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

  // Logic Loop
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
          title: "Screener Active",
          content:
              "Scanning market at ${DateTime.now().minute}:${DateTime.now().second}",
        );
      }
    }

    // Run Logic
    try {
      final logic = ScreenerLogic();
      final results = await logic.scan(
        limit: 30,
      ); // limited to save bandwidth/battery
      final prefs = await SharedPreferences.getInstance();

      for (var coin in results) {
        final String key = 'status_${coin.symbol}';
        final String? lastStatus = prefs.getString(key);

        if (coin.status == 'TRIGGER') {
          if (lastStatus != 'TRIGGER') {
            await NotificationService.showNotification(
              id: coin.symbol.hashCode,
              title: 'EKSEKUSI! ${coin.symbol}',
              body:
                  'Score: ${coin.score.toStringAsFixed(1)}. Breakout detected!',
            );
          }
        } else if (coin.status == 'SETUP') {
          if (lastStatus != 'SETUP' && lastStatus != 'TRIGGER') {
            await NotificationService.showNotification(
              id: coin.symbol.hashCode,
              title: 'SIAP SIAP! ${coin.symbol}',
              body: 'Score: ${coin.score.toStringAsFixed(1)}. High potential.',
            );
          }
        }
        await prefs.setString(key, coin.status);
      }

      // Update data for UI if app is open
      service.invoke('update', {
        'data': results.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      print("Service Error: $e");
    }
  });
}
