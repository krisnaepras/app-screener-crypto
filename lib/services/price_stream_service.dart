import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/coin_data.dart';
import 'api_service.dart';

/// Service to stream real-time price updates for active positions
class PriceStreamService {
  WebSocketChannel? _channel;
  Stream<Map<String, double>>? _priceStream;

  /// Get a stream of current prices keyed by symbol (e.g., 'BTCUSDT' -> 45000.0)
  Stream<Map<String, double>> getPriceStream() {
    if (_priceStream != null) {
      return _priceStream!;
    }

    _channel = WebSocketChannel.connect(Uri.parse(ApiService.wsUrl));

    _priceStream = _channel!.stream.map((event) {
      if (event == null) return <String, double>{};
      try {
        final List<dynamic> data = json.decode(event);
        final Map<String, double> prices = {};

        for (var item in data) {
          final coin = CoinData.fromJson(item);
          prices[coin.symbol] = coin.price;
        }

        return prices;
      } catch (e) {
        print('Error parsing price data: $e');
        return <String, double>{};
      }
    }).asBroadcastStream(); // Broadcast so multiple listeners can subscribe

    return _priceStream!;
  }

  void close() {
    _channel?.sink.close();
    _priceStream = null;
  }
}
