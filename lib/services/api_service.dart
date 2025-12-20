import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/coin_data.dart';

class ApiService {
  WebSocketChannel? _channel;

  // Heroku EU backend (production) - WORKING! ✅
  // Deployed to Europe region to bypass Binance geo-restriction
  static const String herokuWsUrl =
      'wss://screener-micin-eu-040b62987c7f.herokuapp.com/ws';

  // Localhost backend (development) - for local testing
  static String get localWsUrl {
    if (kIsWeb) {
      return 'ws://localhost:8080/ws';
    } else if (Platform.isAndroid) {
      return 'ws://10.0.2.2:8080/ws'; // Android emulator address
    } else {
      return 'ws://localhost:8080/ws'; // iOS/Desktop
    }
  }

  // Use Heroku EU by default (production), or set USE_LOCAL=true for development
  static const bool useLocal = bool.fromEnvironment(
    'USE_LOCAL',
    defaultValue: false,
  );
  static String get wsUrl => useLocal ? localWsUrl : herokuWsUrl;

  Stream<List<CoinData>> getCoinStream() {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    return _channel!.stream.map((event) {
      if (event == null) return [];
      try {
        final List<dynamic> data = json.decode(event);
        return data.map((json) => CoinData.fromJson(json)).toList();
      } catch (e) {
        print('Error parsing WS data: $e');
        return [];
      }
    });
  }

  void close() {
    _channel?.sink.close();
  }
}
