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

      // Track notified coins to prevent spam
      final notifiedScalpLongs =
          prefs.getStringList('notified_scalp_longs') ?? [];
      final notifiedScalpShorts =
          prefs.getStringList('notified_scalp_shorts') ?? [];

      for (var coin in results) {
        final String key = 'status_${coin.symbol}';
        final String? lastStatus = prefs.getString(key);

        // Home Screen Notifications (TRIGGER/SETUP)
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

        // Scalping Notifications (Quality 60+ and SCALP LONG/SHORT only)
        if (coin.features != null) {
          final scalpScore = _calculateScalpingScore(coin);
          final scalpSignal = _getScalpingSignal(coin);

          // Only notify if:
          // 1. Score >= 60 (good quality)
          // 2. Signal is SCALP LONG or SCALP SHORT (not WATCH or RANGING)
          if (scalpScore >= 60) {
            if (scalpSignal['signal'] == '🟢 SCALP LONG' &&
                !notifiedScalpLongs.contains(coin.symbol)) {
              await NotificationService.showNotification(
                id: (coin.symbol + '_scalp_long').hashCode,
                title: '⚡ SCALP LONG ${coin.symbol}',
                body:
                    'Quality: ${scalpScore.toStringAsFixed(0)}/100 • Entry: \$${coin.price.toStringAsFixed(4)}',
              );
              notifiedScalpLongs.add(coin.symbol);
              await prefs.setStringList(
                'notified_scalp_longs',
                notifiedScalpLongs,
              );
            } else if (scalpSignal['signal'] == '🔴 SCALP SHORT' &&
                !notifiedScalpShorts.contains(coin.symbol)) {
              await NotificationService.showNotification(
                id: (coin.symbol + '_scalp_short').hashCode,
                title: '⚡ SCALP SHORT ${coin.symbol}',
                body:
                    'Quality: ${scalpScore.toStringAsFixed(0)}/100 • Entry: \$${coin.price.toStringAsFixed(4)}',
              );
              notifiedScalpShorts.add(coin.symbol);
              await prefs.setStringList(
                'notified_scalp_shorts',
                notifiedScalpShorts,
              );
            }
          }
        }

        await prefs.setString(key, coin.status);
      }

      // Clear old scalping notifications (reset every 10 minutes to allow re-notification)
      final lastClear = prefs.getInt('last_scalp_clear') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastClear > 600000) {
        // 10 minutes
        await prefs.remove('notified_scalp_longs');
        await prefs.remove('notified_scalp_shorts');
        await prefs.setInt('last_scalp_clear', now);
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

// Helper functions for scalping (copied from scalping_screen.dart logic)
double _calculateScalpingScore(coin) {
  final features = coin.features!;
  double score = 0;

  // Momentum (40 points)
  final momentum = coin.priceChangePercent.abs();
  if (momentum >= 3 && momentum <= 8) {
    score += 20;
  } else if (momentum > 1 && momentum < 15) {
    score += 10;
  }

  // VWAP proximity (20 points)
  final vwapDist = features.overExtVwap.abs();
  if (vwapDist < 0.01) {
    score += 20;
  } else if (vwapDist < 0.02) {
    score += 10;
  }

  // EMA position (20 points)
  final emaDist = features.overExtEma.abs();
  if (emaDist < 0.02) {
    score += 20;
  } else if (emaDist < 0.03) {
    score += 10;
  }

  // Structure (20 points)
  if (features.isRetest) score += 15;
  if (features.isBreakdown) score += 10;
  if (features.nearestSupport != null &&
      features.distToSupportATR != null &&
      features.distToSupportATR!.abs() < 3) {
    score += 10;
  }

  return score;
}

Map<String, dynamic> _getScalpingSignal(coin) {
  final features = coin.features!;
  String signal = '';
  Color color = Colors.grey;
  List<String> reasons = [];

  final priceChange = coin.priceChangePercent;
  final overEma = features.overExtEma;
  final overVwap = features.overExtVwap;

  // LONG setup
  if (priceChange < 0 &&
      overEma < 0 &&
      (features.isRetest || features.rsi < 45)) {
    if (features.isRetest) reasons.add('Retest Support');
    if (overVwap < -0.01) reasons.add('Below VWAP');
    if (features.rsi < 45)
      reasons.add('RSI ${features.rsi.toStringAsFixed(0)}');

    if (reasons.length >= 2) {
      signal = '🟢 SCALP LONG';
      color = Colors.green;
    } else {
      signal = '🟡 WATCH LONG';
      color = Colors.yellow;
    }
  }
  // SHORT setup
  else if (priceChange > 0 &&
      overEma > 0 &&
      (features.isBreakdown || features.rsi > 55)) {
    if (features.isBreakdown) reasons.add('Breakdown');
    if (overVwap > 0.01) reasons.add('Above VWAP');
    if (features.rsi > 55)
      reasons.add('RSI ${features.rsi.toStringAsFixed(0)}');

    if (reasons.length >= 2) {
      signal = '🔴 SCALP SHORT';
      color = Colors.red;
    } else {
      signal = '🟠 WATCH SHORT';
      color = Colors.orange;
    }
  }
  // Ranging
  else {
    signal = '⚪ RANGING';
    color = Colors.grey;
  }

  return {'signal': signal, 'color': color, 'reasons': reasons};
}
