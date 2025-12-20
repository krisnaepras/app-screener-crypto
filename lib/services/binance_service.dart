import 'dart:convert';
import 'package:http/http.dart' as http;

class Ticker24h {
  final String symbol;
  final String priceChangePercent;
  final String lastPrice;
  final String quoteVolume;

  Ticker24h({
    required this.symbol,
    required this.priceChangePercent,
    required this.lastPrice,
    required this.quoteVolume,
  });

  factory Ticker24h.fromJson(Map<String, dynamic> json) {
    return Ticker24h(
      symbol: json['symbol'],
      priceChangePercent: json['priceChangePercent'],
      lastPrice: json['lastPrice'],
      quoteVolume: json['quoteVolume'],
    );
  }
}

class BinanceService {
  static const String fapiBaseUrl = 'https://fapi.binance.com';
  static const String spotBaseUrl = 'https://api.binance.com';

  Future<List<Ticker24h>> getFutures24hrTicker() async {
    final response = await http.get(
      Uri.parse('$fapiBaseUrl/fapi/v1/ticker/24hr'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Ticker24h.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load futures tickers');
    }
  }

  Future<List<Ticker24h>> getSpot24hrTicker() async {
    final response = await http.get(
      Uri.parse('$spotBaseUrl/api/v3/ticker/24hr'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Ticker24h.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load spot tickers');
    }
  }

  Future<List<List<dynamic>>> getKlines(
    String symbol,
    String interval,
    int limit,
  ) async {
    // Default to Futures klines as logic relies on it
    final response = await http.get(
      Uri.parse(
        '$fapiBaseUrl/fapi/v1/klines?symbol=$symbol&interval=$interval&limit=$limit',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<List<dynamic>>();
    } else {
      throw Exception('Failed to load klines for $symbol');
    }
  }

  Future<double> getFundingRate(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$fapiBaseUrl/fapi/v1/premiumIndex?symbol=$symbol'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return double.tryParse(data['lastFundingRate'] ?? '0') ?? 0;
      }
    } catch (e) {
      // Ignore
    }
    return 0;
  }

  Future<double> getSpotPrice(String baseAsset) async {
    try {
      final symbol = '${baseAsset}USDT';
      final response = await http.get(
        Uri.parse('$spotBaseUrl/api/v3/ticker/price?symbol=$symbol'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return double.tryParse(data['price'] ?? '0') ?? 0;
      }
    } catch (e) {
      // Ignore - asset might not have spot market
    }
    return 0;
  }
}
