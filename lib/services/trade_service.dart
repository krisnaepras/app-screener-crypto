import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/trade_entry.dart';

class TradeService {
  // Heroku backend (production)
  static const String herokuBaseUrl =
      'https://screener-micin-eu-040b62987c7f.herokuapp.com/api/trades';

  // Local backend (development)
  static String get localBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080/api/trades';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/trades';
    }
    return 'http://localhost:8080/api/trades';
  }

  // Use Heroku by default, override with: --dart-define=USE_LOCAL=true
  static const bool useLocal = bool.fromEnvironment(
    'USE_LOCAL',
    defaultValue: false,
  );

  static String get baseUrl => useLocal ? localBaseUrl : herokuBaseUrl;

  // Create new entry
  static Future<TradeEntry> createEntry({
    required String symbol,
    required bool isLong,
    required double entryPrice,
    required double stopLoss,
    required double takeProfit1,
    required double takeProfit2,
    required double takeProfit3,
    required String entryReason,
  }) async {
    try {
      final entry = TradeEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: symbol,
        isLong: isLong,
        entryPrice: entryPrice,
        stopLoss: stopLoss,
        takeProfit1: takeProfit1,
        takeProfit2: takeProfit2,
        takeProfit3: takeProfit3,
        entryTime: DateTime.now(),
        status: 'active',
        entryReason: entryReason,
      );

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(entry.toJson()),
      );

      if (response.statusCode == 200) {
        return TradeEntry.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create entry: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating entry: $e');
    }
  }

  // Get active entries
  static Future<List<TradeEntry>> getActiveEntries() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/active'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => TradeEntry.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load active entries');
      }
    } catch (e) {
      throw Exception('Error loading active entries: $e');
    }
  }

  // Get trade history
  static Future<List<TradeEntry>> getHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}/history'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) => TradeEntry.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      throw Exception('Error loading history: $e');
    }
  }

  // Update entry status
  static Future<TradeEntry> updateEntry({
    required String id,
    required String status,
    double? exitPrice,
    String? entryReason,
  }) async {
    try {
      final body = {
        'id': id,
        'status': status,
        if (exitPrice != null) 'exitPrice': exitPrice,
        'exitTime': DateTime.now().toIso8601String(),
        if (entryReason != null) 'entryReason': entryReason,
      };

      final response = await http.put(
        Uri.parse('${baseUrl}/update?id=$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return TradeEntry.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update entry: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating entry: $e');
    }
  }

  // Delete entry
  static Future<void> deleteEntry(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}/delete?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete entry: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting entry: $e');
    }
  }
}
