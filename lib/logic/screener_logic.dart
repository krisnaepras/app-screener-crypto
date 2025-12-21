import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../models/coin_data.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class ScreenerLogic {
  final ApiService _apiService = ApiService();
  final Set<String> _notifiedCoins = {}; // Track coins we've already notified
  StreamSubscription<List<CoinData>>? _notificationSubscription;

  Stream<List<CoinData>> get coinStream {
    // Avoid network/websocket connections during widget/unit tests.
    final bool isTest =
        !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (isTest) {
      return Stream<List<CoinData>>.empty();
    }

    final stream = _apiService.getCoinStream();

    // Start monitoring for notifications if on mobile
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _startNotificationMonitoring(stream);
    }

    return stream;
  }

  void _startNotificationMonitoring(Stream<List<CoinData>> stream) {
    _notificationSubscription?.cancel();
    _notificationSubscription = stream.listen((coins) {
      _checkForTriggers(coins);
    });
  }

  void _checkForTriggers(List<CoinData> coins) {
    for (final coin in coins) {
      // Only notify for TRIGGER status with high score
      if (coin.status == 'TRIGGER' && coin.score >= 70) {
        // Check if we haven't notified for this coin recently
        if (!_notifiedCoins.contains(coin.symbol)) {
          _notifiedCoins.add(coin.symbol);

          // Send notification
          NotificationService.showNotification(
            id: coin.symbol.hashCode,
            title: '🚀 ${coin.symbol.replaceAll('USDT', '')} TRIGGER',
            body:
                'Score: ${coin.score.toStringAsFixed(0)} | Price: \$${coin.price > 1 ? coin.price.toStringAsFixed(2) : coin.price.toStringAsFixed(5)} | Change: ${coin.priceChangePercent.toStringAsFixed(2)}%',
          );

          // Remove from notified set after 5 minutes to allow re-notification
          Future.delayed(const Duration(minutes: 5), () {
            _notifiedCoins.remove(coin.symbol);
          });
        }
      } else {
        // If coin is no longer TRIGGER, remove from notified set
        _notifiedCoins.remove(coin.symbol);
      }
    }
  }

  void dispose() {
    _notificationSubscription?.cancel();
    _apiService.close();
  }
}
