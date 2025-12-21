import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/binance_api_models.dart';
import 'api_service.dart';

class BinanceAPIService {
  static const String userId = 'default-user'; // Can be dynamic per user

  // Save API credentials
  Future<Map<String, dynamic>> saveCredentials({
    required String apiKey,
    required String secretKey,
    bool isTestnet = false,
    bool isEnabled = true,
  }) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/binance/credentials');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': userId,
        'apiKey': apiKey,
        'secretKey': secretKey,
        'isTestnet': isTestnet,
        'isEnabled': isEnabled,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Failed to save credentials');
    }
  }

  // Get API credentials status
  Future<Map<String, dynamic>> getCredentialsStatus() async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/api/binance/credentials?userId=$userId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {'exists': false};
    }
  }

  // Delete credentials
  Future<void> deleteCredentials() async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/api/binance/credentials?userId=$userId',
    );

    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete credentials');
    }
  }

  // Get account info
  Future<BinanceAccountInfo> getAccountInfo() async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/api/binance/account?userId=$userId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BinanceAccountInfo.fromJson(data);
    } else {
      throw Exception('Failed to get account info');
    }
  }

  // Test connection
  Future<Map<String, dynamic>> testConnection() async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/api/binance/test-connection?userId=$userId',
    );

    final response = await http.post(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['error'] ?? 'Connection test failed');
    }
  }

  // Save trading config
  Future<void> saveTradingConfig(BinanceTradingConfig config) async {
    final url = Uri.parse('${ApiService.baseUrl}/api/binance/trading-config');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(config.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save trading config');
    }
  }

  // Get trading config
  Future<BinanceTradingConfig> getTradingConfig() async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/api/binance/trading-config?userId=$userId',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BinanceTradingConfig.fromJson(data);
    } else {
      // Return default config
      return BinanceTradingConfig(userId: userId);
    }
  }
}
