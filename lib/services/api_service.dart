import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/coin_data.dart';

class ApiService {
  WebSocketChannel? _channel;
  
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator?
  // Let's assume Android emulator logic or localhost if web.
  // For iOS simulator, it's localhost.
  static const String wsUrl = 'ws://10.0.2.2:8080/ws'; 

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
