import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coin_data.dart';

class ApiService {
  // TODO: Replace with the actual deployed URL or user's local IP if testing on device
  // For Android Emulator, 10.0.2.2 points to host localhost.
  static const String baseUrl = 'http://10.0.2.2:5173/api/rank'; 

  Future<List<CoinData>> fetchRank() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CoinData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load rank: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load rank: $e');
    }
  }
}
