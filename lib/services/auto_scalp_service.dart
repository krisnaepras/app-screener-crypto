import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auto_scalp_entry.dart';
import '../models/auto_scalp_settings.dart';
import 'api_service.dart';

class AutoScalpService {
  final String baseUrl = ApiService.baseUrl;

  Future<AutoScalpSettings> getSettings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/autoscalp/settings'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return AutoScalpSettings.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load settings: ${response.body}');
    }
  }

  Future<void> updateSettings(AutoScalpSettings settings) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/autoscalp/settings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(settings.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update settings: ${response.body}');
    }
  }

  Future<List<AutoScalpEntry>> getActivePositions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/autoscalp/active'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data == null) return [];
        if (data is! List) return [];
        return data.map((item) => AutoScalpEntry.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load active positions: ${response.body}');
      }
    } catch (e) {
      print('Error loading active positions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getHistory(String period) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/autoscalp/history?period=$period'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> historyData = data['history'] ?? [];
        final Map<String, dynamic> statsData = data['stats'] ?? {};

        return {
          'history': historyData
              .map((item) => AutoScalpEntry.fromJson(item))
              .toList(),
          'stats': statsData,
        };
      } else {
        throw Exception('Failed to load history: ${response.body}');
      }
    } catch (e) {
      print('Error loading history: $e');
      return {
        'history': <AutoScalpEntry>[],
        'stats': {
          'totalTrades': 0,
          'winRate': 0.0,
          'totalProfitPct': 0.0,
          'avgDuration': 0,
        },
      };
    }
  }
}
